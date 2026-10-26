"""Arma las capturas de la App Store en estilo washi: iPhone 6,9" (1320×2868) y
iPad 13" (2064×2752).

Uso:  python3 tool/compose_screenshots.py
Lee   store/screenshots/raw/en_<nombre>.png (simulador iPhone 17 Pro Max) y
      store/screenshots/raw/ipad_<nombre>.png (simulador iPad Pro 13").
Escribe store/screenshots/<idioma>/ y store/screenshots/<idioma>_ipad/, <n>_<nombre>.png
con el título arriba.
"""

import os
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.join(os.path.dirname(__file__), '..')
RAW = os.path.join(ROOT, 'store', 'screenshots', 'raw')
FONT = os.path.join(ROOT, 'assets', 'fonts', 'ShipporiMinchoB1-ExtraBold.ttf')
KANJI = os.path.join(ROOT, 'assets', 'fonts', 'YujiSyuku-Regular.ttf')
INK = (38, 30, 24)
RED = (184, 50, 42)

# (captura, kanji de fondo, título por idioma)
SHOTS = [
    ('finisher', '封', {
        'en': 'Surround the Leader.\nSeal the victory.',
        'es': 'Rodeá al Líder.\nSellá la victoria.',
    }),
    ('story', '記', {
        'en': 'Two rival schools.\nOne buried secret.',
        'es': 'Dos escuelas rivales.\nUn secreto enterrado.',
    }),
    ('initiation', '師', {
        'en': 'The Sensei guides\nyour first match.',
        'es': 'El Sensei te guía\nen tu primera partida.',
    }),
    ('stars', '星', {
        'en': '48 story battles.\nEarn every star.',
        'es': '48 batallas de historia.\nGaná cada estrella.',
    }),
    ('solo', '日', {
        'en': 'A new challenge\nevery day.',
        'es': 'Un desafío nuevo\ncada día.',
    }),
]


# Por dispositivo: lienzo, prefijo de la captura en crudo, recorte (en tablet la app
# es una columna centrada con barras negras), tamaño del título y del kanji, y dónde
# va la captura (x centrada, y arriba, ancho y alto máximos; sin alto máximo la
# captura del iPhone se sale un poco por abajo, a propósito).
DEVICES = {
    'iphone': dict(size=(1320, 2868), raw='en', crop=None, title=96, kanji=560, top=640, sw=1080, sh=None, out=''),
    'ipad': dict(size=(2064, 2752), raw='ipad', crop=(206, 0, 1858, 2752), title=104, kanji=640, top=650,
                 sw=1500, sh=2010, out='_ipad'),
}


def washi(W, H):
    rnd = random.Random(3)
    img = Image.new('RGB', (W, H))
    d = ImageDraw.Draw(img)
    top, bottom = (241, 230, 208), (224, 205, 172)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(top, bottom)))
    # Fibras del papel.
    fib = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fib)
    for _ in range(900):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        dx, dy = rnd.uniform(-40, 40), rnd.uniform(-12, 12)
        fd.line([(x, y), (x + dx, y + dy)], fill=(120, 90, 50, rnd.randint(10, 28)), width=1)
    return Image.alpha_composite(img.convert('RGBA'), fib)


def rounded(shot, radius):
    mask = Image.new('L', shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *shot.size], radius, fill=255)
    out = Image.new('RGBA', shot.size, (0, 0, 0, 0))
    out.paste(shot, (0, 0), mask)
    return out


def compose(name, glyph, title, lang, dev):
    W, H = dev['size']
    canvas = washi(W, H)
    d = ImageDraw.Draw(canvas)
    # Kanji grande y tenue detrás del título.
    k = dev['kanji']
    big = ImageFont.truetype(KANJI, k)
    layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(layer).text((W - k, 40), glyph, font=big, fill=(*RED, 26))
    canvas = Image.alpha_composite(canvas, layer)
    d = ImageDraw.Draw(canvas)
    # Sello rojo y título.
    d.rounded_rectangle([96, 190, 146, 240], 8, fill=RED)
    font = ImageFont.truetype(FONT, dev['title'])
    d.multiline_text((96, 270), title, font=font, fill=INK, spacing=26)
    # Captura con esquinas redondeadas, sombra y marco fino.
    shot = Image.open(os.path.join(RAW, f"{dev['raw']}_{name}.png")).convert('RGB')
    if dev['crop']:
        shot = shot.crop(dev['crop'])
    scale = dev['sw'] / shot.width
    if dev['sh']:
        scale = min(scale, dev['sh'] / shot.height)
    sw = int(shot.width * scale)
    shot = shot.resize((sw, int(shot.height * scale)), Image.LANCZOS)
    shot = rounded(shot, 64)
    x, y = (W - sw) // 2, dev['top']
    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([x, y + 24, x + sw, y + shot.height + 24], 64, fill=(60, 40, 20, 110))
    canvas = Image.alpha_composite(canvas, shadow.filter(ImageFilter.GaussianBlur(28)))
    canvas.paste(shot, (x, y), shot)
    ImageDraw.Draw(canvas).rounded_rectangle([x, y, x + sw, y + shot.height], 64, outline=(120, 90, 50), width=3)
    return canvas.convert('RGB')


def main():
    # Las capturas en crudo están en inglés: los títulos en español piden capturas en español.
    for lang in ('en',):
        for dev in DEVICES.values():
            out = os.path.join(ROOT, 'store', 'screenshots', lang + dev['out'])
            os.makedirs(out, exist_ok=True)
            for i, (name, glyph, titles) in enumerate(SHOTS, 1):
                compose(name, glyph, titles[lang], lang, dev).save(os.path.join(out, f'{i}_{name}.png'))
            print('ok →', os.path.abspath(out))


if __name__ == '__main__':
    main()
