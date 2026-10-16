"""Prepara una ilustración de ficha generada (PNG grande con alfa) para el juego.

- Limpia el alfa: borra la basura casi invisible del recorte y deja la figura opaca.
- Recorta al contenido y lo centra en un lienzo cuadrado de 512 px.
- Guarda `assets/pieces/<nombre>.webp` (liviano para celular) y una vista previa
  dentro del hexágono, como la dibuja el juego, en `build/piece_previews/`.
- Si el origen es un PNG dentro de `assets/pieces/`, lo borra (no debe ir al bundle).

Uso:  python3 tool/prep_piece_art.py origen.png shaolin_monk [--fill 0.88]
"""
import argparse
import math
import os

import numpy as np
from PIL import Image, ImageDraw

SIZE = 512
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def clean(src: str, fill: float) -> Image.Image:
    im = np.array(Image.open(src).convert('RGBA')).astype(np.int32)
    a = im[..., 3]
    a[a < 12] = 0
    a[a >= 235] = 255
    im[..., 3] = a
    im[a == 0, :3] = 0
    img = Image.fromarray(im.astype(np.uint8), 'RGBA')
    ys, xs = np.where(a > 0)
    img = img.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    k = fill * SIZE / max(img.size)
    img = img.resize((round(img.width * k), round(img.height * k)), Image.LANCZOS)
    out = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    out.paste(img, ((SIZE - img.width) // 2, (SIZE - img.height) // 2), img)
    return out


def _hex(c: float, r: float):
    return [(c + r * math.cos(math.radians(60 * i - 30)), c + r * math.sin(math.radians(60 * i - 30))) for i in range(6)]


def preview(art: Image.Image, size: int, shaolin: bool, leader: bool) -> Image.Image:
    """Aproxima `PieceRenderer`: cara de piedra, arte recortado, borde y anillo de líder."""
    r, c = size * 0.45, size / 2
    face = (240, 244, 236, 255) if shaolin else (40, 38, 42, 255)
    edge = (47, 158, 110, 255) if shaolin else (192, 64, 79, 255)
    base = Image.new('RGBA', (size, size), (205, 185, 140, 255))
    ImageDraw.Draw(base).polygon(_hex(c, r), fill=face)
    scaled = art.resize((round(1.6 * r), round(1.6 * r)), Image.LANCZOS)
    layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    layer.paste(scaled, (round(c - 0.8 * r), round(c - 0.8 * r)), scaled)
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).polygon(_hex(c, r * 0.86), fill=255)
    alpha = Image.fromarray(np.minimum(np.array(layer.split()[3]), np.array(mask)))
    base.paste(layer, (0, 0), alpha)
    d = ImageDraw.Draw(base)
    d.line(_hex(c, r) + [_hex(c, r)[0]], fill=edge, width=max(2, round(r * 0.09)))
    if leader:
        d.line(_hex(c, r * 0.8) + [_hex(c, r * 0.8)[0]], fill=(168, 122, 34, 255), width=max(1, round(r * 0.06)))
    return base


def main():
    p = argparse.ArgumentParser()
    p.add_argument('src')
    p.add_argument('name', help='<facción>_<tipo>, p. ej. shaolin_monk')
    p.add_argument('--fill', type=float, default=0.88, help='lado mayor de la figura / lienzo')
    args = p.parse_args()

    art = clean(args.src, args.fill)
    dst = os.path.join(ROOT, 'assets', 'pieces', f'{args.name}.webp')
    art.save(dst, 'WEBP', quality=88, method=6)
    print(f'{dst}: {os.path.getsize(dst) // 1024} KB')

    shaolin = args.name.startswith('shaolin')
    leader = args.name in ('shaolin_monk', 'ninja_shogun')
    sheet = Image.new('RGBA', (390, 300), (205, 185, 140, 255))
    sheet.paste(preview(art, 300, shaolin, leader), (0, 0))
    sheet.paste(preview(art, 60, shaolin, leader), (315, 120))
    out_dir = os.path.join(ROOT, 'build', 'piece_previews')
    os.makedirs(out_dir, exist_ok=True)
    sheet.save(os.path.join(out_dir, f'{args.name}.png'))

    pieces_dir = os.path.join(ROOT, 'assets', 'pieces')
    src = os.path.abspath(args.src)
    if src.endswith('.png') and os.path.dirname(src) == pieces_dir:
        os.remove(src)
        print(f'borrado {src}')


if __name__ == '__main__':
    main()
