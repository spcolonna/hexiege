# Prompts para generar el arte

Prompts pensados para **ChatGPT** (generador de imágenes), en inglés porque así sigue mejor las instrucciones.
Cada uno es autocontenido: se copia y se pega tal cual.

| Asset | Lo que entregás | Lo que queda en el juego |
|---|---|---|
| 12 fichas | PNG de ChatGPT, fondo transparente | `assets/pieces/<facción>_<tipo>.webp`, 512×512 (~25 KB) |
| 2 emblemas | PNG 1024×1024, transparente | `assets/emblems/` (todavía no se usan en el código) |
| 4 texturas de mesa + piedra vacía | PNG opaco | `assets/textures/` (todavía no se usan en el código) |

---

## 1. Cómo las dibuja el juego (por qué los prompts piden lo que piden)

- El juego dibuja la piedra hexagonal (blanca o negra según el jugador), el borde con el color de la facción
  y, en los líderes, un anillo dorado. **La imagen va encima**, recortada a un hexágono: por eso tiene que ser
  solo la figura tallada, con fondo transparente, sin placa, marco ni halo.
- Se ve a ~50 px: silueta grande y simple, poco detalle fino.
- Las esquinas se recortan: la figura entra en un círculo central (~80 % del ancho).
- Luz siempre desde arriba a la izquierda, igual que la piedra que dibuja el código.

## 2. Flujo de trabajo

1. Abrí **una conversación nueva de ChatGPT por facción** y pegá el prompt de la primera ficha (el líder).
2. Si no te convence, pedile cambios puntuales en la misma conversación ("make the beard shorter", etc.).
3. Para las otras 5 de la facción, en **la misma conversación**, empezá el mensaje con
   *"Same exact style, material, lighting, scale and framing as the previous image."* y pegá el prompt
   completo de la ficha siguiente. Así mantiene la consistencia.
4. Descargá el PNG y dejalo en `assets/pieces/` con su nombre (`shaolin_dragon.png`, etc.).
5. Pedile a Claude que lo integre. Corre `tool/prep_piece_art.py`, que limpia los bordes del recorte,
   centra la figura, la pasa a WebP de 512 px, genera una vista previa en `build/piece_previews/` y borra
   el PNG original.

## 3. Fichas Shaolin (mármol blanco + jade verde)

Cada prompt está completo: copialo tal cual. Ver el flujo de trabajo en la sección 2.

