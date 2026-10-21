"""Genera la música de Hexiege por síntesis (sin assets de terceros).

Uso:  python3 tool/gen_music.py   → escribe assets/music/*.m4a (necesita afconvert o ffmpeg)

Cuatro loops ambientales, pensados para sonar de fondo debajo de los efectos:
  menu    — cuencos, koto disperso y un colchón cálido.
  shaolin — dizi (flauta de bambú) sobre pentatónica china, guzheng y bordón.
  ninja   — shakuhachi en escala in (miyako-bushi), koto y taiko suave.
  oni     — bordón grave en trítono, taiko lento y metal frotado disonante.

Todo es determinista (semillas fijas). Cada loop se renderiza con su cola de
reverb y la cola se suma al principio, así el corte del loop no se oye.
"""

import os
import shutil
import subprocess
import tempfile
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'music')


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def onepole_lp(x, cutoff):
    """Pasa-bajos de un polo vectorizado por bloques vía filtro IIR en frecuencia."""
    n = len(x)
    a = np.exp(-2 * np.pi * cutoff / SR)
    # Respuesta en frecuencia del filtro de un polo, aplicada por FFT (suficiente acá).
    f = np.fft.rfftfreq(n * 2, 1 / SR)
    z = np.exp(-2j * np.pi * f / SR)
    h = (1 - a) / (1 - a * z)
    y = np.fft.irfft(np.fft.rfft(x, n * 2) * h)[:n]
    return y


def bandpass(x, lo, hi):
    n = len(x)
    spec = np.fft.rfft(x, n * 2)
    f = np.fft.rfftfreq(n * 2, 1 / SR)
    # Ventana suave en frecuencia para no sonar a filtro de ladrillo.
    w = 1 / (1 + ((f - (lo + hi) / 2) / ((hi - lo) / 2)) ** 4)
    return np.fft.irfft(spec * w)[:n]


def reverb_ir(seconds, seed, damp=6000):
    rng = np.random.default_rng(seed)
    t = t_axis(seconds)
    ir = rng.standard_normal(len(t)) * np.exp(-t / (seconds / 6.5))
    ir = onepole_lp(ir, damp)
    ir[: int(SR * 0.012)] *= np.linspace(0, 1, int(SR * 0.012))
    return ir / np.sqrt(np.sum(ir ** 2))


def convolve(x, ir):
    n = len(x) + len(ir) - 1
    size = 1 << (n - 1).bit_length()
    return np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size))[:n]


def env_adsr(n, a, d, s, r):
    e = np.ones(n) * s
    na, nd, nr = int(SR * a), int(SR * d), int(SR * r)
    na = min(na, n)
    e[:na] = np.linspace(0, 1, na) if na else e[:na]
    end = min(na + nd, n)
    e[na:end] = np.linspace(1, s, end - na)
    if nr and nr < n:
        e[-nr:] *= np.linspace(1, 0, nr)
    return e


# ------------------------------------------------------------------ instrumentos


def pluck(f, dur, rng, bright=1.0, bend=0.0):
    """Cuerda pulsada (koto/guzheng): parciales con decaimiento propio, los agudos
    se apagan antes; [bend] = ligera subida de pitch tras el ataque (guzheng)."""
    t = t_axis(dur)
    glide = 1 + bend * (1 - np.exp(-t / 0.18)) * (t > 0.08)
    x = np.zeros_like(t)
    for k in range(1, 9):
        inharm = 1 + 0.0007 * k * k
        amp = (1 / k ** 1.1) * (1.0 if k == 1 else bright)
        decay = 1.6 / (1 + 0.55 * (k - 1))
        ph = 2 * np.pi * np.cumsum(f * k * inharm * glide) / SR + rng.uniform(0, 6.28)
        x += amp * np.sin(ph) * np.exp(-t / decay)
    # Ataque: ruido corto filtrado (la uña sobre la cuerda).
    x += 0.25 * bandpass(rng.standard_normal(len(t)), f * 2, f * 6) * np.exp(-t / 0.012)
    x *= np.clip(t / 0.003, 0, 1)
    x[-int(SR * 0.05):] *= np.linspace(1, 0, int(SR * 0.05))
    return x


