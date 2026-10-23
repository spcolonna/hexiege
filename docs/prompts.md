# Prompts para generar el arte

Prompts para **ChatGPT** (generador de imágenes), en inglés porque así sigue mejor las instrucciones. Este es el
único archivo de prompts: juego e historia.

**Cómo usarlos:**
- Cada bloque gris es **un solo mensaje**: copialo entero y pegalo en una conversación nueva. Arranca a generar sin
  preguntar.
- Los bloques tienen **10 imágenes como máximo**.
- Cada imagen repite toda su descripción (formato, estilo, qué no incluir). Así sale consistente aunque la corras
  sola, en otra conversación o en otra cuenta.
- ChatGPT no les pone nombre: salen en el orden de la lista. Guardá cada PNG con el nombre que figura en
  `Image N — <nombre>`, en la carpeta que se indica, y pedile a Claude que las integre.
- Si una sale mal, regenerala sola con su prompt individual (más abajo, mismo nombre).

---

# Para generar ahora

| Bloque | Qué | Carpeta | Imágenes |
|---|---|---|---|
| A | Fichas del Oni para el final de la historia (opcionales) | `assets/pieces/` | 3 |

Además, sin generar nada:
- **Ícono Ema:** las 3 variantes ya están en `assets/icons/`; falta elegir una (ver «9. Ícono de la app estilo Ema»).
- **Fichas en alta resolución:** re-descargarlas de ChatGPT (ver «1. Fichas en alta resolución»).

Las fichas del Oni solo aparecen en el final (etapas f1–f3). Mientras falten, el juego las dibuja como piedra de
ceniza con su kanji (鬼, 饿, 眼). Van igual que las demás fichas: figura tallada con fondo transparente. Adjuntá
`assets/pieces/ninja_shogun.webp` como referencia de estilo y, si querés, `assets/story/char_oni.webp` para el Oni.

## Bloque A — Fichas del Oni (3)

Archivos, en orden: `oni_oni.png`, `oni_gaki.png`, `oni_oniEye.png`. Carpeta: `assets/pieces/`.
Ojo: el tercero se llama `oni_oniEye.png`, con la E mayúscula (así lo busca el código).

```
Generate exactly 3 separate images. Start generating immediately, without asking questions or requesting confirmation. Each image has its own complete instructions below; follow them separately. Each image is its own file: do NOT combine them into a grid, collage or contact sheet.

Image 1 — oni_oni:
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A huge horned demon (oni) shown from the chest up, facing the viewer straight on (perfect front view). Two thick curved horns, a heavy brow, a wide snarling mouth with two short tusks, a wild mane that dissolves upward into drifting flakes of ash. Massive shoulders, one clawed hand raised in front of the chest. Ancient, enormous, half-awake menace.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the eyes, the inside of the mouth and the cracks in the horns are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: two big horns above a snarling tusked face and broad shoulders.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.

Image 2 — oni_gaki:
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A gaki (hungry ghost): a gaunt, hunched spirit crouched as if about to leap, three-quarter view facing the viewer. Thin bony limbs, a swollen round belly, a long thin neck, a small head with a tiny pinched mouth and big hollow eyes. One long-fingered hand reaching forward, grasping at the air. Its lower body trails off into a curl of ash smoke instead of feet.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the hollow eyes and the reaching fingertips are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: a hunched starving spirit with a long neck, a reaching claw and a smoky tail.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.

Image 3 — oni_oniEye:
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A single giant demon eye carved in stone, seen straight from the front: a heavy-lidded almond-shaped eye with a vertical slit pupil, framed by a thick furrowed brow and deep wrinkles, with short jagged ash tendrils radiating out from the eyelids like dead roots. Watchful, calm, unsettling.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the iris and the cracks along the tendrils are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole shape is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: one big slit-pupil eye with a heavy brow and radiating tendrils.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

---

# Estado

⬜ = falta · ✅ = generado e integrado · ⏸ = generado, sin uso hasta que exista la tienda. Los prompts de lo que
ya está quedan abajo por si hay que regenerar algo.

## Historia

| Qué | Carpeta | Cantidad | Estado |
|---|---|---|---|
| Figuras de personajes (`char_*`) | `assets/story/` | 16 | ✅ |
| Escenarios (`bg_*`) | `assets/story/` | 22 | ✅ |
| Retratos redondos (`avatar_abbot`, `avatar_shogun`, `avatar_ashoni`) | `assets/avatars/` | 3 | ✅ |
| Ilustraciones de momentos clave (`art_*`) | `assets/story/` | 12 | ✅ |

Cómo las usa el juego:
- **Figuras:** quien habla está parado abajo, de su lado del cuadro; el juego espeja la figura cuando va a la
  derecha, por eso todas miran a la derecha. Fondo transparente (o magenta `#FF00FF`, que se recorta).
- **Escenarios:** el mismo fondo se recorta en tiras anchas y en cuadros altos o anchos, y el encuadre se corre
  según quién habla: por eso piden detalles en los tres tercios, arriba tranquilo y abajo despejado.
- **Ilustraciones:** panel ancho enmascarado por una pincelada; necesitan un foco claro.
- **Retratos:** se recortan en círculo, como los avatares.
- Al integrarlas se pasan a `.webp`. El juego detecta solo qué arte existe y, si falta algo, dibuja un respaldo.

## Juego

| # | Qué | Para qué | Cantidad | Estado |
|---|---|---|---|---|
| 1 | Fichas en alta resolución | Zoom nítido en el visor 3D | 12 (re-descargar, no generar) | ⬜ |
| 2 | Banner de Google Play | Obligatorio para publicar en Android | 1 | ✅ `store/feature_graphic.png` (1024×500) |
| 3 | Avatares que faltan | Perfil | 2 | ✅ en el juego |
| 4 | Emotes | Partida | 16 | ✅ en el juego |
| 5 | Marcos de avatar | Perfil (a futuro, premios de la ladder) | 4 | ✅ en el juego |
| 6 | Íconos de la tienda | Tienda | 3 | ⏸ generados; se usan cuando exista la tienda |
| 7 | Piedras de ficha (skins) | Ajustes | 4 | ✅ en el juego |
| 8 | Tapetes de mesa | Ajustes (debajo del tablero) | 5 | ✅ en el juego |
| 9 | Ícono de la app estilo Ema | Ícono de iOS y Android | 3 variantes | ⏸ generadas en `assets/icons/`; falta elegir una |
| 10 | Fichas del Oni | Final de la historia (hoy se dibujan con kanji) | 3 | ⬜ (bloque A; opcionales) |

Las capturas de pantalla para App Store y Google Play no se generan: se sacan del juego.

---

# Prompts individuales — Historia

## Ilustraciones de momentos clave — `assets/story/`

