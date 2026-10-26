#!/usr/bin/env python3
"""Genera el guion de las viñetas desde docs/lore.md.

docs/lore.md es la fuente del texto en español; tool/story_tr.json tiene las
traducciones de las líneas con texto, en el mismo orden ({"s1.pre": {"en": [...], "zh": [...], "ja": [...]}}).

Puesta en escena, entre corchetes y separada por "·":
  - [plano .8,.4 x1.6 lento]        pausa muda: la cámara va a ese punto del fondo
  - Ren [entra izq · temblor]: …   la indicación acompaña la línea
  - *Noche. Las celdas.* [plano …]
Indicaciones: plano X,Y [xZOOM] [lento] · entra QUIÉN [izq|der|centro|0..1] [humo|sombra|corre]
· sale QUIÉN [humo] · vacía · temblor · destello · humo · latido · oscuro · niebla
· onom CLAVE (texto en onom.CLAVE) · arte NOMBRE · lugar PLACE · página · off (habla fuera de cuadro)
Produce lib/story/script.g.dart (quién habla y de qué tipo es cada mensaje) y
suma las claves story.<escena>.<n> a tool/i18n_strings.json.

Uso:
  python3 tool/gen_story.py           # genera todo
  python3 tool/gen_story.py --list    # muestra las escenas y sus líneas en español
"""
import json
import re
import subprocess
import sys
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LORE = ROOT / 'docs' / 'lore.md'
TR = ROOT / 'tool' / 'story_tr.json'
OUT = ROOT / 'lib' / 'story' / 'script.g.dart'

WHO = {
    'Narración': 'narrator',
    'Ren': 'ren',
    'Aya': 'aya',
    'Abad': 'abbot',
    'Kage': 'kage',
    'Mei': 'mei',
    'Tao': 'tao',
    'Gon': 'gon',
    'Kuro': 'kuro',
    'Jubei': 'jubei',
    'Zorra Blanca': 'fox',
    'Oni': 'oni',
    'Ninja': 'ninja',
    'Explorador': 'scout',
    'Novicio': 'novice',
    'Guardia': 'guard',
    'Kunoichi': 'kunoichi',
}

LINE = re.compile(r'^(?P<who>[^:*\[]+?)(?:\s\[(?P<cue>[^\]]+)\])?(?:\s\*\((?P<dir>[^)]+)\)\*)?:\s(?P<text>.+)$')
MOMENT = re.compile(r'^\*(?P<text>[^*].*?)\*(?:\s\[(?P<cue>[^\]]+)\])?$')
PAUSE = re.compile(r'^\[(?P<cue>[^\]]+)\]$')

FX = {'temblor': 'shake', 'destello': 'flash', 'humo': 'smoke', 'latido': 'pulse', 'oscuro': 'dark', 'niebla': 'fog'}
SPOT = {'izq': 0.27, 'der': 0.73, 'centro': 0.5}
STYLES = ('humo', 'sombra', 'corre', 'ya')
PLACES = None


def places():
    global PLACES
    if PLACES is None:
        src = (ROOT / 'lib' / 'story' / 'staging.dart').read_text()
        PLACES = set(re.findall(r'^  (\w+)\(\'bg_', src, re.M))
    return PLACES


def who_of(words, ctx, speaker=None):
    """(enum del personaje, palabras que siguen): acepta el nombre del guion o el del enum.
    Sin nombre, quien dice la línea."""
    for n in range(len(words), 0, -1):
        name = ' '.join(words[:n])
        if name in WHO:
            return WHO[name], words[n:]
        if name in WHO.values():
            return name, words[n:]
    if speaker:
        return speaker, words
    sys.exit(f'{ctx}: personaje desconocido en «{" ".join(words)}»')


def num(s):
    return float(s) if not s.startswith('.') else float('0' + s)


def cues(src, ctx, speaker=None):
    """Las indicaciones entre corchetes, como constructores de Cue."""
    out = []
    for tok in [t.strip() for t in src.split('·') if t.strip()]:
        w = tok.split()
        head, rest = w[0], w[1:]
        if head == 'plano':
            x, y = (num(v) for v in rest[0].split(','))
            zoom = next((num(v[1:]) for v in rest[1:] if v.startswith('x')), 1.0)
            slow = ', slow: true' if 'lento' in rest else ''
            out.append(f'Cue.cam({x}, {y}, {zoom}{slow})')
        elif head in ('entra', 'sale'):
            who, more = who_of(rest, ctx, speaker)
            style = next((m for m in more if m in STYLES), None)
            st = f", '{style}'" if style else ''
            if head == 'sale':
                out.append(f'Cue.exit(Who.{who}{st})')
                continue
            spot = next((SPOT.get(m, None) if m in SPOT else num(m) for m in more if m in SPOT or re.match(r'^[\d.]+$', m)), None)
            if spot is None:
                sys.exit(f'{ctx}: «{tok}» sin lugar (izq, der, centro o 0..1)')
            out.append(f'Cue.enter(Who.{who}, {spot}{st})')
        elif head in ('vacía', 'vacia'):
            out.append('Cue.clear()')
        elif head in FX:
            out.append(f'Cue.fx(Fx.{FX[head]})')
        elif head == 'onom':
            out.append(f"Cue.onom('{rest[0]}')")
        elif head == 'arte':
            out.append(f"Cue.art('{rest[0]}')")
        elif head == 'lugar':
            if rest[0] not in places():
                sys.exit(f'{ctx}: lugar desconocido «{rest[0]}»')
            out.append(f'Cue.place(Place.{rest[0]})')
        elif head == 'off':
            out.append('Cue.voice()')
        elif head in ('página', 'pagina'):
            out.append('Cue.page()')
        else:
            sys.exit(f'{ctx}: indicación desconocida «{tok}»')
    return out


