"""Guarda tool/story_tr.json en su formato compacto: un idioma por línea."""
import json
from pathlib import Path

TR = Path(__file__).resolve().parent / 'story_tr.json'


def dump(tr):
    out = ['{']
    items = list(tr.items())
    for k, (sid, t) in enumerate(items):
        out.append(f' {json.dumps(sid)}: {{')
        langs = list(t.items())
        for j, (lang, lines) in enumerate(langs):
            comma = ',' if j < len(langs) - 1 else ''
            out.append(f'  {json.dumps(lang)}: {json.dumps(lines, ensure_ascii=False)}{comma}')
        out.append(' }' + (',' if k < len(items) - 1 else ''))
    out.append('}')
    TR.write_text('\n'.join(out) + '\n')


def set_scene(sid, en, zh, ja):
    tr = json.loads(TR.read_text())
    tr[sid] = {'en': en, 'zh': zh, 'ja': ja}
    dump(tr)


if __name__ == '__main__':
    dump(json.loads(TR.read_text()))