### `art_wall.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: A Buddhist mountain temple at midnight under a thin moon; a single black ninja silhouette crouches on top of the long temple wall. Accent: deep blue night, a touch of jade on the roof tiles.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_fox_cell.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: A dim stone prison cell; the white fox spirit stands in the doorway glowing softly, a young ninja prisoner looks at it surprised, mist curling around. Accent: pale silver-white glow.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_ash_ceiling.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Ren and the abbot in the abbot's hall look up as grey ash falls from cracks in the wooden ceiling like snow. Accent: ash grey with a faint ember-orange glow in the cracks.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_carvings.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: An abandoned forest shrine; on moss-covered standing stones, carved reliefs show six stones in a hexagon around a horned figure, with a monk and a ninja side by side. Ren touches the carving. Accent: moss green.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_duel_shrine.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Ren and Aya facing each other at dawn in front of an old forest shrine, staff against fan, mist between them; the white fox watches from the shrine steps. Accent: pale dawn gold and crimson.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_pagoda.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: A five-storey dark pagoda on a cliff at night, crimson lanterns on every floor; Ren, tiny, climbs the stone steps toward it. Accent: crimson.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_stairs.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Seen from a rooftop at night: two monks with lanterns guard a stone stairway that descends into the ground in the temple courtyard; the stone door at the bottom glows faintly. Aya's silhouette watches from the roof edge in the foreground. Accent: warm lantern orange.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_crypt.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: A huge underground crypt; on the floor six large stones form a hexagon around a deep glowing crack; three stones are split and ash rises from them. A tiny Aya stands at the edge for scale. Accent: ember orange in the dark.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_drunken_tale.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Tao sits on the crypt steps with his gourd telling a story; behind him, painted as a faded mural in smoke, a monk and a ninja woman stand back to back surrounding a demon with six stones. Aya listens. Accent: warm red.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_scroll.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Aya in the temple library unrolling a long jade-green scroll on an altar; the old abbot sits defeated on the floor behind her. Through the window, a column of ash rises into the sky. Accent: jade green and ember orange.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_oni_rises.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: The temple courtyard split by a burning crack; the colossal ash demon rises from it, horns and burning eyes in the smoke; tiny figures of monks and ninjas below. Accent: ember orange and ash grey.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `art_seal.png` ✅

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A full-width comic "splash panel" for the key moments of the story mode of a mobile strategy game about Shaolin monks (white marble, jade green, saffron) versus a ninja clan (black, crimson). It is masked by a ragged ink brush stroke, so the outer edges may be lost; it is shown on a phone about 360 pixels wide, so it needs one clear focal point and a strong silhouette.

SUBJECT: Ren and Aya side by side, back to back, with six glowing stones around them in a hexagon, three glowing jade green and three glowing crimson; the ash demon fades into sparks above them; the white fox shines between them. Accent: jade green and crimson.

CONTINUITY: The young monk REN is a teenage boy, shaved head, saffron-orange robe, wooden staff. The kunoichi AYA is a young woman, black hair in a high ponytail, purple-black outfit, mask around the neck, a folding war fan. The WHITE FOX is a slender white fox spirit with several soft glowing tails. The drunken master TAO is an old round-bellied monk with a wine gourd. The ABBOT is an old monk with a white beard and jade prayer beads.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, lots of empty paper, limited palette of ink black plus the accent colors given. Cinematic framing, atmospheric mist, dramatic like a comic splash page. Not cartoonish.

DO NOT INCLUDE: any text, letters, speech bubbles, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

## Figuras de personajes ✅ — `assets/story/`

### `char_ren.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands at the bottom of a panel over a painted background. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Ren, a teenage Shaolin disciple (about 16), shaved head, earnest and stubborn face, saffron-orange robe with one shoulder bare, wooden staff held upright in one hand. Accent colors: saffron and jade green.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. Three-quarter view, body turned TOWARD THE RIGHT side of the image, eyes looking to the right as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors. Expressive but not cartoonish.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; other characters.
```

### `char_aya.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands at the bottom of a panel over a painted background. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Aya, a young kunoichi (about 18), black hair in a high ponytail, sharp watchful eyes, dark purple-black outfit, a cloth mask pulled down around her neck. Accent colors: deep purple and crimson.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. Three-quarter view, body and face turned TOWARD THE RIGHT side of the image, eyes looking to the right as if talking to someone there.

HANDS (important): Only ONE hand is raised: the hand on the RIGHT SIDE OF THE IMAGE (the one in front, closest to where she is looking) is lifted to chest height and holds a half-open folding war fan pointing forward to the right. The hand on the LEFT SIDE OF THE IMAGE stays down and relaxed, close to her body, partly hidden. Exactly two hands, correct anatomy, five fingers each.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors. Expressive but not cartoonish.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; other characters.
```

### `char_abbot.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Abbot Hōshin, an old Shaolin abbot (about 70), shaved head, long white eyebrows and a thin white beard, proud and secretive expression, saffron and dark red robes, a string of large jade prayer beads in one hand. Accent: jade green and dark red.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_kage.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Grand Shogun Kage, stern leader of the ninja clan (about 55), short greying beard, a scar across one eyebrow, black lacquered helmet with a small crescent crest, dark armor tied with crimson cords, tired hard eyes. Accent: crimson.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_kuro.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Kuro, the jonin, Aya's mentor (about 40), lean and dangerous, black hood, a long crimson scarf drifting like smoke, a kusarigama chain over the shoulder, loyal and severe. Accent: crimson and ash grey.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_mei.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Master Mei, second of the Shaolin temple, a strict woman in her fifties, shaved head, grey and jade-green robes, a long wooden prayer-bead necklace, calm face hiding something. Accent: jade green.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_fox.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: The White Fox, a slender mystical fox spirit seen from the chest up, pure white fur, several soft glowing tails curling around her, calm knowing golden eyes, a faint silver glow. Accent: silver-white and pale gold.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_oni.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: The Ash Oni, an ancient colossal demon seen from the chest up: horned head, skin of cracked grey ash with glowing orange-red fire inside the cracks, burning eyes, fangs, smoke rising from the horns and shoulders, one huge clawed hand. Terrifying but readable. Accent: ember orange and ash grey.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_tao.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Tao, the drunken master, an old round-bellied Shaolin monk with a red nose and a mischievous grin, eyes half-closed, patched saffron robe, a big gourd of wine raised in one hand. Accent: warm red and saffron.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_gon.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Gon, Ren's fellow disciple and friendly rival (about 17), broad-shouldered and cocky, shaved head, a bandage on one forearm, saffron training clothes, an iron-banded staff resting on his shoulder. Accent: saffron and jade green.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_jubei.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: Jubei, a wandering ronin who was once a monk (about 45), unshaven, a worn straw hat tilted back, a faded grey kimono over old monk prayer beads, a sheathed katana, wry tired smile. Accent: faded indigo and straw yellow.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_ninja.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: A clan ninja foot soldier, anonymous, black outfit and hood, face mask showing only the eyes, a short katana drawn and held low, alert stance. Accent: crimson.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_scout.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: A young ninja scout (about 15), lighter grey-black outfit, a coil of rope with a grappling hook on the shoulder, mask pulled down, nervous but defiant face. Accent: crimson and slate grey.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_novice.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: A small Shaolin novice (about 10), round face, shaved head, oversized saffron robe, holding a broom bigger than himself, wide curious eyes. Accent: saffron.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_guard.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: A pagoda guard of the ninja clan, heavy-set, dark lamellar armor over black clothes, crimson cords, a long spear held upright, stern face under a dark headband. Accent: crimson.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

### `char_kunoichi.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a PORTRAIT image with a 2:3 aspect ratio (1024×1536), with a TRANSPARENT background (PNG with alpha). If transparency is impossible, use a perfectly flat pure magenta (#FF00FF) background with no gradient, no shadow and no texture.

PURPOSE: A character cut-out for comic-style dialogue panels in a mobile strategy game about Shaolin monks versus a ninja clan. The figure stands on one side of a wide panel, over a painted background, and its head may break out of the top of the panel. It is shown about 140 pixels wide on a phone, so the silhouette and the face must read clearly.

SUBJECT: An elite clan kunoichi, cold and elegant (about 25), dark hair in a tight bun pierced with a needle, black outfit with crimson lining, a closed iron fan in each hand. Accent: crimson and black.

FRAMING: Half-body, from the waist up, cut off cleanly at the bottom edge of the image. The head is in the upper third, with a little empty space above it. The body is in a three-quarter view turned TOWARD THE RIGHT side of the image (the game mirrors it when the character stands on the right), the eyes looking to the right, as if talking to someone there. One expressive hand gesture is welcome if it stays inside the image.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes and clean, bold ink outlines, combined with a limited flat color palette: deep ink black, warm off-white, and the accent colors given in the subject. Expressive but not cartoonish; same look as the rest of the comic.