### Monje Superior (Líder) — `shaolin_monk` ✅ generada
Habilidad: Líder, se desliza 1 casilla.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: An elderly Shaolin grandmaster, shown from the chest up, facing the viewer straight on (perfect front view, no 3/4 angle). Shaved, smooth round head. Long beard flowing down to the chest, narrowing to a point. Eyes calmly closed in meditation, serene expression. Both palms pressed together in front of the chest in a prayer gesture. Wearing a simple monk's robe with a wide crossed collar (left over right). A string of large round prayer beads hangs around his neck.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the prayer beads are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: big round head, pointed beard, joined hands.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a halo or ring behind the head; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Dragón Celestial — `shaolin_dragon`
Habilidad: Vuela en línea recta sobre fichas contiguas y aterriza en el primer hueco.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A Chinese celestial dragon flying straight toward the right, seen from the side. Its long serpentine body forms one strong horizontal S-curve across the whole image. The head is in profile on the right, with open jaws, two swept-back antlers and two long whiskers flowing behind. Four short clawed legs tucked against the body; the front claw holds a round pearl. A small band of carved swirling clouds under the belly. The pose says fast, straight-line flight.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the pearl and the dorsal spine ridge are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: long horizontal S-shaped body with antlered head on the right.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; wings; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Rey Mono — `shaolin_wukong`
Habilidad: Se sube encima de fichas (las bloquea); en el suelo copia el movimiento de una ficha adyacente.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: Sun Wukong, the Monkey King, crouching low as if perched on top of something, facing the viewer. Monkey face with a big mischievous grin. A plain headband circlet on his brow. His long staff rests horizontally across his shoulders, both wrists hooked over it. One knee up, one down; his curled tail rises behind him in a spiral. Playful, agile pose.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the headband circlet and both ends of the staff are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: crouched figure with a horizontal staff across the shoulders and a spiral tail.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Tigre de Mármol — `shaolin_tiger`
Habilidad: Embiste 1–3 casillas en línea recta y empuja una ficha enemiga.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A powerful tiger charging straight at the viewer, front view. Head lowered between hunched shoulders, mouth open in a roar showing the fangs, one front paw slammed forward. Its stripes are simple deep carved grooves. Heavy muscular mass that conveys a ramming, pushing force.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the stripes are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: wide lowered head with open roaring mouth between two big shoulders.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; blood; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Grulla de Viento — `shaolin_crane`
Habilidad: Salta en línea recta sobre 1 o 2 fichas.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A red-crowned crane caught mid-leap, front view. Both wings spread wide and raised high in a V shape. Long thin legs pushing off below, as if springing over an obstacle. Neck stretched upward, beak pointing up. Two or three carved wind streaks curving under the wings. Elegant and light.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the crown patch on its head is inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: wide V of raised wings with a long upward neck.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Serpiente de Jade — `shaolin_serpent`
Habilidad: Se desliza 1 o 2 casillas; las fichas enemigas adyacentes pierden sus efectos especiales.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A coiled serpent seen from the front. Its body forms a compact round spiral at the bottom; the head rises from the center facing the viewer, mouth closed, calm hypnotic gaze. Two or three faint concentric carved ripples radiate outward from the coil, like a suppressing aura. Smooth and sinuous.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished white marble, like a temple bas-relief sculpture that has been cut out along its outline. Only the whole snake body (only the belly scales stay white marble) are inlaid with green jade (a deep jade green, #2F9E6E). No other colors: no skin tones, no painted cloth, no gold. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or fur, no wrinkles, no fabric texture. The marble has a soft satin polish with faint gray veining.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: round spiral coil with a raised head in the middle.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a cobra hood, fangs, extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

## 4. Fichas Ninja (obsidiana negra + vetas carmesí)

Cada prompt está completo: copialo tal cual. Ver el flujo de trabajo en la sección 2.

### Gran Shogun (Líder) — `ninja_shogun`
Habilidad: Líder, se desliza 1 casilla; una vez por partida intercambia lugar con un Shinobi adyacente.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: An imposing shogun warlord shown from the chest up, facing the viewer straight on (perfect front view). Ornate samurai armor. A kabuto helmet with a tall crescent-shaped maedate crest on the front. A menacing menpo face mask covering the lower face, only the eyes visible. Arms crossed over the chest, the hilt of a katana visible at his side. Commanding, immovable presence.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the crescent crest are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The bottom of the figure ends in a soft, clean horizontal cut, like the bottom edge of a bust. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: helmet with a tall crescent crest above a masked face and crossed arms.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a sun disc, halo or ring behind the head; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Shinobi — `ninja_shinobi`
Habilidad: Se desliza hasta 4 casillas por el perímetro, incluso por huecos estrechos.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A hooded ninja in a low sprinting pose, seen from the side, running toward the right. Body compressed and leaning forward as if slipping through a narrow gap. Only the eyes are visible through the mask. One hand reaching forward. A short straight sword strapped across the back. Two scarf tails streaming far behind to suggest long, swift movement.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the scarf tails are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: low forward-leaning runner with long scarf tails behind.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Kunoichi — `ninja_kunoichi`
Habilidad: Se desliza hasta 2 casillas y paraliza a una ficha enemiga adyacente por 1 turno.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A female ninja (kunoichi) in a poised, upright stance, three-quarter body, facing the viewer. Hair tied in a high ponytail. Face half-masked, eyes visible. One arm extended to the side, holding a single long slender needle between two fingers. A small burst of carved crimson cracks radiating from the needle tip, like a paralysis mark. Graceful and precise.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the needle tip burst are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: upright figure with a high ponytail and one arm extended holding a needle.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Tengu — `ninja_tengu`
Habilidad: Se teletransporta a cualquier hueco que toque al menos 3 fichas.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A karasu tengu crow-demon, front view, from the waist up. Crow head with a strong beak, a small tokin cap on top. Large wings wrapped around its body like a cloak. One hand holds a feather fan. On its right side, the silhouette breaks apart into a few scattered carved feathers drifting away, as if it is blinking out of existence.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the edges of the drifting feathers are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: beaked crow head over a cloak of folded wings, with feathers scattering off one side.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Kitsune — `ninja_kitsune`
Habilidad: Se desliza 1 o 2 casillas (ficha ágil básica).

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A sly kitsune fox sitting upright, front view. Tall sharp ears, narrow cunning eyes. Three fluffy tails fanned out behind it like a crest. A small carved fox-fire flame floating beside its head. Sleek, compact silhouette.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the eyes and the fox-fire flame are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: sitting fox with tall ears and three tails fanned behind.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

### Sombra Errante — `ninja_shadow`
Habilidad: Se desliza 1 casilla y puede dejar un Sello de Sombra que paraliza a quien caiga ahí.

```
Create a square 1024×1024 PNG image with a fully transparent background (real alpha channel, no white or checkerboard background).

PURPOSE: This is the icon for a game piece in a hexagonal board game. It will be shown very small (about 50×50 pixels) on top of a hexagonal stone tile that the game draws itself. So the image must contain ONLY the carved figure, with nothing behind it.

SUBJECT: A faceless hooded wraith made of shadow, front view. Deep hood with two small glowing eyes inside and no visible face. The cloak dissolves into wisps at the bottom. One hand lowered, pressing a round seal sigil (a simple circle with a few radial marks) onto the ground in front of it. Eerie and silent.

MATERIAL AND STYLE: The whole figure is carved from a single block of polished black obsidian stone, like a temple bas-relief sculpture that has been cut out along its outline. Thin glowing crimson veins (#C0404F) run through the stone, and the two eyes and the seal sigil are carved in the same crimson. No other colors: no skin tones, no painted cloth, no gold. Every outer edge of the figure has a crisp pale-gray polished rim highlight so the dark figure stays readable on a dark tile. The carving is deep and simple, with broad smooth planes and strong grooves that separate the main shapes. Very little fine detail: no individual hair strands or feathers, no fabric texture.

LIGHTING: A single soft light from the upper left. The upper-left edges of the carving catch highlights, and the grooves and lower-right edges fall into soft shadow, so the relief reads clearly as raised 3D stone. No cast shadow on the ground.

COMPOSITION: The figure is perfectly centered and fits inside an imaginary circle that fills about 80% of the canvas width. All four corners must stay completely empty and transparent. The whole figure is visible, nothing is cropped. The silhouette must be bold and instantly recognizable even when shrunk to 50 pixels: tall pointed hood with two eyes, wispy cloak bottom and a round seal at its hand.

DO NOT INCLUDE: any background, frame, border, hexagon, circle, coin, medallion, plaque, base or pedestal; any text, letters or Chinese/Japanese characters; a skull, gore, a horror face, extra figures or objects; photographic skin; cartoon, anime or flat vector style; a perspective tilt.
```

---

## 5. Emblemas de facción

Tamaño 1024×1024, fondo transparente. Todavía no se usan en el código; antes de generarlos conviene
reescribirlos en el formato de las fichas.

### Templo Shaolin — `assets/emblems/shaolin_emblem.png`

```
Faction emblem, bas-relief carved in polished white marble with green jade inlay and thin gold leaf edges, a circular medallion containing a stylized lotus flower above a pair of open meditating palms, surrounded by a ring of carved clouds, front view, centered, symmetrical, bold silhouette readable at 48 pixels, soft light from the top-left, isolated on a fully transparent background, 1024x1024 PNG
```

### Sombras Ninja — `assets/emblems/ninja_emblem.png`

```
Faction emblem, bas-relief carved in polished black obsidian with glowing crimson veins and thin brass edges, a circular medallion containing two crossed kunai over a crescent moon with a four-pointed shuriken at the center, front view, centered, symmetrical, bold silhouette readable at 48 pixels, soft light from the top-left, isolated on a fully transparent background, 1024x1024 PNG
```

---

## 6. Texturas de "mesa de juego física"

Negative común para texturas:

```
text, letters, characters, watermark, logo, people, animals, objects, game pieces, hexagons, grid lines, visible seams, perspective, vignette, strong shadows, lens blur, high contrast hotspots, repeating obvious motifs
```

### Tablero Shaolin — `assets/textures/shaolin_board.png`
1024×1024, **tileable**, opaco. Va detrás de la grilla, así que debe ser tranquilo y de bajo contraste.

```
Seamless tileable texture, top-down flat view of a temple game table surface made of pale light wood planks with fine straight grain, very subtle inlaid thin white marble strips, warm soft even lighting, low contrast, muted cream and honey tones, calm surface for placing game pieces, no objects, 1024x1024
```

### Fondo de menú Shaolin — `assets/textures/shaolin_menu_bg.png`
2048×2048, **no tileable** (se recorta con `BoxFit.cover`, en vertical y horizontal), opaco.

```
Top-down view of a Shaolin temple game table, a large sheet of textured rice paper laid over pale temple wood, white marble border along the edges with carved green jade corner ornaments and thin gold inlay lines, faint ink-wash mountains and clouds barely visible on the rice paper, soft warm natural light, the center area kept clean and empty for UI, elegant and serene, 2048x2048
```

### Tablero Ninja — `assets/textures/ninja_board.png`
1024×1024, **tileable**, opaco. Tranquilo y de bajo contraste.

```
Seamless tileable texture, top-down flat view of a game table surface of glossy black lacquer over charred shou sugi ban wood, the burnt wood grain faintly visible through the lacquer, very subtle deep vermilion undertone in the grain, soft even lighting, low contrast, no reflections of objects, calm surface for placing game pieces, 1024x1024
```

### Fondo de menú Ninja — `assets/textures/ninja_menu_bg.png`
2048×2048, **no tileable**, opaco.

```
Top-down view of a ninja clan game table, central panel of black lacquer with faint charred wood grain, framed by a border of burnt dark wood with vermilion red lacquered trim and engraved brass corner fittings, faint brushed crimson cloud motifs near the edges, dim moody lighting with a soft warm glow, the center area kept clean and empty for UI, 2048x2048
```

### Piedra de ficha vacía — `assets/textures/stone_tile_empty.png`
512×512, **tileable**, opaco. Relleno de las casillas vacías/ficha sin imagen; neutral para ambas facciones.

```
Seamless tileable texture, top-down flat view of smooth weathered grey granite stone, fine speckled grain, very subtle hairline cracks, neutral cool grey, soft even lighting, low contrast, matte finish, 512x512
```
Negative extra: `moss, colored veins, marble veins, red, green`

---

## 7. Textura de la piedra de las fichas

Es la cara del hexágono sobre la que va la ilustración tallada. El código la recorta al hexágono y le agrega
el canto, el brillo, el borde de facción y el anillo del líder. Por eso se pide un cuadrado plano y sin costuras,
sin forma de ficha. Tiene que contrastar con la figura: la figura es **pulida**, la piedra **mate**. La figura
Shaolin es blanca, así que su piedra es un poco más oscura y cálida; la figura Ninja es negra, así que su piedra es
un gris pizarra un poco más claro. Todavía no se usan en el código: hoy la piedra se pinta con un degradé.

### Piedra Shaolin — `assets/textures/shaolin_stone.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a white polished marble carving on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed (matte, not polished) pale celadon-green stone, like old temple jade-marble. Base color a soft warm grey-green (around #C9D3C0), slightly darker than white marble so a white carving stands out on it. A few very faint, soft, wide veins in a slightly darker grey-green (#A9B5A4) running diagonally from upper left to lower right. A fine, almost invisible mineral speckle.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; strong, dark or high-contrast veins; gold, red or any saturated color; a perspective view; a photographic scene.
```

### Piedra Ninja — `assets/textures/ninja_stone.png`

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the stone surface of the game pieces in a hexagonal board game. The game will cut it into a small hexagon (about 50×50 pixels on screen) and place a polished black obsidian carving with crimson veins on top of it. So it must be calm and quiet, and it must not compete with the carving.

SUBJECT: A perfectly flat, straight-on, top-down view of a slab of matte, honed dark slate stone, like the stone of an old Japanese castle wall. Base color a charcoal grey (around #3A3638), slightly lighter than black obsidian so a black carving stands out on it. A very fine, even grain with a subtle layered texture. Two or three hair-thin, very faint deep-red mineral lines (#6E2A30) running diagonally from upper left to lower right, barely visible.

LIGHTING: Completely even, flat, shadowless lighting across the whole image. No highlight spot, no gradient, no vignette, no glossy reflections, no bevel.

DO NOT INCLUDE: any shape, hexagon, border, frame, edge, rim or bevel; any carving, symbol, character, text or logo; cracks, holes, chips or moss; bright or glowing veins; gold, brass or any saturated color; pure black areas; a perspective view; a photographic scene.
```