def flute(f, dur, rng, breath=0.35, scoop=0.0, vibrato=5.2, depth=0.006, bright=0.35):
    """Flauta de bambú: fundamental con pocos armónicos, soplo filtrado,
    vibrato que entra de a poco y [scoop] = entrada desde abajo (meri del shakuhachi)."""
    t = t_axis(dur)
    vib_on = np.clip((t - 0.35) / 0.6, 0, 1)
    pitch = f * (1 - scoop * np.exp(-t / 0.12)) * (1 + depth * vib_on * np.sin(2 * np.pi * vibrato * t))
    ph = 2 * np.pi * np.cumsum(pitch) / SR
    tone = np.sin(ph) + bright * 0.5 * np.sin(2 * ph + 0.3) + bright * 0.18 * np.sin(3 * ph + 1.1)
    air = bandpass(rng.standard_normal(len(t)), f * 0.8, f * 3.5)
    air /= np.max(np.abs(air)) + 1e-9
    swell = 0.85 + 0.15 * np.sin(2 * np.pi * 0.7 * t + rng.uniform(0, 6))
    env = env_adsr(len(t), 0.09, 0.2, 0.82, min(0.45, dur * 0.4))
    # El soplo es más fuerte en el ataque.
    air_env = env * (0.6 + 0.8 * np.exp(-t / 0.15))
    return (tone * swell * env + breath * air * air_env) * 0.6


def taiko(rng, f=72, amp=1.0, dur=1.6):
    t = t_axis(dur)
    pitch = f * (1 + 0.55 * np.exp(-t / 0.03))
    body = np.sin(2 * np.pi * np.cumsum(pitch) / SR) * np.exp(-t / 0.42)
    body += 0.35 * np.sin(2 * np.pi * np.cumsum(pitch * 1.52) / SR) * np.exp(-t / 0.2)
    skin = onepole_lp(rng.standard_normal(len(t)), 900) * np.exp(-t / 0.035) * 0.8
    return amp * (body + skin) * np.clip(t / 0.002, 0, 1)


def bowl(f, rng, dur=7.0, amp=1.0):
    """Cuenco tibetano: parciales inarmónicos con batido lento."""
    t = t_axis(dur)
    x = np.zeros_like(t)
    for ratio, a, d in [(1, 1, 5.5), (2.71, 0.45, 3.2), (5.12, 0.22, 1.8), (8.3, 0.08, 0.9)]:
        beat = 1 + 0.003 * ratio
        x += a * (np.sin(2 * np.pi * f * ratio * t) + 0.6 * np.sin(2 * np.pi * f * ratio * beat * t + 1)) * np.exp(-t / d)
    x += 0.2 * onepole_lp(rng.standard_normal(len(t)), 1500) * np.exp(-t / 0.01)
    return amp * x * np.clip(t / 0.004, 0, 1) * 0.5


def pad(freqs, dur, rng, cutoff=900, motion=0.07):
    """Colchón: osciladores apenas desafinados con un respiro lento de volumen."""
    t = t_axis(dur)
    x = np.zeros_like(t)
    for f in freqs:
        for det in (-0.004, 0.0, 0.0045):
            ph = rng.uniform(0, 6.28)
            saw = sum(np.sin(2 * np.pi * f * (1 + det) * k * t + ph * k) / k for k in range(1, 6))
            x += saw * (1 + 0.35 * np.sin(2 * np.pi * motion * t + rng.uniform(0, 6.28)))
    x = onepole_lp(onepole_lp(x, cutoff), cutoff)
    return x / (len(freqs) * 3)


def bowed_metal(f, dur, rng):
    """Metal frotado: parciales inarmónicos que crecen y se van, inquietante."""
    t = t_axis(dur)
    x = np.zeros_like(t)
    for ratio, a in [(1, 1), (1.41, 0.6), (2.27, 0.4), (3.06, 0.25), (4.53, 0.12)]:
        wob = 1 + 0.002 * np.sin(2 * np.pi * (0.3 + 0.1 * ratio) * t)
        x += a * np.sin(2 * np.pi * np.cumsum(np.full_like(t, f * ratio) * wob) / SR)
    swell = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 2
    grit = bandpass(rng.standard_normal(len(t)), f * 2, f * 6) * 0.15
    return (x * 0.35 + grit) * swell


# ------------------------------------------------------------------ composición


def place(buf, x, at, gain=1.0):
    """Suma [x] desde [at]; lo que se pasa del final entra por el principio
    (loop sin costura), aunque dé más de una vuelta."""
    n = len(buf)
    s = int(SR * at) % n
    i = 0
    while i < len(x):
        take = min(len(x) - i, n - s)
        buf[s:s + take] += x[i:i + take] * gain
        i += take
        s = 0


