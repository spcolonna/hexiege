"""Genera los efectos de sonido de Hexiege por síntesis (sin assets de terceros).

Uso:  python3 tool/gen_sfx.py      → escribe assets/sfx/*.wav

Todo es procedural: golpes de piedra = transitorio de ruido + parciales amortiguados
(los graves dan "peso", los medios hacen que se escuche en parlantes de teléfono).
"""

import os
import wave

import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sfx')


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


def write(name, x, peak=0.89):
    x = fade(x.astype(np.float64))
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    data = (x * 32767).astype('<i2').tobytes()
    with wave.open(os.path.join(OUT, f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data)


def stone_thud(seed, weight=1.0, pitch=1.0, dur=0.45):
    """Ficha de piedra que cae sobre la mesa: boom grave + cuerpo + click."""
    rng = np.random.default_rng(seed)
    t = t_axis(dur)
    p = pitch * rng.uniform(0.95, 1.05)
    x = partial(t, 58 * p, 0.16 * weight, 1.0 * weight, drop=0.6, drop_time=0.025)
    x += partial(t, 132 * p, 0.10 * weight, 0.9, drop=0.35)
    x += partial(t, 247 * p, 0.06, 0.55, drop=0.2)
    x += partial(t, 523 * p * rng.uniform(0.98, 1.02), 0.035, 0.30)
    x += partial(t, 1170 * p * rng.uniform(0.97, 1.03), 0.018, 0.18)
    click = highpass(noise_burst(t, 0.004, rng), 1800) * 0.9
    body_noise = lowpass(noise_burst(t, 0.035, rng), 900) * 1.4
    return x + click + body_noise


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


def turn_knock():
    """Dos golpes de bloque de madera: 'tu turno'."""
    t = t_axis(0.35)
    x = partial(t, 820, 0.03, 0.8) + partial(t, 1640, 0.015, 0.3)
    s = int(SR * 0.11)
    x[s:] += (partial(t[: len(t) - s], 1090, 0.035, 0.9) + partial(t[: len(t) - s], 2180, 0.015, 0.3))
    return x


def main():
    os.makedirs(OUT, exist_ok=True)
    for i in range(3):
        write(f'place_{i}', stone_thud(100 + i, weight=1.25, pitch=0.92))
        write(f'land_{i}', stone_thud(200 + i, weight=0.9, pitch=1.05, dur=0.35), peak=0.8)
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
    write('turn', turn_knock(), peak=0.5)
    print('ok →', os.path.abspath(OUT))


if __name__ == '__main__':
    main()