DO NOT INCLUDE: any background, floor, cast shadow or scenery; any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style; extra characters.
```

## Escenarios ✅ — `assets/story/`

### `bg_wall.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) and comic frames from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The long outer wall of a Buddhist mountain temple at midnight, a curved tiled roof running along the top of the wall, pine trees behind it, a thin moon in the sky. Accent: deep night blue, a touch of jade on the roof tiles.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (night sky, mist) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. The mood should read at a glance.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_yard.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) and comic frames from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The temple training yard in the early morning: packed earth ground, wooden training posts, racks of wooden staves, a low wall with a small gate, mountains in mist behind. Accent: warm morning ochre.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, mist, wall line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. The mood should read at a glance.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_cells.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) and comic frames from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A row of dim stone prison cells inside the temple at night: thick wooden bars, rough stone walls, a single oil lamp hanging on the wall giving a small warm glow, straw on the floor. Accent: dark umber with a small warm lamplight.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third (for example a cell door, the lamp, another set of bars), so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (dark stone wall, shadow) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. The mood should read at a glance.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric haze, limited palette of ink black plus the accent. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_courtyard.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) and comic frames from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The main inner courtyard of a Buddhist mountain temple in daylight: stone paving, a bronze incense burner with a thin line of smoke, a large bronze bell under a small roof, halls with curved tiled roofs on both sides, mountains in mist far behind. Accent: warm stone and saffron.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. The mood should read at a glance.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_gate.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The main temple gate, massive red-lacquered doors with a tiled roof, stone stairs leading up to it, seen at dawn. Accent: dawn orange and dark red.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_abbot_hall.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The abbot's private hall: dark wooden pillars, a low lacquered desk, a scroll rack, incense smoke, a round window with mountains outside. Accent: deep red and gold.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_dormitory.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The novices' dormitory at night: rows of sleeping mats on a wooden floor, paper windows with moonlight, dark rafters with thin cracks. Accent: dark brown with cold moonlight.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_library.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The temple library at night: tall shelves of scrolls, a stone altar in the middle distance with an empty jade stand, candles, dust in the air. Accent: jade green in the dark.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_ash_courtyard.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The same temple courtyard after disaster: a long burning crack splits the stone paving, grey ash falls like snow, grey flames, smoke hiding the roofs. Accent: ash grey and ember orange.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_crypt_stairs.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A hidden stone stairway descending into the ground at the edge of the temple courtyard at night, two lanterns at the top, a faint glow from the stone door far below. Accent: warm lantern orange.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_crypt.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A huge underground crypt under the temple: rough stone pillars, and on the floor six large standing stones forming a hexagon around a deep glowing crack, ash rising. Accent: ember orange in the dark.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_road.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A dirt road winding down the mountain toward a small village in the late afternoon, rice terraces, a wooden signpost, long shadows. Accent: golden afternoon ochre.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_mountain_path.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A narrow mountain path along a cliff, twisted pines, clouds below, stone steps cut into the rock. Accent: cool grey-green.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_bridge.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The only wooden bridge over a fast mountain river, rope rails, rocks and spray, forest on both banks. Accent: river blue-grey.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_shrine.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: An abandoned forest shrine at dawn: a moss-covered torii-like gate, standing stones with worn carvings, mist between the trees. Accent: moss green and pale dawn gold.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_forest.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A dense bamboo and pine forest at night, shafts of moonlight, mist low on the ground. Accent: dark green and silver.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_valley.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: A wide valley swallowed by thick fog, only the tops of trees and a few rocks visible, a faint sun disc. Accent: pale grey.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_pagoda.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The ninja clan's five-storey dark pagoda on a cliff at night, crimson lanterns on every floor, a stone stairway leading up. Accent: crimson.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_pagoda_top.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The top floor of the dark pagoda at night, an open balcony with crimson pillars, a war banner without symbols, the whole valley and the distant temple far below under stars. Accent: crimson and night violet.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_garden.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The temple's zen stone garden: raked white gravel, six dark stones arranged in a hexagon, one of them cracked, a low wall and a maple tree. Accent: soft grey and a single red maple.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_broken_garden.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The same zen stone garden torn in two by a glowing crack, gravel scattered, the six stones knocked over, ash and embers in the air. Accent: ember orange and ash grey.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

### `bg_epilogue.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a LANDSCAPE image with a 3:2 aspect ratio (1536×1024), fully opaque.

PURPOSE: A background for a comic page in a mobile strategy game about Shaolin monks (white stone, jade green, saffron) versus a ninja clan (black, crimson). The game crops the same image in different ways: a WIDE horizontal strip (about 2.4:1) for establishing panels, and comic frames of varied shape for dialogue, from TALL and NARROW (about 2:3) to wide (about 3:2). The crop slides to the LEFT, CENTER or RIGHT depending on who is speaking. Characters stand in front along the bottom edge; speech balloons cover the upper part.

SUBJECT: The temple courtyard one week after the battle, peaceful, cherry blossoms falling, the stone paving repaired with a visible golden seam (kintsugi), monks' and ninjas' banners hung side by side. Accent: soft pink and gold.

COMPOSITION: An EMPTY place with NO people or animals. Spread the interesting details across the whole width, with something recognizable in the left third, the center and the right third, so that any narrow vertical slice still reads as this place. Keep the upper area calm and simple (sky, wall, mist, roof line) because balloons cover it, and the lower third uncluttered because characters stand there. No single huge object in the center. Readable as a mood at a glance: time of day and atmosphere matter more than detail.

STYLE: Traditional East Asian ink-wash painting (sumi-e) on warm off-white rice paper, confident brush strokes, atmospheric mist, limited palette of ink black plus the accent given. Slightly muted so characters in front of it stand out. Not cartoonish.

DO NOT INCLUDE: people, animals, any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame or border; photographic realism; 3D render; anime style.
```

## Retratos redondos ✅ — `assets/avatars/`

### `avatar_abbot.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: A character portrait for the story mode of a mobile strategy game about Shaolin monks versus ninja clans. The game crops it into a CIRCLE and shows it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: An old Shaolin abbot, about seventy, shaved head, long white eyebrows and a thin white beard, deep wrinkles, calm but proud and secretive expression, eyes slightly narrowed. Saffron and dark red robes, a string of large jade prayer beads. Accent color: jade green.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### `avatar_shogun.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: A character portrait for the story mode of a mobile strategy game about Shaolin monks versus ninja clans. The game crops it into a CIRCLE and shows it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: The Grand Shogun of a ninja clan, a stern man in his fifties, short greying beard, a scar across one eyebrow, black lacquered samurai helmet with a small crescent crest, dark armor with crimson cords. Hard but not cruel expression, tired eyes. Accent color: crimson.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### `avatar_ashoni.png`

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: A character portrait for the story mode of a mobile strategy game about Shaolin monks versus ninja clans. The game crops it into a CIRCLE and shows it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: An ancient demon made of ash and embers: a horned oni face whose skin is cracked grey ash with glowing orange-red fire inside the cracks, burning eyes, sharp fangs, smoke drifting from its horns. Terrifying but readable. Accent color: ember orange.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

---

# Prompts individuales — Juego

## 1. Fichas en alta resolución ⬜ (no se genera nada)

El visor 3D de la galería deja hacer zoom, pero las fichas quedaron a 512 px y de cerca se ven algo borrosas.
ChatGPT las generó a 1024 px; el problema es que achicamos esa versión al integrarla.

1. Entrá a las conversaciones de ChatGPT donde generaste las fichas y **volvé a descargar cada imagen final**
   (la que quedó en el juego).
2. Dejalas en `assets/pieces/hires/` con el nombre de siempre:
   `shaolin_monk.png`, `shaolin_dragon.png`, `shaolin_wukong.png`, `shaolin_tiger.png`, `shaolin_crane.png`,
   `shaolin_serpent.png`, `ninja_shogun.png`, `ninja_shinobi.png`, `ninja_kunoichi.png`, `ninja_tengu.png`,
   `ninja_kitsune.png`, `ninja_shadow.png`.