def melody(rng, scale, start_deg, n, lo, hi):
    """Paseo por la escala con saltos chicos y alguna nota larga."""
    deg = start_deg
    out = []
    for _ in range(n):
        step = rng.choice([-2, -1, -1, 0, 1, 1, 2, 3, -3], p=[.08, .2, .12, .06, .2, .14, .1, .05, .05])
        deg = int(np.clip(deg + step, lo, hi))
        out.append(deg)
    return out


def note(scale, root, deg):
    octave, i = divmod(deg, len(scale))
    return midi(root + 12 * octave + scale[i])


def finish(mix, ir, wet=0.38):
    tail = convolve(mix, ir)
    wet_sig = tail[: len(mix)].copy()
    rest = tail[len(mix):]
    wet_sig[: len(rest)] += rest  # la cola del final suena sobre el principio
    out = mix * (1 - wet) + wet_sig * wet * 2.2
    out -= np.mean(out)
    return out / (np.max(np.abs(out)) + 1e-9)


def track_menu(L):
    rng = np.random.default_rng(11)
    buf = np.zeros(int(SR * L))
    # Colchón en D mayor pentatónico, dos acordes que respiran.
    half = L / 2
    for k, chord in enumerate([[50, 57, 62, 66], [47, 54, 59, 62]]):
        p = pad([midi(m) for m in chord], half + 4, rng, cutoff=700, motion=0.05)
        p *= env_adsr(len(p), 2.5, 0.1, 1, 3.0)
        place(buf, p, k * half - 1.5, 0.55)
    for at, f in [(0.5, midi(62)), (L * 0.5 + 0.5, midi(57))]:
        place(buf, bowl(f / 2, rng, amp=0.9), at, 0.5)
    scale = [0, 2, 4, 7, 9]
    t = 3.0
    while t < L - 2:
        deg = int(rng.integers(5, 12))
        place(buf, pluck(note(scale, 50, deg), 3.0, rng, bright=0.6), t, 0.32)
        t += float(rng.choice([1.5, 2.25, 3.0, 4.5]))
    return finish(buf, reverb_ir(3.2, 1), wet=0.45)


def track_shaolin(L):
    rng = np.random.default_rng(23)
    buf = np.zeros(int(SR * L))
    scale = [0, 2, 4, 7, 9]  # pentatónica gong sobre C
    root = 48
    drone = pad([midi(36), midi(43), midi(48)], L + 4, rng, cutoff=500, motion=0.04)
    place(buf, drone, -2, 0.35)
    # Guzheng: arpegios lentos ascendentes cada 4 compases.
    beat = 60 / 66
    for bar in range(int(L / (beat * 4))):
        at = bar * beat * 4
        base = [0, 2, 4] if bar % 4 < 2 else [3, 5, 7]
        for i, d in enumerate(base + [base[0] + 5]):
            place(buf, pluck(note(scale, root, d + 5), 3.5, rng, bright=0.8, bend=0.012 if i == 3 else 0), at + i * beat * 0.5, 0.26)
    # Dizi: frases con respiro entre ellas.
    t = beat * 8
    while t < L - beat * 6:
        phrase = melody(rng, scale, int(rng.integers(10, 13)), int(rng.integers(4, 7)), 8, 15)
        for i, d in enumerate(phrase):
            dur = float(rng.choice([1, 1, 1.5, 2, 3])) * beat
            if i == len(phrase) - 1:
                dur = 3.5 * beat
            place(buf, flute(note(scale, root, d), dur + 0.3, rng, breath=0.3, depth=0.008, bright=0.45), t, 0.42)
            t += dur
        t += float(rng.choice([4, 6, 8])) * beat
    return finish(buf, reverb_ir(2.8, 2), wet=0.4)


