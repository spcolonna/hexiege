#!/usr/bin/env python3
"""Genera el guion de las viñetas desde docs/lore.md.

docs/lore.md es la fuente del texto en español; tool/story_tr.json tiene las
traducciones en el mismo orden ({"s1.pre": {"en": [...], "zh": [...]}}).
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

LINE = re.compile(r'^(?P<who>[^:*]+?)(?:\s\*\((?P<dir>[^)]+)\)\*)?:\s(?P<text>.+)$')


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
        if body.startswith('*') and body.endswith('*') and not body.startswith('**'):
            beat = ('moment', None, body.strip('*').strip())
        else:
            m = LINE.match(body)
            if not m or m.group('who') not in WHO:
                sys.exit(f'línea sin hablante conocido: {body}')
            who, d, text = WHO[m.group('who')], m.group('dir'), m.group('text').strip()
            if who == 'narrator':
                kind = 'narrate'
            elif d == 'pensando':
                kind = 'think'
            else:
                kind = 'say'
                if d:
                    text = f'*({d})* {text}'
            beat = (kind, who, text)
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
            for _, who, text in beats:
                print(f'  {who or "-"}: {text}')
        return
    tr = json.loads(TR.read_text()) if TR.exists() else {}
    batch = OrderedDict()
    missing = []
    for sid, beats in scenes.items():
        t = tr.get(sid, {})
        for lang in ('en', 'zh'):
            if len(t.get(lang, [])) != len(beats):
                missing.append(f'{sid}.{lang}: {len(t.get(lang, []))}/{len(beats)}')
        for i, (_, _, text) in enumerate(beats):
            batch[f'story.{sid}.{i}'] = {
                'es': text,
                'en': (t.get('en') or [None] * len(beats))[i] if len(t.get('en', [])) == len(beats) else text,
                'zh': (t.get('zh') or [None] * len(beats))[i] if len(t.get('zh', [])) == len(beats) else text,
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
        for kind, who, _ in beats:
            dart.append(f'    Beat.{kind}({"" if who is None else "Who." + who}),')
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