3. Pedile a Claude que las integre. El tablero sigue usando la de 512 (es liviana) y el visor carga la de 1024.

Si alguna conversación ya no está, su prompt está al final, en «Ya en el juego». Va a salir parecida pero no
idéntica, así que en ese caso conviene reemplazar también la de 512.

---

## 2. Banner de Google Play ✅

Google Play lo exige para publicar (1024×500). ChatGPT no hace ese tamaño exacto: pedimos 2:1 y Claude lo
recorta. Va sin texto; el nombre del juego se lo agregamos encima después, si queremos.

Archivo: `store/feature_graphic.png`

```
Create a WIDE LANDSCAPE image with a 2:1 aspect ratio (for example 1536×768), fully opaque.

PURPOSE: This is the feature banner of "Hexiege" on the Google Play store, a hexagonal strategy board game where Shaolin monks (white marble and green jade) fight ninja clans (black obsidian and crimson). It will be cropped to 1024×500, and the store may place a play button over the very center, so keep the center calm.

SUBJECT: A dark, warm temple table seen from slightly above. On the LEFT side, three hexagonal stone game tiles of polished white marble with thin jade-green (#2F9E6E) rims, each with a small carved figure in bas-relief: a meditating monk, a coiled dragon, a leaping crane. On the RIGHT side, three hexagonal tiles of polished black obsidian with thin crimson (#C0404F) rims and glowing crimson veins, carved with a samurai helmet, a fox and a crow-demon. The two groups face each other across the middle as if about to clash; a soft burst of warm light and a few floating sparks between them.

BACKGROUND AND LIGHTING: Deep charcoal brown (#231E1A) with a gentle warm glow in the middle. Soft light from the upper left; the tiles have clear highlights on their upper edges and soft shadows, so they read as thick physical stones.

COMPOSITION: The tiles sit in the left third and the right third; the central third is mostly the glow. Keep a 10% empty margin at the top and bottom (it will be cropped).

DO NOT INCLUDE: any text, letters, logo or Chinese/Japanese characters; people or creatures outside the carvings; a border or frame; cartoon, anime or flat vector style.
```

---

## 3. Avatares que faltan ✅ (2)

El retrato del jugador en el emparejamiento, el marcador de la partida y el perfil. El juego lo recorta en
círculo. Son retratos en tinta, distintos de las fichas de piedra a propósito. Los otros 8 ya están en el
juego (sus prompts, al final). Carpeta: `assets/avatars/`.

### 3.1 Máscara oni (Ninja) — `avatar_oni.png`

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A ninja wearing a red horned oni demon mask with fangs, only the mask and hood visible, intimidating. Accent color: blood red.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### 3.2 Espíritu kitsune (Ninja) — `avatar_kitsune.png`

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A mysterious figure wearing a white fox kitsune mask with red markings, long silver hair, wisps of blue spirit fire floating around. Accent color: ice blue.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

---

## 4. Emotes ✅ (16)

Stickers de un monjecito y un ninjita, los mismos 8 gestos que hay hoy en la partida. Cada jugador usa el de
su facción.

Carpeta: `assets/emotes/`.

### 4.A Monjecito

#### 4.A1 Hola — `emote_monk_hello.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Waving one hand happily with a big smile, a small bow of the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A2 Bien jugado — `emote_monk_nice.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Giving a thumbs up with a proud confident smile and one eye winking.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A3 ¡Wow! — `emote_monk_wow.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Shocked with huge round eyes and mouth wide open, hands on cheeks, tiny sparkles around the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A4 Pensando — `emote_monk_think.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Thinking hard, eyes looking up, one hand on the chin, a small question mark floating above.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A5 ¡Fuego! — `emote_monk_fire.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Fired up with burning determined eyes, fists raised, small orange flames around the body.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A6 Canchero — `emote_monk_smug.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Smug and cocky, half-closed eyes, a sly grin, arms crossed.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A7 Uy — `emote_monk_oops.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Embarrassed with a nervous smile, a big sweat drop on the forehead, scratching the back of the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.A8 GG — `emote_monk_gg.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.

EXPRESSION: Bowing respectfully with both hands holding a small wooden sign that reads exactly "GG" in bold letters.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text or letters other than the "GG" on the sign; extra characters; realistic style.
```

### 4.B Ninjita

#### 4.B1 Hola — `emote_ninja_hello.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Waving one hand happily with a big smile, a small bow of the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B2 Bien jugado — `emote_ninja_nice.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Giving a thumbs up with a proud confident smile and one eye winking.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B3 ¡Wow! — `emote_ninja_wow.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Shocked with huge round eyes and mouth wide open, hands on cheeks, tiny sparkles around the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B4 Pensando — `emote_ninja_think.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Thinking hard, eyes looking up, one hand on the chin, a small question mark floating above.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B5 ¡Fuego! — `emote_ninja_fire.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Fired up with burning determined eyes, fists raised, small orange flames around the body.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B6 Canchero — `emote_ninja_smug.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Smug and cocky, half-closed eyes, a sly grin, arms crossed.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B7 Uy — `emote_ninja_oops.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Embarrassed with a nervous smile, a big sweat drop on the forehead, scratching the back of the head.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text, letters or characters; extra characters; realistic style.
```

#### 4.B8 GG — `emote_ninja_gg.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: Bowing respectfully with both hands holding a small wooden sign that reads exactly "GG" in bold letters.

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background; a speech bubble; any text or letters other than the "GG" on the sign; extra characters; realistic style.
```

---

## 5. Marcos de avatar ✅ (4)

El aro que rodea al avatar. Se ganan por rango en la ladder. El centro tiene que quedar transparente.

Carpeta: `assets/frames/`.

### 5.1 Bronce (rango 1 de la ladder) — `frame_bronze.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A decorative circular frame for a player avatar in a mobile game. The game places a round portrait in the transparent center hole.

SUBJECT: A circular ring frame. Simple polished bronze ring with a thin engraved wave pattern.

SHAPE: The ring is centered. Its outer edge touches about 96% of the canvas width; the inner hole is a perfect circle of about 74% of the canvas width and is COMPLETELY TRANSPARENT. Ornaments may stick out slightly at the top and bottom only, never covering the hole.

LIGHTING: Soft light from the upper left, clear highlights and soft shadows so it reads as a thick physical object.

DO NOT INCLUDE: anything inside the center hole; a background; any text, letters or numbers; a portrait or face.
```

### 5.2 Plata y jade (rango 2) — `frame_jade.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A decorative circular frame for a player avatar in a mobile game. The game places a round portrait in the transparent center hole.

SUBJECT: A circular ring frame. Polished silver ring inlaid with four small rounded green jade stones at the top, bottom, left and right.

SHAPE: The ring is centered. Its outer edge touches about 96% of the canvas width; the inner hole is a perfect circle of about 74% of the canvas width and is COMPLETELY TRANSPARENT. Ornaments may stick out slightly at the top and bottom only, never covering the hole.

LIGHTING: Soft light from the upper left, clear highlights and soft shadows so it reads as a thick physical object.

DO NOT INCLUDE: anything inside the center hole; a background; any text, letters or numbers; a portrait or face.
```

### 5.3 Oro imperial (rango 3) — `frame_gold.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A decorative circular frame for a player avatar in a mobile game. The game places a round portrait in the transparent center hole.

SUBJECT: A circular ring frame. Ornate gold ring with carved cloud motifs, a small golden dragon head peeking over the top edge.

SHAPE: The ring is centered. Its outer edge touches about 96% of the canvas width; the inner hole is a perfect circle of about 74% of the canvas width and is COMPLETELY TRANSPARENT. Ornaments may stick out slightly at the top and bottom only, never covering the hole.

LIGHTING: Soft light from the upper left, clear highlights and soft shadows so it reads as a thick physical object.