def track_ninja(L):
    rng = np.random.default_rng(37)
    buf = np.zeros(int(SR * L))
    scale = [0, 1, 5, 7, 8]  # in (miyako-bushi) sobre D
    root = 50
    beat = 60 / 72
    drone = pad([midi(38), midi(45)], L + 4, rng, cutoff=420, motion=0.05)
    place(buf, drone, -2, 0.32)
    # Taiko suave: golpe grave y respuesta, como un pulso que acecha.
    bars = int(L / (beat * 4))
    for bar in range(bars):
        at = bar * beat * 4
        place(buf, taiko(rng, f=68, amp=0.9), at, 0.32)
        place(buf, taiko(rng, f=82, amp=0.5, dur=0.8), at + beat * 1.5, 0.22)
        if bar % 2 == 1:
            place(buf, taiko(rng, f=95, amp=0.35, dur=0.5), at + beat * 3.0, 0.18)
            place(buf, taiko(rng, f=95, amp=0.3, dur=0.5), at + beat * 3.5, 0.15)
    # Koto: ostinato de dos notas cada dos compases.
    for bar in range(0, bars, 2):
        at = bar * beat * 4 + beat * 2
        for i, d in enumerate([5, 7, 6, 5]):
            place(buf, pluck(note(scale, root, d), 2.4, rng, bright=0.9), at + i * beat * 0.75, 0.2)
    # Shakuhachi: notas largas que entran desde abajo.
    t = beat * 6
    while t < L - beat * 8:
        phrase = melody(rng, scale, int(rng.integers(6, 9)), int(rng.integers(3, 5)), 4, 11)
        for i, d in enumerate(phrase):
            dur = float(rng.choice([2, 3, 4])) * beat
            place(
                buf,
                flute(note(scale, root, d), dur + 0.4, rng, breath=0.55, scoop=0.03, vibrato=4.4, depth=0.01, bright=0.25),
                t,
                0.45,
            )
            t += dur
        t += float(rng.choice([6, 8, 10])) * beat
    return finish(buf, reverb_ir(3.4, 3), wet=0.42)


def track_oni(L):
    rng = np.random.default_rng(53)
    buf = np.zeros(int(SR * L))
    beat = 60 / 52
    # Bordón en trítono: D y Ab bien graves.
    drone = pad([midi(26), midi(32), midi(38)], L + 4, rng, cutoff=320, motion=0.09)
    place(buf, drone, -2, 0.5)
    for bar in range(int(L / (beat * 4))):
        at = bar * beat * 4
        place(buf, taiko(rng, f=52, amp=1.0, dur=2.2), at, 0.45)
        if bar % 2 == 0:
            place(buf, taiko(rng, f=58, amp=0.6, dur=1.4), at + beat * 2.5, 0.3)
    t = beat * 2
    while t < L - 4:
        f = midi(int(rng.choice([62, 63, 68, 69, 74])))
        dur = float(rng.uniform(4.0, 7.0))
        place(buf, bowed_metal(f / 2, dur, rng), t, 0.25)
        t += dur * float(rng.uniform(0.7, 1.3))
    # Una flauta lejana y grave, como algo que quedó atrapado.
    t = beat * 10
    scale = [0, 1, 5, 6, 8]
    while t < L - beat * 8:
        for d in melody(rng, scale, 5, 3, 2, 8):
            dur = float(rng.choice([3, 4])) * beat
            place(buf, flute(note(scale, 50, d), dur + 0.4, rng, breath=0.7, scoop=0.05, vibrato=3.6, depth=0.014, bright=0.15), t, 0.28)
            t += dur
        t += 12 * beat
    return finish(buf, reverb_ir(4.5, 4, damp=3500), wet=0.5)


TRACKS = {
    'menu': (track_menu, 48.0),
    'shaolin': (track_shaolin, 58.18),  # 16 compases a 66 bpm
    'ninja': (track_ninja, 53.33),      # 16 compases a 72 bpm
    'oni': (track_oni, 55.38),          # 12 compases a 52 bpm
}


def write_m4a(name, x):
    pcm = (np.clip(x * 0.89, -1, 1) * 32767).astype('<i2')
    os.makedirs(OUT, exist_ok=True)
    dst = os.path.abspath(os.path.join(OUT, f'{name}.m4a'))
    with tempfile.TemporaryDirectory() as d:
        wav = os.path.join(d, f'{name}.wav')
        with wave.open(wav, 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        if shutil.which('afconvert'):
            subprocess.run(['afconvert', '-f', 'm4af', '-d', 'aac', '-b', '80000', wav, dst], check=True)
        else:
            subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', wav, '-c:a', 'aac', '-b:a', '80k', dst], check=True)
    print(name, os.path.getsize(dst) // 1024, 'KB')


def main():
    for name, (fn, length) in TRACKS.items():
        write_m4a(name, fn(length))


if __name__ == '__main__':
    main()
