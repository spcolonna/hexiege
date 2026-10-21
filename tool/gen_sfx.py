"""Genera los efectos de sonido de Hexiege por síntesis (sin assets de terceros).

Uso:  python3 tool/gen_sfx.py               → escribe assets/sfx/*.wav
      python3 tool/gen_sfx.py --candidates  → alternativas en tool/sfx_candidates/

Todo es procedural: golpes de piedra = transitorio de ruido + parciales amortiguados
(los graves dan "peso", los medios hacen que se escuche en parlantes de teléfono).
"""

import os
import sys
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sfx')
# Alternativas para comparar (no se bundlean): `python3 tool/gen_sfx.py --candidates`
CANDIDATES = os.path.join(os.path.dirname(__file__), 'sfx_candidates')

# Variante que va a assets/sfx/. Para cambiar: editar la letra y volver a correr el script.
TURN_VARIANT = 'b'    # a = cuenco, b = gong chico, c = cuenco doble
# Fichas: a–d = mármol (a equilibrado, b brillante, c cuerpo, d grave);
#         h–j = dominó (h seco, i con rebote, j ficha más gruesa y grave)
MARBLE_VARIANT = 'j'


def t_axis(dur):
    return np.arange(int(SR * dur)) / SR


def lowpass(x, cutoff):
    a = np.exp(-2 * np.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def partial(t, f, decay, amp=1.0, drop=0.0, drop_time=0.03, phase=0.0):
    """Senoidal amortiguada; `drop` = caída de pitch inicial (impacto de material)."""
    freq = f * (1 + drop * np.exp(-t / drop_time))
    ph = 2 * np.pi * np.cumsum(freq) / SR + phase
    return amp * np.sin(ph) * np.exp(-t / decay)


def noise_burst(t, decay, rng, amp=1.0):
    return amp * rng.standard_normal(len(t)) * np.exp(-t / decay)


def fade(x, ms=4):
    n = int(SR * ms / 1000)
    x[-n:] *= np.linspace(1, 0, n)
    return x


def write(name, x, peak=0.89, out=OUT):
    x = fade(x.astype(np.float64))
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    data = (x * 32767).astype('<i2').tobytes()
    with wave.open(os.path.join(out, f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


# Parciales inarmónicos de mármol: (frecuencia, decay, amplitud) por variante.
MARBLE = {
    'a': dict(modes=[(900, 0.11, 1.0), (1610, 0.075, 0.7), (2720, 0.05, 0.45), (4100, 0.035, 0.28)],
              click=0.9, body=0.35, noise=0.15),
    'b': dict(modes=[(1050, 0.08, 0.9), (1880, 0.055, 0.75), (3150, 0.04, 0.5), (4700, 0.025, 0.35)],
              click=1.2, body=0.2, noise=0.1),
    'c': dict(modes=[(780, 0.12, 1.0), (1420, 0.085, 0.6), (2450, 0.055, 0.38), (3900, 0.035, 0.2)],
              click=0.7, body=0.55, noise=0.2),
    # Bloque de mármol más grueso: parciales una sexta más abajo, clic suave y golpe grave.
    'd': dict(modes=[(560, 0.13, 1.0), (1010, 0.09, 0.62), (1720, 0.055, 0.34), (2650, 0.035, 0.16)],
              click=0.45, click_hp=2000, body=0.8, body_f=105, body_decay=0.045, noise=0.12),
}


def marble_tap(seed, variant='a', weight=1.0, pitch=1.0, dur=0.3):
    """Ficha de mármol pulido apoyándose sobre piedra: click brillante + parciales inarmónicos."""
    v = MARBLE[variant]
    rng = np.random.default_rng(seed)
    t = t_axis(dur)
    p = pitch * rng.uniform(0.95, 1.05)
    x = np.zeros_like(t)
    for f, d, a in v['modes']:
        x += partial(t, f * p * rng.uniform(0.98, 1.02), d * weight, a, phase=rng.uniform(0, 2 * np.pi))
    x += partial(t, v.get('body_f', 150) * p, v.get('body_decay', 0.03) * weight, v['body'] * weight, drop=0.3, drop_time=0.01)
    x += highpass(noise_burst(t, 0.0025, rng), v.get('click_hp', 3000)) * v['click']
    x += lowpass(noise_burst(t, 0.015, rng), 1500) * v['noise'] * weight
    return x


# Fichas de dominó chocando. Nada de senoidales puras (suenan a lata): un golpe de
# ruido excita resonadores de Q bajo, que dan el "toc" opaco de hueso/resina.
# modes = (frecuencia, Q, ganancia); Q más alto = más tono, más bajo = más seco.
DOMINO = {
    'h': dict(modes=[(1150, 12, 0.7), (2100, 18, 1.0), (3400, 14, 0.45), (5000, 10, 0.15)],
              knock=(320, 4, 0.8), bounce=None),
    'i': dict(modes=[(1150, 12, 0.7), (2100, 18, 1.0), (3400, 14, 0.45), (5000, 10, 0.15)],
              knock=(320, 4, 0.8), bounce=(0.03, 0.3)),
    'j': dict(modes=[(850, 12, 0.8), (1600, 16, 1.0), (2700, 12, 0.4), (4100, 9, 0.12)],
              knock=(240, 4, 1.1), bounce=None),
}


def resonate(x, f, q):
    from scipy.signal import iirpeak, lfilter
    b, a = iirpeak(min(f, SR / 2 - 100), q, fs=SR)
    return lfilter(b, a, x)


def domino_clack(seed, variant='h', weight=1.0, pitch=1.0, dur=0.14):
    """Ficha contra ficha, como dos dominós: 'toc' corto, opaco y sin cola que resuene."""
    v = DOMINO[variant]
    rng = np.random.default_rng(seed)
    t = t_axis(dur)
    p = pitch * rng.uniform(0.95, 1.05)

    def hit(tt, amp):
        exc = noise_burst(tt, 0.002 * weight, rng)
        exc[:2] += 1.0  # impulso del choque
        x = np.zeros_like(tt)
        for f, q, g in v['modes']:
            x += resonate(exc, f * p * rng.uniform(0.97, 1.03), q) * g
        kf, kq, kg = v['knock']
        x += resonate(exc, kf * p, kq) * kg * weight
        return lowpass(x, 7000) * amp

    x = hit(t, 1.0)
    if v['bounce']:
        at, amp = v['bounce']
        s = int(SR * at * rng.uniform(0.85, 1.15))
        x[s:] += hit(t[: len(t) - s], amp)
    return x


def stone_clack(seed, pitch=1.0):
    """Piedra sobre piedra (apilar): más agudo e inarmónico."""
    rng = np.random.default_rng(seed)
    t = t_axis(0.32)
    p = pitch * rng.uniform(0.96, 1.04)
    x = partial(t, 96 * p, 0.09, 0.7, drop=0.4)
    for f, d, a in [(1510, 0.05, 0.5), (2380, 0.035, 0.38), (3460, 0.022, 0.25), (780, 0.07, 0.4)]:
        x += partial(t, f * p * rng.uniform(0.98, 1.02), d, a)
    x += highpass(noise_burst(t, 0.003, rng), 2500) * 1.0
    return x


def lift(seed):
    """Levantar la ficha: roce suave + pequeño 'tock' de despegue."""
    rng = np.random.default_rng(seed)
    t = t_axis(0.16)
    env = np.sin(np.pi * np.clip(t / 0.16, 0, 1)) ** 2
    scrape = lowpass(rng.standard_normal(len(t)), 1400) * env * 0.5
    tock = partial(t, 680, 0.012, 0.25) + partial(t, 1400, 0.008, 0.12)
    return scrape + tock


def tap(seed, f=1900):
    rng = np.random.default_rng(seed)
    t = t_axis(0.08)
    return partial(t, f, 0.012, 1.0) + partial(t, f * 1.5, 0.008, 0.4) + highpass(noise_burst(t, 0.002, rng), 3000) * 0.5


def chime(base=660, decay=0.9, dur=1.3):
    t = t_axis(dur)
    x = np.zeros_like(t)
    for i, (r, a) in enumerate([(1, 1), (1.5, 0.55), (2.0, 0.45), (3.01, 0.22), (4.2, 0.12)]):
        start = int(SR * 0.045 * i)
        seg = partial(t[: len(t) - start], base * r, decay / (1 + 0.3 * i), a)
        seg *= 1 + 0.15 * np.sin(2 * np.pi * 5.5 * t[: len(seg)])  # brillo
        x[start:] += seg
    return x


def frost():
    rng = np.random.default_rng(7)
    t = t_axis(0.7)
    x = np.zeros_like(t)
    for i, f in enumerate([2350, 3120, 3950, 4700, 5600]):
        start = int(SR * 0.03 * i)
        x[start:] += partial(t[: len(t) - start], f * rng.uniform(0.99, 1.01), 0.18, 0.5)
    x += highpass(rng.standard_normal(len(t)), 5000) * np.exp(-t / 0.08) * 0.4
    return x


def stamp():
    """Sello de sombra: golpe seco y apagado + papel."""
    rng = np.random.default_rng(11)
    t = t_axis(0.4)
    x = partial(t, 72, 0.12, 1.0, drop=0.8, drop_time=0.02) + partial(t, 160, 0.06, 0.6)
    x += lowpass(noise_burst(t, 0.05, rng), 2500) * 1.2
    return x


def gong(base=98, decay=2.2, dur=3.2, bright=1.0):
    t = t_axis(dur)
    x = np.zeros_like(t)
    for r, a in [(1, 1), (1.47, 0.7 * bright), (2.09, 0.5 * bright), (2.56, 0.35), (3.39, 0.25 * bright), (4.18, 0.15)]:
        x += partial(t, base * r, decay * (1.15 - r * 0.12), a)
        x += partial(t, base * r * 1.004, decay * (1.1 - r * 0.12), a * 0.5)  # batido
    rng = np.random.default_rng(3)
    x += lowpass(noise_burst(t, 0.02, rng), 1200) * 0.8
    attack = np.clip(t / 0.006, 0, 1)
    return x * attack


def pop():
    t = t_axis(0.14)
    f = 380 + 700 * (1 - np.exp(-t / 0.03))
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.04)


def turn_chime(variant='b'):
    """Aviso de turno: gong/cuenco grave y cálido, ataque blando, nada por encima de ~2 kHz."""
    t = t_axis(0.75)
    rng = np.random.default_rng(5)
    if variant == 'a':    # cuenco: fundamental + parciales de cuenco (2.7x, 5.1x) muy suaves
        modes = [(200, 0.3, 1.0), (200 * 2.71, 0.18, 0.25), (200 * 5.1, 0.1, 0.07)]
        hits = [(0.0, 1.0)]
    elif variant == 'b':  # gong chico: parciales inarmónicos de gong con batido
        modes = [(190, 0.28, 1.0), (190 * 1.47, 0.22, 0.4), (190 * 2.09, 0.16, 0.22), (190 * 2.56, 0.12, 0.12)]
        hits = [(0.0, 1.0)]
    else:                 # cuenco doble: dos toques suaves, el segundo una cuarta arriba
        modes = [(180, 0.22, 1.0), (180 * 2.71, 0.12, 0.2)]
        hits = [(0.0, 0.85), (0.13, 1.0)]
    x = np.zeros_like(t)
    for k, (at, amp) in enumerate(hits):
        s = int(SR * at)
        tt = t[: len(t) - s]
        r = 1.335 if k == 1 else 1.0
        for f, d, a in modes:
            x[s:] += partial(tt, f * r, d, a * amp)
            x[s:] += partial(tt, f * r * 1.005, d * 0.9, a * amp * 0.35)  # batido
        x[s:] += lowpass(noise_burst(tt, 0.01, rng), 600) * 0.15 * amp
    attack = np.clip(t / 0.018, 0, 1) ** 2
    return lowpass(x * attack, 2000)


def heartbeat():
    """Latido grave (lub-dub) para el Líder en peligro: fundamental para auriculares
    y armónicos medios para que se sienta en el parlante del teléfono."""
    t = t_axis(0.62)
    x = np.zeros_like(t)
    for at, amp, f in [(0.0, 1.0, 62), (0.2, 0.72, 54)]:
        s = int(SR * at)
        tt = t[: len(t) - s]
        x[s:] += partial(tt, f, 0.11, amp, drop=0.6, drop_time=0.02)
        x[s:] += partial(tt, f * 2.02, 0.07, amp * 0.55, drop=0.4, drop_time=0.02)
        x[s:] += partial(tt, f * 3.1, 0.04, amp * 0.22)
    attack = np.clip(t / 0.004, 0, 1)
    return fade(lowpass(x * attack, 900), ms=20)


def write_stones(variant, out):
    for i in range(3):
        if variant in DOMINO:
            write(f'place_{i}', domino_clack(100 + i, variant, weight=1.15, pitch=0.95), out=out)
            write(f'land_{i}', domino_clack(200 + i, variant, weight=0.85, pitch=1.06, dur=0.1), peak=0.8, out=out)
        else:
            write(f'place_{i}', marble_tap(100 + i, variant, weight=1.25, pitch=0.9), out=out)
            write(f'land_{i}', marble_tap(200 + i, variant, weight=0.85, pitch=1.06, dur=0.22), peak=0.8, out=out)


def candidates():
    os.makedirs(CANDIDATES, exist_ok=True)
    for v in 'abcdhij':
        if v in 'abc':
            write(f'turn_{v}', turn_chime(v), peak=0.45, out=CANDIDATES)
        d = os.path.join(CANDIDATES, f'marble_{v}' if v in MARBLE else f'domino_{v}')
        os.makedirs(d, exist_ok=True)
        write_stones(v, d)
    print('ok →', os.path.abspath(CANDIDATES))


def main():
    os.makedirs(OUT, exist_ok=True)
    write_stones(MARBLE_VARIANT, OUT)
    for i in range(3):
        write(f'stack_{i}', stone_clack(300 + i), peak=0.8)
        write(f'lift_{i}', lift(400 + i), peak=0.45)
    write('select', tap(1), peak=0.4)
    write('tick', tap(2, f=1250), peak=0.35)
    write('ability', chime(), peak=0.6)
    write('frost', frost(), peak=0.5)
    write('stamp', stamp(), peak=0.8)
    write('victory', gong(), peak=0.85)
    write('defeat', gong(base=73, decay=1.6, bright=0.45), peak=0.75)
    write('emote', pop(), peak=0.5)
    write('turn', turn_chime(TURN_VARIANT), peak=0.45)
    write('heartbeat', heartbeat(), peak=0.9)
    print('ok →', os.path.abspath(OUT))


if __name__ == '__main__':
    candidates() if '--candidates' in sys.argv else main()