DO NOT INCLUDE: anything inside the center hole; a background; any text, letters or numbers; a portrait or face.
```

### 5.4 Obsidiana carmesí (rango máximo) — `frame_obsidian.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A decorative circular frame for a player avatar in a mobile game. The game places a round portrait in the transparent center hole.

SUBJECT: A circular ring frame. Black obsidian ring with glowing crimson cracks, a small brass shuriken ornament at the top and two thin red tassels hanging from the bottom.

SHAPE: The ring is centered. Its outer edge touches about 96% of the canvas width; the inner hole is a perfect circle of about 74% of the canvas width and is COMPLETELY TRANSPARENT. Ornaments may stick out slightly at the top and bottom only, never covering the hole.

LIGHTING: Soft light from the upper left, clear highlights and soft shadows so it reads as a thick physical object.

DO NOT INCLUDE: anything inside the center hole; a background; any text, letters or numbers; a portrait or face.
```

---

## 6. Íconos de la tienda ⏸ (3, generados)

Se ven chicos (24 a 64 px). Carpeta: `assets/icons/`.

### 6.1 Moneda de jade — `icon_jade.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A user-interface icon for a mobile strategy game about Shaolin monks and ninjas. It will be shown small (24 to 64 pixels), so it needs one bold, simple shape.