def parse():
    """{escena: [(tipo, quién, texto)]}, en el orden del guion."""
    scenes = OrderedDict()
    prologue = []
    stage = part = None
    in_finale = False
    for raw in LORE.read_text().splitlines():
        line = raw.strip()
        if line.startswith('## 6.'):
            in_finale, stage, part = True, None, None
            continue
        if line.startswith('## '):
            in_finale, stage, part = False, None, None
            continue
        m = re.match(r'^#### ([snf]\d+) ·', line)
        if m:
            stage, part = m.group(1), None
            continue
        if line.startswith('**Antes**'):
            part = 'pre'
            continue
        if line.startswith('**Después'):
            part = 'post'
            continue
        if not line.startswith('- '):
            continue
        if not (stage and part) and not (in_finale and stage is None):
            continue
        body = line[2:].strip()
        if '→' in body or body.startswith('*Tarjeta') or body.startswith('*(') or body.startswith('*Se abre'):
            continue
        ctx = f'{stage}.{part}' if stage else 'prólogo'
        mm, mp = MOMENT.match(body), PAUSE.match(body)
        if mp:
            beat = ('pause', None, '', cues(mp.group('cue'), ctx))
        elif mm and not body.startswith('**'):
            beat = ('moment', None, mm.group('text').strip(), cues(mm.group('cue') or '', ctx))
        else:
            m = LINE.match(body)
            if not m or m.group('who') not in WHO:
                sys.exit(f'línea sin hablante conocido: {body}')
            who, d, text = WHO[m.group('who')], m.group('dir'), m.group('text').strip()
            cs = cues(m.group('cue') or '', ctx, WHO[m.group('who')])
            if who == 'narrator':
                kind = 'narrate'
            elif d == 'pensando':
                kind = 'think'
            else:
                kind = 'say'
                if d:
                    text = f'*({d})* {text}'
            beat = (kind, who, text, cs)
        if in_finale and stage is None:
            prologue.append(beat)
            continue
        if stage is None or part is None:
            continue
        scenes.setdefault(f'{stage}.{part}', []).append(beat)
    scenes['f1.pre'] = prologue + scenes['f1.pre']
    return scenes


def main():
    scenes = parse()
    if '--list' in sys.argv:
        for sid, beats in scenes.items():
            print(f'## {sid} ({len(beats)})')
            for kind, who, text, cs in beats:
                print(f'  {who or "-"}: {text or "[" + ", ".join(cs) + "]"}')
        return
    tr = json.loads(TR.read_text()) if TR.exists() else {}
    batch = OrderedDict()
    missing = []
    for sid, beats in scenes.items():
        t = tr.get(sid, {})
        said = [i for i, b in enumerate(beats) if b[0] != 'pause']
        ok = {}
        for lang in ('en', 'zh', 'ja'):
            ok[lang] = len(t.get(lang, [])) == len(said)
            if not ok[lang]:
                missing.append(f'{sid}.{lang}: {len(t.get(lang, []))}/{len(said)}')
        for n, i in enumerate(said):
            text = beats[i][2]
            batch[f'story.{sid}.{i}'] = {
                'es': text,
                'en': t['en'][n] if ok['en'] else text,
                'zh': t['zh'][n] if ok['zh'] else text,
                'ja': t['ja'][n] if ok['ja'] else text,
            }
    if missing:
        print('Faltan traducciones (se usa el español):\n  ' + '\n  '.join(missing))

    dart = [
        '// GENERADO por tool/gen_story.py desde docs/lore.md. No editar a mano.',
        "part of 'script.dart';",
        '',
        'const _script = <String, List<Beat>>{',
    ]
    for sid, beats in scenes.items():
        dart.append(f"  '{sid}': [")
        for kind, who, _, cs in beats:
            args = [] if who is None else ['Who.' + who]
            if cs:
                args.append('[' + ', '.join(cs) + ']')
            dart.append(f'    Beat.{kind}({", ".join(args)}),')
        dart.append('  ],')
    dart.append('};')
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text('\n'.join(dart) + '\n')
    subprocess.run(['dart', 'format', '-l', '120', str(OUT)], check=True, capture_output=True)

    tmp = ROOT / 'build' / 'story_batch.json'
    tmp.parent.mkdir(exist_ok=True)
    tmp.write_text(json.dumps(batch, ensure_ascii=False, indent=1))
    # Limpia claves de escenas que ya no existen y regenera.
    src = ROOT / 'tool' / 'i18n_strings.json'
    data = json.loads(src.read_text(), object_pairs_hook=OrderedDict)
    for k in [k for k in data if k.startswith('story.') and re.match(r'^story\.[snf]\d+\.(pre|post)\.\d+$', k) and k not in batch]:
        del data[k]
    src.write_text(json.dumps(data, ensure_ascii=False, indent=1) + '\n')
    subprocess.run([sys.executable, str(ROOT / 'tool' / 'gen_i18n.py'), '--add', str(tmp)], check=True)
    print(f'{len(scenes)} escenas, {len(batch)} líneas')


if __name__ == '__main__':
    main()
