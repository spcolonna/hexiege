# Hexiege — Prompts de arte del modo historia

Dos bloques para pegar tal cual en el generador. Mismo estilo que los avatares actuales
(tinta sumi-e sobre papel de arroz, un color de acento), para que las viñetas y los retratos
del juego se vean como una sola cosa.

- Retratos → `assets/avatars/avatar_<id>.png` (se convierten a `.webp` al integrarlos).
- Escenas → `assets/story/<id>.png`.

Hasta que existan, el juego muestra el retrato del personaje o un kanji en su lugar.

## Bloque 1 — Retratos (3)

```
Generate exactly 3 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL three images:
Create a SQUARE image (1:1, 1024×1024), fully opaque.
PURPOSE: A character portrait for the story mode of a mobile strategy game about Shaolin monks versus ninja clans. The game crops it into a CIRCLE and shows it small (about 64×64 pixels) next to dialogue, so the face must be large, centered and readable at that size.
STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.
COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).
DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.

Image 1 — avatar_abbot:
SUBJECT: An old Shaolin abbot, about seventy, shaved head, long white eyebrows and a thin white beard, deep wrinkles, calm but proud and secretive expression, eyes slightly narrowed. Saffron and dark red robes, a string of large jade prayer beads. Accent color: jade green.

Image 2 — avatar_shogun:
SUBJECT: The Grand Shogun of a ninja clan, a stern man in his fifties, short greying beard, a scar across one eyebrow, black lacquered samurai helmet with a small crescent crest, dark armor with crimson cords. Hard but not cruel expression, tired eyes. Accent color: crimson.

Image 3 — avatar_ashoni:
SUBJECT: An ancient demon made of ash and embers: a horned oni face whose skin is cracked grey ash with glowing orange-red fire inside the cracks, burning eyes, sharp fangs, smoke drifting from its horns. Terrifying but readable. Accent color: ember orange.
```

## Bloque 2 — Escenas de las viñetas (12)

```
Generate exactly 12 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL twelve images:
Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.
PURPOSE: A comic-like story panel for a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is shown on a phone inside a dialogue, about 360 pixels wide, so it needs one clear focal point and a strong silhouette.
STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist. Not cartoonish.
CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask over the lower face, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails.
DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.

Image 1 — scene_wall:
A Buddhist mountain temple at midnight under a thin moon; a single black ninja silhouette crouches on top of the long temple wall. Accent: deep blue night, a touch of jade on the roof tiles.

Image 2 — scene_fox_cell:
A dim stone prison cell; the white fox spirit stands in the doorway glowing softly, a ninja prisoner looks at it surprised, mist curling around. Accent: pale silver-white glow.

Image 3 — scene_ash_ceiling:
Ren lying awake on a sleeping mat in a dark monk dormitory, looking up; grey ash falls from cracks in the wooden ceiling like snow. Accent: ash grey with a faint ember-orange glow in the cracks.

Image 4 — scene_stairs:
Seen from a rooftop at night: two monks with lanterns guard a stone stairway that descends into the ground in the temple courtyard; the stone door at the bottom glows faintly. Accent: warm lantern orange.

Image 5 — scene_carvings:
An abandoned forest shrine; on moss-covered standing stones, carved reliefs show six stones in a hexagon around a horned figure, with a monk symbol and a ninja symbol side by side. Ren touches the carving. Accent: moss green.

Image 6 — scene_duel_shrine:
Ren and Aya facing each other at dawn in front of an old forest shrine, staff against fan, mist between them; the white fox watches from the shrine steps. Accent: pale dawn gold and crimson.

Image 7 — scene_crypt:
A huge underground crypt; on the floor six large stones form a hexagon around a deep glowing crack; three stones are split and ash rises from them. A tiny Aya stands at the edge for scale. Accent: ember orange in the dark.

Image 8 — scene_drunken_tale:
An old fat drunken monk with a gourd sits on the crypt steps telling a story; behind him, painted as a faded mural in smoke, a monk and a ninja woman stand back to back surrounding a demon. Aya listens. Accent: warm red.

Image 9 — scene_pagoda:
A five-storey dark pagoda on a cliff at night, crimson lanterns on every floor; Ren, tiny, climbs the stone steps toward it. Accent: crimson.

Image 10 — scene_scroll:
Aya in a temple library unrolling a long jade-green scroll on an altar; the old abbot sits defeated on the floor behind her. Through the window, a column of ash rises into the sky. Accent: jade green and ember orange.

Image 11 — scene_oni_rises:
The temple courtyard split by a burning crack; the colossal ash demon rises from it, horns and burning eyes in the smoke; tiny figures of monks and ninjas below. Accent: ember orange and ash grey.

Image 12 — scene_seal:
Ren and Aya side by side, back to back, with six glowing stones around them in a hexagon, three glowing jade green and three glowing crimson; the ash demon fades into sparks above them; the white fox shines between them. Accent: jade green and crimson.
```
