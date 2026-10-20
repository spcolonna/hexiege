# Hexiege — Prompts de arte del modo historia

Las viñetas se arman como una página de cómic:
- **Tiras:** de uno o dos cuadros, de anchos desparejos y con corte en diagonal. El mismo fondo se recorta en cuadros angostos y altos o anchos.
- **Momentos:** una pincelada ancha de tinta funciona como máscara y deja ver el escenario donde transcurre el momento.
- **Personajes:** quien habla está parado abajo, de su lado; en los planos de dos, cada uno del suyo.
- **Globos:** van arriba, escalonados, con la cola hacia quien habla.
- **Plano y contraplano:** el encuadre del escenario se corre según quién habla.
- **Momentos clave:** tienen una ilustración grande.

Cada bloque se pega tal cual en el generador. El estilo es el mismo de los avatares actuales: tinta sumi-e sobre papel de arroz, con un color de acento. Así las viñetas y el resto del juego se ven como una sola cosa.

| Bloque | Qué | Archivo | Cantidad |
|---|---|---|---|
| 1 | Figuras: protagonistas y jefes | `assets/story/char_<id>.png` | 8 |
| 2 | Figuras: secundarios | `assets/story/char_<id>.png` | 8 |
| 3 | Escenarios: Templo | `assets/story/bg_<id>.png` | 11 |
| 4 | Escenarios: fuera del Templo y final | `assets/story/bg_<id>.png` | 11 |
| 5 | Ilustraciones de momentos clave | `assets/story/art_<id>.png` | 12 |
| 6 | Retratos redondos (avatares) | `assets/avatars/avatar_<id>.png` | 3 |

Al integrarlos se convierten a `.webp`. El juego detecta solo qué arte existe. Mientras falte algo:
- Sin escenario: se pinta un paisaje de tinta con los colores del lugar.
- Sin figura: se muestra el retrato redondo del personaje o, si tampoco hay retrato, su kanji.
- Sin ilustración: el panel no aparece.

Se puede integrar de a un bloque.

**Fondo transparente:** si el generador no puede dar transparencia, las figuras se piden sobre magenta plano `#FF00FF`, que se recorta al integrar.

---

## Bloque 1 — Figuras: protagonistas y jefes (8)

```
Generate exactly 8 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL eight images:
Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.
PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.
FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.
STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look for all eight so they belong to one comic.
DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.

Image 1 — char_ren:
SUBJECT: Ren, a teenage Shaolin disciple (about 16), shaved head, earnest and stubborn face, saffron-orange robe with one shoulder bare, wooden staff held upright in one hand. Accent: saffron and jade green.

Image 2 — char_aya:
SUBJECT: Aya, a young kunoichi (about 18), black hair in a high ponytail, sharp watchful eyes, dark purple-black outfit, a cloth mask pulled down around her neck, holding a half-open folding war fan. Accent: deep purple and crimson.

Image 3 — char_abbot:
SUBJECT: Abbot Hōshin, an old Shaolin abbot (about 70), shaved head, long white eyebrows and a thin white beard, proud and secretive expression, saffron and dark red robes, a string of large jade prayer beads in one hand. Accent: jade green and dark red.

Image 4 — char_kage:
SUBJECT: Grand Shogun Kage, stern leader of the ninja clan (about 55), short greying beard, a scar across one eyebrow, black lacquered helmet with a small crescent crest, dark armor tied with crimson cords, tired hard eyes. Accent: crimson.

Image 5 — char_kuro:
SUBJECT: Kuro, the jonin, Aya's mentor (about 40), lean and dangerous, black hood, a long crimson scarf drifting like smoke, a kusarigama chain over the shoulder, loyal and severe. Accent: crimson and ash grey.

Image 6 — char_mei:
SUBJECT: Master Mei, second of the Shaolin temple, a strict woman in her fifties, shaved head, grey and jade-green robes, a long wooden prayer-bead necklace, calm face hiding something. Accent: jade green.

Image 7 — char_fox:
SUBJECT: The White Fox, a slender mystical fox spirit seen from the chest up, pure white fur, several soft glowing tails curling around her, calm knowing golden eyes, a faint silver glow. Accent: silver-white and pale gold.

Image 8 — char_oni:
SUBJECT: The Ash Oni, an ancient colossal demon seen from the chest up: horned head, skin of cracked grey ash with glowing orange-red fire inside the cracks, burning eyes, fangs, smoke rising from the horns and shoulders, one huge clawed hand. Terrifying but readable. Accent: ember orange and ash grey.
```

## Bloque 2 — Figuras: secundarios (8)