SUBJECT: A thick round coin carved from glossy green jade (#2F9E6E), with a square hole in the center like an ancient Chinese coin and a thin gold rim.

STYLE: A physical, slightly stylized 3D object with clear volume, polished materials and a soft light from the upper left. Centered, filling about 80% of the canvas.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or numbers, frame or extra objects.
```

### 6.2 Cofre — `icon_chest.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A user-interface icon for a mobile strategy game about Shaolin monks and ninjas. It will be shown small (24 to 64 pixels), so it needs one bold, simple shape.

SUBJECT: A small treasure chest of black lacquered wood with brass corners and a red silk tassel on the lock, the lid slightly open with a soft golden glow inside.

STYLE: A physical, slightly stylized 3D object with clear volume, polished materials and a soft light from the upper left. Centered, filling about 80% of the canvas.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or numbers, frame or extra objects.
```

### 6.3 Tienda — `icon_shop.png`

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: A user-interface icon for a mobile strategy game about Shaolin monks and ninjas. It will be shown small (24 to 64 pixels), so it needs one bold, simple shape.

SUBJECT: A small market stall with a curved Asian tiled roof and a red paper lantern hanging from the front.

STYLE: A physical, slightly stylized 3D object with clear volume, polished materials and a soft light from the upper left. Centered, filling about 80% of the canvas.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or numbers, frame or extra objects.
```

---

## 7. Piedras de ficha ✅ (4 skins)

Cambian la piedra de las 6 fichas del jugador. Tienen que contrastar con la figura: más oscuras bajo la
figura blanca Shaolin, más claras bajo la figura negra Ninja.

Carpeta: `assets/textures/`.

### 7.1 Jade imperial (Shaolin) — `shaolin_stone_imperial.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a white polished marble carving on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed (matte) deep imperial jade, base color a rich muted green (around #6E9A7E), with soft cloudy lighter patches (#8DB39A) and a fine mineral speckle. Dark enough that a white marble carving stands out clearly on it.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong or high-contrast veins; a perspective view; a photographic scene.
```

### 7.2 Arenisca dorada (Shaolin) — `shaolin_stone_sandstone.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a white polished marble carving on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed warm golden sandstone (around #B9A27A), very fine sandy grain, a few faint soft horizontal layers in a slightly darker tone (#A48D66). Dark enough that a white marble carving stands out clearly on it.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong or high-contrast veins; a perspective view; a photographic scene.
```

### 7.3 Laca bermellón (Ninja) — `ninja_stone_vermilion.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a polished black obsidian carving with crimson veins on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of worn satin vermilion lacquer (around #8E3B32) over wood, a very faint wood grain showing through, slightly lighter worn patches (#A2493E). Light enough that a black obsidian carving stands out clearly on it.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong or high-contrast veins; a perspective view; a photographic scene.
```

### 7.4 Hierro oxidado (Ninja) — `ninja_stone_iron.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a polished black obsidian carving with crimson veins on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a plate of dark weathered iron (around #4A4440), matte, with soft rust-brown mottling (#6A4A38) and a fine even grain. Light enough that a black obsidian carving stands out clearly on it.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong or high-contrast veins; a perspective view; a photographic scene.
```

---

## 8. Tapetes de mesa ✅ (5)

El paño que está *debajo* del tablero durante la partida, como el fieltro de una mesa de póker. Hoy el juego lo
pinta por código. Se ve poco porque el tablero lo tapa casi todo, por eso va último.

Carpeta: `assets/tables/`.

### 8.1 Madera de templo — `table_temple_wood.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: Pale honey-colored temple wood planks with fine straight grain, running horizontally, planks about 1/4 of the image tall, soft warm tones.

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

### 8.2 Laca negra — `table_black_lacquer.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: Satin black lacquer over wood, the wood grain faintly visible through the lacquer, a very subtle deep red undertone.

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

### 8.3 Tatami — `table_tatami.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: Woven tatami straw mat, fine horizontal weave, soft pale green-gold color, slightly worn.

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

### 8.4 Seda roja — `table_red_silk.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: Deep crimson silk cloth stretched flat, very fine weave, a faint tone-on-tone cloud pattern barely visible.

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

### 8.5 Pizarra de río — `table_river_slate.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: Smooth dark grey river slate, matte, very fine grain, soft cool tones.

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

---

## 9. Ícono de la app estilo Ema ⏸ (3 variantes, generadas)

Están en `assets/icons/app_icon_ema_{a,b,c}.png`. Se elige una y Claude genera con ella los íconos de iOS y
Android (`flutter_launcher_icons.yaml`: la copia a `assets/icon/app_icon.png` y arma `app_icon_fg.png` para el
ícono adaptativo de Android). Prompt de las tres, por si hay que regenerar:

```
Generate exactly 3 separate images. Start generating immediately, without asking questions or requesting confirmation. Each image has its own complete instructions below; follow them separately. Each image is its own file: do NOT combine them into a grid, collage or contact sheet.

Image 1 — app_icon_ema_a:
Create a SQUARE 1024×1024 PNG image, fully opaque (no transparency anywhere), with square corners (do not round the corners, the phone will do that).

PURPOSE: This is the app icon of "Hexiege", a hexagonal strategy board game where Shaolin monks (white marble and jade green) fight a ninja clan (black obsidian and crimson). The game's interface uses Japanese votive wooden plaques (ema) hanging from red cords, on washi paper. The icon will be seen very small (about 60×60 pixels) on a phone home screen, so it must read as one bold, simple shape.

STYLE: Polished, painterly 3D game-icon rendering with real materials: warm natural wood with visible grain, polished stone, thick red braided cord. Soft light from the upper left, clear highlights and soft shadows so everything reads as thick physical objects. Rich but limited palette: warm wood, ink black, jade green, crimson, a touch of gold.

BACKGROUND: A smooth, dark, warm background filling the whole square: deep charcoal brown (#231E1A) with a gentle lighter glow behind the subject. No pattern, no scene.

COMPOSITION: The subject is centered and fills about 70% of the canvas. Keep about 12% of empty margin on every side (the corners get cut off). Big, simple shapes; very little fine detail.

DO NOT INCLUDE: any text, letters, logo, signature or Chinese/Japanese characters; a border or frame around the image; rounded corners; transparency; cartoon, anime or flat vector style.

SUBJECT: A single wooden ema plaque (a pentagon: rectangle with a pointed gable roof on top) hanging slightly tilted from a short thick red cord tied in a knot at the top. Mounted on the plaque, two hexagonal stone game tiles slightly overlapping, as if they just clashed: the front-left tile is polished white marble with a jade-green (#2F9E6E) rim and a small carved lotus in bas-relief; the back-right tile is polished black obsidian with a crimson (#C0404F) rim and a small carved crescent moon in bas-relief.

Image 2 — app_icon_ema_b:
Create a SQUARE 1024×1024 PNG image, fully opaque (no transparency anywhere), with square corners (do not round the corners, the phone will do that).

PURPOSE: This is the app icon of "Hexiege", a hexagonal strategy board game where Shaolin monks (white marble and jade green) fight a ninja clan (black obsidian and crimson). The game's interface uses Japanese votive wooden plaques (ema) hanging from red cords, on washi paper. The icon will be seen very small (about 60×60 pixels) on a phone home screen, so it must read as one bold, simple shape.

STYLE: Polished, painterly 3D game-icon rendering with real materials: warm natural wood with visible grain, polished stone, thick red braided cord. Soft light from the upper left, clear highlights and soft shadows so everything reads as thick physical objects. Rich but limited palette: warm wood, ink black, jade green, crimson, a touch of gold.

BACKGROUND: A smooth, dark, warm background filling the whole square: deep charcoal brown (#231E1A) with a gentle lighter glow behind the subject. No pattern, no scene.

COMPOSITION: The subject is centered and fills about 70% of the canvas. Keep about 12% of empty margin on every side (the corners get cut off). Big, simple shapes; very little fine detail.

DO NOT INCLUDE: any text, letters, logo, signature or Chinese/Japanese characters; a border or frame around the image; rounded corners; transparency; cartoon, anime or flat vector style.

SUBJECT: A single wooden ema plaque (a pentagon: rectangle with a pointed gable roof on top) seen straight from the front, hanging from a short thick red cord. Inlaid in its center, filling most of the plaque, one large hexagonal tile split diagonally in two halves: the upper-left half polished white marble with a jade-green rim, the lower-right half polished black obsidian with a crimson rim, joined by a thin line of gold like kintsugi.

Image 3 — app_icon_ema_c:
Create a SQUARE 1024×1024 PNG image, fully opaque (no transparency anywhere), with square corners (do not round the corners, the phone will do that).

PURPOSE: This is the app icon of "Hexiege", a hexagonal strategy board game where Shaolin monks (white marble and jade green) fight a ninja clan (black obsidian and crimson). The game's interface uses Japanese votive wooden plaques (ema) hanging from red cords, on washi paper. The icon will be seen very small (about 60×60 pixels) on a phone home screen, so it must read as one bold, simple shape.

STYLE: Polished, painterly 3D game-icon rendering with real materials: warm natural wood with visible grain, polished stone, thick red braided cord. Soft light from the upper left, clear highlights and soft shadows so everything reads as thick physical objects. Rich but limited palette: warm wood, ink black, jade green, crimson, a touch of gold.

BACKGROUND: A smooth, dark, warm background filling the whole square: deep charcoal brown (#231E1A) with a gentle lighter glow behind the subject. No pattern, no scene.

COMPOSITION: The subject is centered and fills about 70% of the canvas. Keep about 12% of empty margin on every side (the corners get cut off). Big, simple shapes; very little fine detail.

DO NOT INCLUDE: any text, letters, logo, signature or Chinese/Japanese characters; a border or frame around the image; rounded corners; transparency; cartoon, anime or flat vector style.

SUBJECT: Two small wooden ema plaques (pentagons: rectangles with pointed gable roofs) hanging side by side from one red cord, overlapping a little and swaying toward each other. The left plaque carries a polished white marble hexagonal tile with a jade-green rim; the right plaque carries a polished black obsidian hexagonal tile with a crimson rim. A small red paper seal-shaped disc (no characters on it) hangs from the cord between them.
```

## 10. Fichas del Oni ⬜ (3) — `assets/pieces/`

### Oni de Ceniza (Líder) — `oni_oni`
Habilidad: Líder del jefe final. Se desliza hasta 2 casillas.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A huge horned demon (oni) shown from the chest up, facing the viewer straight on (perfect front view). Two thick curved horns, a heavy brow, a wide snarling mouth with two short tusks, a wild mane that dissolves upward into drifting flakes of ash. Massive shoulders, one clawed hand raised in front of the chest. Ancient, enormous, half-awake menace.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the eyes, the inside of the mouth and the cracks in the horns are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: two big horns above a snarling tusked face and broad shoulders.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Gaki — `oni_gaki`
Habilidad: Salta a cualquier casilla del borde y paraliza a una ficha enemiga adyacente.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A gaki (hungry ghost): a gaunt, hunched spirit crouched as if about to leap, three-quarter view facing the viewer. Thin bony limbs, a swollen round belly, a long thin neck, a small head with a tiny pinched mouth and big hollow eyes. One long-fingered hand reaching forward, grasping at the air. Its lower body trails off into a curl of ash smoke instead of feet.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the hollow eyes and the reaching fingertips are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: a hunched starving spirit with a long neck, a reaching claw and a smoky tail.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Ojo del Oni — `oni_oniEye`
Habilidad: Se desliza 1 casilla y anula los efectos de las fichas enemigas cercanas.

```
Create ONE single image. Start immediately, without asking questions.

Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A single giant demon eye carved in stone, seen straight from the front: a heavy-lidded almond-shaped eye with a vertical slit pupil, framed by a thick furrowed brow and deep wrinkles, with short jagged ash tendrils radiating out from the eyelids like dead roots. Watchful, calm, unsettling.

MATERIAL AND STYLE: The whole figure is carved from a single block of rough gray volcanic ash stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing ember-orange cracks (#E0702A) run through the stone like cooling lava, and the iris and the cracks along the tendrils are carved in the same glowing ember orange. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray rim highlight so the figure stays readable on a gray tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole shape is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: one big slit-pupil eye with a heavy brow and radiating tendrils.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; blood or gore; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

---

# Ya en el juego ✅ (referencia)

Todo lo de abajo ya está integrado. Quedan los prompts por si hay que regenerar algo.

## Cómo las dibuja el juego (por qué los prompts piden lo que piden)

- El juego dibuja la piedra hexagonal (blanca o negra según el jugador), el borde con el color de la facción
  y, en los líderes, un anillo dorado. **La imagen va encima**, recortada a un hexágono: por eso tiene que ser
  solo la figura tallada, con fondo transparente, sin placa, marco ni halo.
- Se ve a ~50 px: silueta grande y simple, poco detalle fino.
- Las esquinas se recortan: la figura entra en un círculo central (~80 % del ancho).
- Luz siempre desde arriba a la izquierda, igual que la piedra que dibuja el código.

## Flujo de trabajo

1. Pegá el prompt completo de la ficha. Cada prompt repite toda la descripción del estilo, así sale
   consistente aunque lo corras en otra conversación o en otra cuenta.
2. Si no te convence, pedile cambios puntuales en la misma conversación ("make the beard shorter", etc.).
3. Si la tenés a mano, adjuntá una ficha ya terminada de la misma facción como referencia de estilo: ayuda,
   pero no es obligatorio.
4. Si ChatGPT te devuelve una imagen horizontal o vertical, pedile "make it square 1:1, the figure as tall as it is wide".
5. Descargá el PNG y dejalo en `assets/pieces/` con su nombre (`shaolin_dragon.png`, etc.).
6. Pedile a Claude que lo integre. Corre `tool/prep_piece_art.py`, que limpia los bordes del recorte,
   centra la figura, la pasa a WebP de 512 px, genera una vista previa en `build/piece_previews/` y borra
   el PNG original.

## Fichas Shaolin (mármol blanco + jade verde)

Cada prompt está completo: copialo tal cual. Ver «Flujo de trabajo» arriba.

### Monje Superior (Líder) — `shaolin_monk` ✅ en el juego
Habilidad: Líder, se desliza 1 casilla.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: An elderly Shaolin grandmaster, shown from the chest up, facing the viewer straight on (perfect front view, no 3/4 angle). Shaved, smooth round head. Long beard flowing down to the chest, narrowing to a point. Eyes calmly closed in meditation, serene expression. Both palms pressed together in front of the chest in a prayer gesture. Wearing a simple monk's robe with a wide crossed collar (left over right). A string of large round prayer beads hangs around his neck.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the prayer beads are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: big round head, pointed beard, joined hands.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Dragón Celestial — `shaolin_dragon` ✅ en el juego
Habilidad: Vuela en línea recta sobre fichas contiguas y aterriza en el primer hueco.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A Chinese celestial dragon coiled into a compact, round shape that fills the whole circle. Its head is in the upper center, facing the viewer in a slight three-quarter view, with open jaws, two short swept-back antlers and two whiskers curling outward. The serpentine body loops once around below and behind the head like a coiled spring ready to launch, with the tail tip curling up on one side. One clawed front leg reaches forward under the chin holding a round pearl. A small band of carved swirling clouds fills the bottom of the circle. The pose says power about to shoot forward in a straight line.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the pearl and the dorsal spine ridge are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: big antlered dragon head on top of a round coiled body.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; wings; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Rey Mono — `shaolin_wukong` ✅ en el juego
Habilidad: Se sube encima de fichas (las bloquea); en el suelo copia el movimiento de una ficha adyacente.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: Sun Wukong, the Monkey King, crouching low as if perched on top of something, facing the viewer. Monkey face with a big mischievous grin. A plain headband circlet on his brow. He holds his staff diagonally behind his back, one end above his shoulder and the other near his hip, so it does not stick out to the sides. One knee up, one down; his curled tail rises behind him in a spiral. Playful, agile pose.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the headband circlet and both ends of the staff are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: crouched monkey with a big grin, a diagonal staff behind him and a spiral tail.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Tigre de Mármol — `shaolin_tiger` ✅ en el juego
Habilidad: Embiste 1–3 casillas en línea recta y empuja una ficha enemiga.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A powerful tiger charging straight at the viewer, front view. Head lowered between hunched shoulders, mouth open in a roar showing the fangs, one front paw slammed forward. Its stripes are simple deep carved grooves. Heavy muscular mass that conveys a ramming, pushing force.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the stripes are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: wide lowered head with open roaring mouth between two big shoulders.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; blood; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Grulla de Viento — `shaolin_crane` ✅ en el juego
Habilidad: Salta en línea recta sobre 1 o 2 fichas.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A red-crowned crane caught mid-leap, front view. Both wings raised high above the body in a tall, narrow V shape (the wing tips point up, not out to the sides). Long thin legs pushing off below, as if springing over an obstacle. Neck stretched upward, beak pointing up. Two or three carved wind streaks curving under the wings. Elegant and light.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the crown patch on its head is inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: tall V of raised wings with a long upward neck.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Serpiente de Jade — `shaolin_serpent` ✅ en el juego
Habilidad: Se desliza 1 o 2 casillas; las fichas enemigas adyacentes pierden sus efectos especiales.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A coiled serpent seen from the front. Its body forms a compact round spiral at the bottom; the head rises from the center facing the viewer, mouth closed, calm hypnotic gaze. Two or three faint concentric carved ripples radiate outward from the coil, like a suppressing aura. Smooth and sinuous.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the whole snake body (only the belly scales stay white marble) are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: round spiral coil with a raised head in the middle.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a cobra hood, fangs, extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

## Fichas Ninja (obsidiana negra + vetas carmesí)

Cada prompt está completo: copialo tal cual. Ver «Flujo de trabajo» arriba.

### Gran Shogun (Líder) — `ninja_shogun` ✅ en el juego
Habilidad: Líder, se desliza 1 casilla; una vez por partida intercambia lugar con un Shinobi adyacente.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: An imposing shogun warlord shown from the chest up, facing the viewer straight on (perfect front view). Ornate samurai armor. A kabuto helmet with a tall crescent-shaped maedate crest on the front. A menacing menpo face mask covering the lower face, only the eyes visible. Arms crossed over the chest, the hilt of a katana visible at his side. Commanding, immovable presence.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the crescent crest are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: helmet with a tall crescent crest above a masked face and crossed arms.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a sun disc, halo or ring behind the head; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Shinobi — `ninja_shinobi` ✅ en el juego
Habilidad: Se desliza hasta 4 casillas por el perímetro, incluso por huecos estrechos.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A hooded ninja crouched low in a coiled, ready-to-dash pose, three-quarter view facing the viewer, body compact and folded as if about to slip through a narrow gap. Only the eyes are visible through the mask. One hand forward close to the ground. A short straight sword strapped across the back with the hilt above the shoulder. Two short scarf tails curling up behind the head to suggest swift movement.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the scarf tails are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: crouched hooded figure with a sword hilt above the shoulder and curling scarf tails.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Kunoichi — `ninja_kunoichi` ✅ en el juego
Habilidad: Se desliza hasta 2 casillas y paraliza a una ficha enemiga adyacente por 1 turno.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A female ninja (kunoichi) in a poised, upright stance, three-quarter body, facing the viewer. Hair tied in a high ponytail. Face half-masked, eyes visible. One hand raised in front of her shoulder, close to the body, holding a single long slender needle between two fingers, pointing up and forward. A small burst of carved crimson cracks radiating from the needle tip, like a paralysis mark. Graceful and precise.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the needle tip burst are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: upright figure with a high ponytail and a raised needle near the shoulder.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Tengu — `ninja_tengu` ✅ en el juego
Habilidad: Se teletransporta a cualquier hueco que toque al menos 3 fichas.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A karasu tengu crow-demon, front view, from the waist up. Crow head with a strong beak, a small tokin cap on top. Large wings wrapped around its body like a cloak. One hand holds a feather fan. On its right side, the silhouette breaks apart into a few scattered carved feathers drifting away, as if it is blinking out of existence.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the edges of the drifting feathers are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: beaked crow head over a cloak of folded wings, with feathers scattering off one side.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Kitsune — `ninja_kitsune` ✅ en el juego
Habilidad: Se desliza 1 o 2 casillas (ficha ágil básica).

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A sly kitsune fox sitting upright, front view. Tall sharp ears, narrow cunning eyes. Three fluffy tails fanned out behind it like a crest. A small carved fox-fire flame floating beside its head. Sleek, compact silhouette.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the fox-fire flame are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: sitting fox with tall ears and three tails fanned behind.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Sombra Errante — `ninja_shadow` ✅ en el juego
Habilidad: Se desliza 1 casilla y puede dejar un Sello de Sombra que paraliza a quien caiga ahí.

```
Create a SQUARE image (1:1 aspect ratio, 1024×1024, not landscape, not portrait), PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A faceless hooded wraith made of shadow, front view. Deep hood with two small glowing eyes inside and no visible face. The cloak dissolves into wisps at the bottom. One hand lowered, pressing a round seal sigil (a simple circle with a few radial marks) onto the ground in front of it. Eerie and silent.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the two eyes and the seal sigil are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is compact: its overall shape is about as tall as it is wide (never a long thin horizontal or vertical shape), perfectly centered, and it fills an imaginary circle that covers about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: tall pointed hood with two eyes, wispy cloak bottom and a round seal at its hand.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a skull, gore, a horror face, extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

---

## Emblemas de facción

Tamaño 1024×1024, fondo transparente. Se usan como cabecera de cada facción en el códice y en el dorso de la ficha del visor 3D.

### Templo Shaolin — `assets/emblems/shaolin_emblem.webp` ✅ en el juego (códice)

```
Faction emblem, bas-relief carved in polished white marble with green jade inlay and thin gold leaf edges, a circular medallion containing a stylized lotus flower above a pair of open meditating palms, surrounded by a ring of carved clouds, front view, centered, symmetrical, bold silhouette readable at 48 pixels, soft light from the top-left, isolated on a fully transparent background, 1024x1024 PNG
```

### Sombras Ninja — `assets/emblems/ninja_emblem.webp` ✅ en el juego (códice)

```
Faction emblem, bas-relief carved in polished black obsidian with glowing crimson veins and thin brass edges, a circular medallion containing two crossed kunai over a crescent moon with a four-pointed shuriken at the center, front view, centered, symmetrical, bold silhouette readable at 48 pixels, soft light from the top-left, isolated on a fully transparent background, 1024x1024 PNG
```

---

## Textura de la piedra de las fichas

Es la cara del hexágono sobre la que va la ilustración tallada. El código la recorta al hexágono y le agrega
el canto, el brillo, el borde de facción y el anillo del líder. Por eso se pide un cuadrado plano y sin costuras,
sin forma de ficha. Tiene que contrastar con la figura: la figura es **pulida**, la piedra **mate**. La figura
Shaolin es blanca, así que su piedra es un poco más oscura y cálida; la figura Ninja es negra, así que su piedra es
un gris pizarra un poco más claro. Ya están en el juego como `assets/textures/<facción>_stone.webp`.

### Piedra Shaolin — `assets/textures/shaolin_stone.png` ✅ en el juego

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a white polished marble carving on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed (matte, not polished) pale celadon-green stone, like old temple jade-marble. Base color a soft warm grey-green (around #C9D3C0), slightly darker than white marble so a white carving stands out on it. A few very faint, soft, wide veins in a slightly darker grey-green (#A9B5A4) running diagonally from upper left to lower right. A fine, almost invisible mineral speckle.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong, dark or high-contrast veins; gold, red or any saturated color; a perspective view; a photographic scene.
```

### Piedra Ninja — `assets/textures/ninja_stone.png` ✅ en el juego

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a polished black obsidian carving with crimson veins on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of matte, honed dark slate stone, like the stone of an old Japanese castle wall. Base color a charcoal grey (around #3A3638), slightly lighter than black obsidian so a black carving stands out on it. A very fine, even grain with a subtle layered texture. Two or three hair-thin, very faint deep-red mineral lines (#6E2A30) running diagonally from upper left to lower right, barely visible.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no glossy reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; bright or glowing veins; gold, brass or any saturated color; pure black areas; a perspective view; a photographic scene.
```

---

## Ícono de la app — `assets/icon/app_icon.png` ✅ en el juego

1024×1024, **completamente opaco** (iOS rechaza íconos con transparencia) y sin esquinas redondeadas: el sistema
las recorta. Se ve a 60 px en la pantalla de inicio, así que tiene que leerse con una sola forma.

```
Create a SQUARE 1024×1024 PNG image, fully opaque (no transparency anywhere), with square corners (do not round the corners, the phone will do that).

PURPOSE: This is the app icon of "Hexiege", a hexagonal strategy board game where Shaolin monks (white marble and green jade) fight ninja clans (black obsidian and crimson). It will be seen very small (about 60×60 pixels) on a phone home screen, so it must read as one bold, simple shape.

SUBJECT: Two hexagonal stone game tiles seen from the front, slightly overlapping at the center and tilted a few degrees toward each other, as if they just clashed. The left tile is polished white marble with a thin deep jade-green (#2F9E6E) rim and a small carved lotus in bas-relief on its face. The right tile is polished black obsidian with a thin crimson (#C0404F) rim and a small carved crescent moon in bas-relief on its face. A small soft burst of light where they touch.

BACKGROUND: A smooth, dark, warm background filling the whole square: deep charcoal brown (#231E1A) with a gentle lighter glow behind the tiles. No pattern, no scene.

LIGHTING: Soft light from the upper left; the tiles have clear highlights on their upper-left edges and soft shadow on the lower right, so they read as thick physical stones.

COMPOSITION: The two tiles together are centered and fill about 70% of the canvas. Keep about 12% of empty margin on every side (the corners get cut off). Big, simple shapes; very little fine detail.

DO NOT INCLUDE: any text, letters, logo or Chinese/Japanese characters; people or creatures; a border or frame; rounded corners; transparency; cartoon, anime or flat vector style.
```

## Pantalla de carga — reemplazada por el logo de Oraki Games

Desde que se sumó la marca, la pantalla de carga muestra el logo del estudio (sale de `MarcaPersonal/Lanzamiento/assets/logo`).
El arte de las dos fichas sigue en el ícono de la app. Prompt original, por si se quiere volver a usar:

1024×1024, fondo transparente. Es el logo que aparece centrado mientras abre la app, sobre un color liso que pone
el código (claro u oscuro según el sistema). Debe verse bien sobre los dos.

```
Create a SQUARE 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the splash-screen logo of "Hexiege", a hexagonal strategy board game where Shaolin monks (white marble and green jade) fight ninja clans (black obsidian and crimson). It is shown centered on a plain color while the app opens.

SUBJECT: Two hexagonal stone game tiles seen from the front, slightly overlapping at the center and tilted a few degrees toward each other, as if they just clashed. The left tile is polished white marble with a thin deep jade-green (#2F9E6E) rim and a small carved lotus in bas-relief on its face. The right tile is polished black obsidian with a thin crimson (#C0404F) rim and a small carved crescent moon in bas-relief on its face. No background, no glow behind them.

LIGHTING: Soft light from the upper left; the tiles have clear highlights on their upper-left edges and soft shadow on the lower right, so they read as thick physical stones. Big, simple shapes; very little fine detail.

COMPOSITION: Square 1024×1024, the tiles centered and filling about 60% of the canvas width, the rest fully transparent. Each tile has a thin soft edge highlight so it stays visible on both a light cream background and a near-black background.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or characters, frame, halo or glow.
```


---

## Avatares ✅

Ya en el juego: se eligen tocando tu nombre en el menú. Por ahora están todos disponibles; cuando exista la
tienda, el Novicio y el Jōnin quedan gratis y el resto se compra con jade.

### Novicio (Shaolin, gratis al empezar) — `avatar_novice.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A cheerful young Shaolin novice monk, around 12 years old, shaved head, big curious eyes, holding a bamboo broom over his shoulder, orange robe. Accent color: saffron orange.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Jōnin (Ninja, gratis al empezar) — `avatar_jonin.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A veteran ninja clan leader, face covered by a dark mask showing only sharp narrow eyes, a scar across one eyebrow, a black hood. Accent color: crimson.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Abadesa de jade (Shaolin) — `avatar_abbess.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A calm middle-aged Buddhist nun and kung fu master, shaved head, a single jade bead necklace, piercing wise eyes, one hand raised in a blessing gesture. Accent color: jade green.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Maestro borracho (Shaolin) — `avatar_drunken.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: An old, round-bellied kung fu master with a mischievous grin and rosy cheeks, a long thin mustache, holding a gourd of wine, wobbling in a drunken-boxing pose. Accent color: warm red.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Guerrera del bastón (Shaolin) — `avatar_staff.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A young female Shaolin warrior with a short shaved head, determined expression, a long wooden staff held diagonally behind her shoulders. Accent color: golden yellow.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Rey Mono (Shaolin) — `avatar_monkey.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: The Monkey King Sun Wukong, grinning, golden circlet on his head, a fur collar, a golden staff resting on his shoulder, playful and proud. Accent color: gold.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Kunoichi del abanico (Ninja) — `avatar_fan.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A female ninja with a high ponytail and a lower-face mask, holding an iron war fan open beside her face, cold confident eyes. Accent color: deep violet.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

### Rōnin (Ninja) — `avatar_ronin.webp` ✅

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: A wandering masterless samurai under a wide straw hat that shades his eyes, stubble, a straw toothpick in his mouth, a katana hilt visible at his shoulder. Accent color: rust brown.

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```