```
Generate exactly 8 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL eight images:
Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.
PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.
FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.
STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look for all eight so they belong to one comic.
DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.

Image 1 — char_tao:
SUBJECT: Tao, the drunken master, an old round-bellied Shaolin monk with a red nose and a mischievous grin, eyes half-closed, patched saffron robe, a big gourd of wine raised in one hand. Accent: warm red and saffron.

Image 2 — char_gon:
SUBJECT: Gon, Ren's fellow disciple and friendly rival (about 17), broad-shouldered and cocky, shaved head, a bandage on one forearm, saffron training clothes, an iron-banded staff resting on his shoulder. Accent: saffron and jade green.

Image 3 — char_jubei:
SUBJECT: Jubei, a wandering ronin who was once a monk (about 45), unshaven, a worn straw hat tilted back, a faded grey kimono over old monk prayer beads, a sheathed katana, wry tired smile. Accent: faded indigo and straw yellow.

Image 4 — char_ninja:
SUBJECT: A clan ninja foot soldier, anonymous, black outfit and hood, face mask showing only the eyes, a short katana drawn and held low, alert stance. Accent: crimson.

Image 5 — char_scout:
SUBJECT: A young ninja scout (about 15), lighter grey-black outfit, a coil of rope with a grappling hook on the shoulder, mask pulled down, nervous but defiant face. Accent: crimson and slate grey.

Image 6 — char_novice:
SUBJECT: A small Shaolin novice (about 10), round face, shaved head, oversized saffron robe, holding a broom bigger than himself, wide curious eyes. Accent: saffron.

Image 7 — char_guard:
SUBJECT: A pagoda guard of the ninja clan, heavy-set, dark lamellar armor over black clothes, crimson cords, a long spear held upright, stern face under a dark headband. Accent: crimson.

Image 8 — char_kunoichi:
SUBJECT: An elite clan kunoichi, cold and elegant (about 25), dark hair in a tight bun pierced with a needle, black outfit with crimson lining, a closed iron fan in each hand. Accent: crimson and black.
```

## Bloque 3 — Escenarios: el Templo (11)

```
Generate exactly 11 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL eleven images:
Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.
PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.
COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.
STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.
DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.

Image 1 — bg_wall:
The long outer wall of a Buddhist mountain temple at midnight, curved tiled roof on top of the wall, pine trees behind, a thin moon. Accent: deep night blue, a touch of jade on the tiles.

Image 2 — bg_yard:
The temple training yard in the morning: packed earth, wooden training posts, racks of staves, a low wall with a gate, mountains in mist behind. Accent: warm morning ochre.

Image 3 — bg_cells:
A row of dim stone prison cells inside the temple at night, wooden bars, a single oil lamp, straw on the floor. Accent: dark umber with a small warm lamplight.

Image 4 — bg_gate:
The main temple gate, massive red-lacquered doors with a tiled roof, stone stairs leading up to it, seen at dawn. Accent: dawn orange and dark red.

Image 5 — bg_abbot_hall:
The abbot's private hall: dark wooden pillars, a low lacquered desk, a scroll rack, incense smoke, a round window with mountains outside. Accent: deep red and gold.

Image 6 — bg_courtyard:
The main inner courtyard of the temple: stone paving, a bronze incense burner, a large bell under a small roof, halls with curved roofs on both sides. Accent: warm stone and saffron.

Image 7 — bg_dormitory:
The novices' dormitory at night: rows of sleeping mats on a wooden floor, paper windows with moonlight, dark rafters with thin cracks. Accent: dark brown with cold moonlight.

Image 8 — bg_library:
The temple library at night: tall shelves of scrolls, a stone altar in the middle distance with an empty jade stand, candles, dust in the air. Accent: jade green in the dark.

Image 9 — bg_ash_courtyard:
The same temple courtyard after disaster: a long burning crack splits the stone paving, grey ash falls like snow, grey flames, smoke hiding the roofs. Accent: ash grey and ember orange.

Image 10 — bg_crypt_stairs:
A hidden stone stairway descending into the ground at the edge of the temple courtyard at night, two lanterns at the top, a faint glow from the stone door far below. Accent: warm lantern orange.

Image 11 — bg_crypt:
A huge underground crypt under the temple: rough stone pillars, and on the floor six large standing stones forming a hexagon around a deep glowing crack, ash rising. Accent: ember orange in the dark.
```

## Bloque 4 — Escenarios: fuera del Templo y el final (11)

```
Generate exactly 11 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL eleven images:
Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.
PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.
COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.
STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.
DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.

Image 1 — bg_road:
A dirt road winding down the mountain toward a small village in the late afternoon, rice terraces, a wooden signpost, long shadows. Accent: golden afternoon ochre.

Image 2 — bg_mountain_path:
A narrow mountain path along a cliff, twisted pines, clouds below, stone steps cut into the rock. Accent: cool grey-green.

Image 3 — bg_bridge:
The only wooden bridge over a fast mountain river, rope rails, rocks and spray, forest on both banks. Accent: river blue-grey.

Image 4 — bg_shrine:
An abandoned forest shrine at dawn: a moss-covered torii-like gate, standing stones with worn carvings, mist between the trees. Accent: moss green and pale dawn gold.

Image 5 — bg_forest:
A dense bamboo and pine forest at night, shafts of moonlight, mist low on the ground. Accent: dark green and silver.

Image 6 — bg_valley:
A wide valley swallowed by thick fog, only the tops of trees and a few rocks visible, a faint sun disc. Accent: pale grey.

Image 7 — bg_pagoda:
The ninja clan's five-storey dark pagoda on a cliff at night, crimson lanterns on every floor, a stone stairway leading up. Accent: crimson.

Image 8 — bg_pagoda_top:
The top floor of the dark pagoda at night, an open balcony with crimson pillars, a war banner without symbols, the whole valley and the distant temple far below under stars. Accent: crimson and night violet.

Image 9 — bg_garden:
The temple's zen stone garden: raked white gravel, six dark stones arranged in a hexagon, one of them cracked, a low wall and a maple tree. Accent: soft grey and a single red maple.

Image 10 — bg_broken_garden:
The same zen stone garden torn in two by a glowing crack, gravel scattered, the six stones knocked over, ash and embers in the air. Accent: ember orange and ash grey.

Image 11 — bg_epilogue:
The temple courtyard one week after the battle, peaceful, cherry blossoms falling, the stone paving repaired with a visible golden seam (kintsugi), monks' and ninjas' banners hung side by side. Accent: soft pink and gold.
```

## Bloque 5 — Ilustraciones de momentos clave (12)

```
Generate exactly 12 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL twelve images:
Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.
PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.
STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.
CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.
DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.

Image 1 — art_wall:
A Buddhist mountain temple at midnight under a thin moon; a single black ninja silhouette crouches on top of the long temple wall. Accent: deep blue night, a touch of jade on the roof tiles.

Image 2 — art_fox_cell:
A dim stone prison cell; the white fox spirit stands in the doorway glowing softly, a young ninja prisoner looks at it surprised, mist curling around. Accent: pale silver-white glow.

Image 3 — art_ash_ceiling:
Ren and the abbot in the abbot's hall look up as grey ash falls from cracks in the wooden ceiling like snow. Accent: ash grey with a faint ember-orange glow in the cracks.

Image 4 — art_carvings:
An abandoned forest shrine; on moss-covered standing stones, carved reliefs show six stones in a hexagon around a horned figure, with a monk and a ninja side by side. Ren touches the carving. Accent: moss green.

Image 5 — art_duel_shrine:
Ren and Aya facing each other at dawn in front of an old forest shrine, staff against fan, mist between them; the white fox watches from the shrine steps. Accent: pale dawn gold and crimson.

Image 6 — art_pagoda:
A five-storey dark pagoda on a cliff at night, crimson lanterns on every floor; Ren, tiny, climbs the stone steps toward it. Accent: crimson.

Image 7 — art_stairs:
Seen from a rooftop at night: two monks with lanterns guard a stone stairway that descends into the ground in the temple courtyard; the stone door at the bottom glows faintly. Aya's silhouette watches from the roof edge in the foreground. Accent: warm lantern orange.

Image 8 — art_crypt:
A huge underground crypt; on the floor six large stones form a hexagon around a deep glowing crack; three stones are split and ash rises from them. A tiny Aya stands at the edge for scale. Accent: ember orange in the dark.

Image 9 — art_drunken_tale:
Tao sits on the crypt steps with his gourd telling a story; behind him, painted as a faded mural in smoke, a monk and a ninja woman stand back to back surrounding a demon with six stones. Aya listens. Accent: warm red.

Image 10 — art_scroll:
Aya in the temple library unrolling a long jade-green scroll on an altar; the old abbot sits defeated on the floor behind her. Through the window, a column of ash rises into the sky. Accent: jade green and ember orange.

Image 11 — art_oni_rises:
The temple courtyard split by a burning crack; the colossal ash demon rises from it, horns and burning eyes in the smoke; tiny figures of monks and ninjas below. Accent: ember orange and ash grey.

Image 12 — art_seal:
Ren and Aya side by side, back to back, with six glowing stones around them in a hexagon, three glowing jade green and three glowing crimson; the ash demon fades into sparks above them; the white fox shines between them. Accent: jade green and crimson.
```

## Bloque 6 — Retratos redondos (3)

Son los avatares circulares que se usan en el Pergamino y como respaldo de las figuras.

```
Generate exactly 3 separate images. Start generating immediately, without asking questions or requesting confirmation.

For ALL three images:
Create a SQUARE image (1:1, 1024×1024), fully opaque.
PURPOSE: A character portrait for the story mode of a mobile strategy game about Shaolin monks versus ninja clans. The game crops it into a CIRCLE and shows it small (about 64×64 pixels), so the face must be large, centered and readable at that size.
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
