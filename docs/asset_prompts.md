# Prompts para generar el arte

Prompts pensados para **ChatGPT** (generador de imágenes), en inglés porque así sigue mejor las instrucciones.
Cada uno es autocontenido: se copia y se pega tal cual.

| Asset | Lo que entregás | Lo que queda en el juego |
|---|---|---|
| 12 fichas | PNG de ChatGPT, fondo transparente | `assets/pieces/<facción>_<tipo>.webp`, 512×512 (~25 KB) |
| 2 emblemas | PNG 1024×1024, transparente | `assets/emblems/<facción>_emblem.webp`, 512×512 |
| Tienda: avatares, marcos, emotes, piedras, tapetes, íconos | ver secciones 6 y 11 a 15 | todavía no se usan en el código |
| 2 texturas de piedra de ficha | PNG opaco, tileable | `assets/textures/<facción>_stone.webp` |
| Ícono de la app | PNG 1024×1024 **opaco** | `ios/…/AppIcon.appiconset` y Android, generados con `flutter_launcher_icons` |
| Pantalla de carga | PNG 1024×1024, transparente | generada con `flutter_native_splash` (config en `flutter_native_splash.yaml`) |

---

## Estado

✅ = ya está en el juego · ⬜ = falta generarlo · ⏸ = idea para la tienda, el código todavía no lo usa.

| Asset | Estado |
|---|---|
| Las 12 fichas (Shaolin y Ninja) | ✅ |
| Piedra de las fichas (Shaolin y Ninja) | ✅ |
| Emblemas de facción | ✅ (se ven en el códice y en el dorso del visor 3D) |
| Ícono de la app (sección 8) | ✅ (el PNG de origen se borró) |
| Pantalla de carga (sección 9) | ✅ ahora muestra el logo de Oraki Games (el arte de las dos fichas quedó en el ícono) |
| Fichas en alta resolución (sección 10) | ⬜ **lo que más suma ahora**: el zoom del visor 3D |
| Tienda: avatares, marcos, emotes, piedras, íconos (secciones 11 a 15) | ⏸ generar cuando se arme la tienda |
| Tapetes de mesa (sección 6) | ⏸ baja prioridad |

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
4. Si ChatGPT te devuelve una imagen horizontal o vertical, pedile "make it square 1:1, the figure as tall as it is wide".
5. Descargá el PNG y dejalo en `assets/pieces/` con su nombre (`shaolin_dragon.png`, etc.).
6. Pedile a Claude que lo integre. Corre `tool/prep_piece_art.py`, que limpia los bordes del recorte,
   centra la figura, la pasa a WebP de 512 px, genera una vista previa en `build/piece_previews/` y borra
   el PNG original.

## 3. Fichas Shaolin (mármol blanco + jade verde)

Cada prompt está completo: copialo tal cual. Ver el flujo de trabajo en la sección 2.

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

## 4. Fichas Ninja (obsidiana negra + vetas carmesí)

Cada prompt está completo: copialo tal cual. Ver el flujo de trabajo en la sección 2.

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

## 5. Emblemas de facción

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

## 6. Tapetes de mesa ⏸ (tienda, baja prioridad)

**Qué es, en criollo:** el "paño" que está *debajo* del tablero durante la partida, como el fieltro verde de
una mesa de póker. Hoy el juego lo pinta por código (un color liso con un degradé). La idea es venderlo en
la tienda como cosmético: el jugador elige sobre qué mesa juega.

**Por qué es baja prioridad:** el tablero hexagonal tapa casi todo el tapete, así que se ve poco. Conviene
hacerlo después de avatares y emotes, que sí se ven en cada partida.

**Cómo es la imagen:** una foto *desde arriba*, sin nada encima, de una superficie lisa (madera, tela,
piedra). Tiene que ser **tileable**: si se ponen dos copias una al lado de la otra no se nota la unión,
porque el juego la repite como baldosas para llenar pantallas de cualquier tamaño. Tranquila y de poco
contraste, para que las fichas resalten.

Plantilla (cambiá solo la línea SURFACE por la de cada tapete de la tabla):

```
Create a square 1024×1024 PNG image, fully opaque, that is a SEAMLESS TILEABLE texture: the left edge must continue perfectly into the right edge and the top edge into the bottom edge, with no visible seams when tiled.

PURPOSE: This is the table surface under a hexagonal board game. Game pieces and a board will be placed on top of it, so it must be calm, low contrast and must not compete with them.

SURFACE: <pegá acá la descripción de la tabla>

VIEW AND LIGHTING: Perfectly flat, straight-on, top-down view. Completely even, soft, shadowless lighting. No highlight spot, no gradient, no vignette.

DO NOT INCLUDE: any object, game piece, hexagon, grid, line pattern, border or frame; any text, letters, symbol or logo; strong or high-contrast details; a perspective view; a photographic scene.
```

| Tapete | Archivo | SURFACE |
|---|---|---|
| Madera de templo | `table_temple_wood.png` | `Pale honey-colored temple wood planks with fine straight grain, running horizontally, planks about 1/4 of the image tall, soft warm tones.` |
| Laca negra | `table_black_lacquer.png` | `Satin black lacquer over wood, the wood grain faintly visible through the lacquer, a very subtle deep red undertone.` |
| Tatami | `table_tatami.png` | `Woven tatami straw mat, fine horizontal weave, soft pale green-gold color, slightly worn.` |
| Seda roja | `table_red_silk.png` | `Deep crimson silk cloth stretched flat, very fine weave, a faint tone-on-tone cloud pattern barely visible.` |
| Pizarra de río | `table_river_slate.png` | `Smooth dark grey river slate, matte, very fine grain, soft cool tones.` |

---

## 7. Textura de la piedra de las fichas

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

## 8. Ícono de la app — `assets/icon/app_icon.png` ✅ en el juego

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

## 9. Pantalla de carga — reemplazada por el logo de Oraki Games

Desde que se sumó la marca, la pantalla de carga muestra el logo del estudio (sale de `MarcaPersonal/Lanzamiento/assets/logo`).
El arte de las dos fichas sigue en el ícono de la app. Prompt original, por si se quiere volver a usar:

1024×1024, fondo transparente. Es el logo que aparece centrado mientras abre la app, sobre un color liso que pone
el código (claro u oscuro según el sistema). Debe verse bien sobre los dos.

```
Same exact style, material and lighting as the app icon, but as a PNG with a fully transparent background (real alpha channel, no white or checkerboard background).

SUBJECT: Only the two clashing hexagonal stone tiles from the app icon — the white marble tile with the jade rim and carved lotus on the left, the black obsidian tile with the crimson rim and carved crescent moon on the right — slightly overlapping at the center. No background, no glow behind them.

COMPOSITION: Square 1024×1024, the tiles centered and filling about 60% of the canvas width, the rest fully transparent. Each tile has a thin soft edge highlight so it stays visible on both a light cream background and a near-black background.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or characters, frame, halo or glow.
```

---

## 10. Fichas en alta resolución ⬜ (no hace falta generar nada nuevo)

El visor 3D de la galería deja hacer zoom, pero las fichas quedaron a 512 px y de cerca se ven algo borrosas.
ChatGPT las generó a 1024 px; el problema es que achicamos esa versión al integrarla.

1. Entrá a las conversaciones de ChatGPT donde generaste las fichas y **volvé a descargar cada imagen final**
   (la que quedó en el juego). No hace falta pedir nada nuevo.
2. Dejalas en `assets/pieces/hires/` con el mismo nombre de siempre (`shaolin_dragon.png`, etc.).
3. Pedile a Claude que las integre. El tablero sigue usando la de 512 (es liviana) y el visor carga la de 1024.

Si alguna conversación ya no está, se puede regenerar con el mismo prompt de la sección 3 o 4. Va a salir
parecida, pero no idéntica a la del juego, así que conviene reemplazar también la de 512.

---

# La tienda ⏸

Idea (ver `docs/pendientes.md`, sección Tienda): todo es **cosmético**, nada da ventaja en la partida. Se compra
con **jade**, una moneda que se gana jugando: victorias, misiones del día, campaña y ladder. Por ahora sin
dinero real. Orden sugerido para generar: avatares → emotes → marcos → íconos de la tienda → piedras → tapetes.

## 11. Avatares ⏸

El retrato del jugador: aparece en el emparejamiento, en el marcador de la partida y en el perfil. Hoy es un
carácter chino (僧 o 将). El juego lo recorta en **círculo** y le pone un marco encima (sección 12). Por eso el
fondo va pintado y lo importante tiene que quedar en el centro.

Estilo distinto al de las fichas a propósito: las fichas son piedra tallada; los avatares son **retratos pintados
en tinta**, para que se distingan de un vistazo.

Flujo: una conversación nueva para todos los avatares. El primero con la plantilla completa; desde el segundo,
*"Same exact style, palette, framing and brush technique as the previous image."* más la plantilla con el
nuevo SUBJECT.

```
Create a SQUARE image (1:1, 1024×1024), fully opaque.

PURPOSE: This is a player avatar for a mobile strategy game about Shaolin monks versus ninja clans. The game will crop it into a CIRCLE and show it small (about 64×64 pixels), so the face must be large, centered and readable at that size.

SUBJECT: <pegá acá el SUBJECT de la tabla>

STYLE: Traditional East Asian ink-wash painting (sumi-e) with confident brush strokes, combined with a limited flat color palette: warm off-white rice paper, deep ink black, and ONE accent color given in the subject. Clean shapes, strong silhouette, expressive but not cartoonish. Head and shoulders portrait, facing the viewer or slightly turned.

COMPOSITION: The face is centered and fills about 55% of the canvas height. The background is a soft, plain rice-paper wash in the accent color, darker toward the edges. Everything important stays inside a centered circle covering 85% of the canvas (the corners will be cut).

DO NOT INCLUDE: any text, letters, signature, seal stamp or Chinese/Japanese characters; a frame, border or circle drawn around the portrait; photographic realism; 3D render; anime style; extra characters.
```

| Avatar | Facción | Archivo | SUBJECT |
|---|---|---|---|
| Novicio | Shaolin | `avatar_novice.png` | `A cheerful young Shaolin novice monk, around 12 years old, shaved head, big curious eyes, holding a bamboo broom over his shoulder, orange robe. Accent color: saffron orange.` |
| Abadesa de jade | Shaolin | `avatar_abbess.png` | `A calm middle-aged Buddhist nun and kung fu master, shaved head, a single jade bead necklace, piercing wise eyes, one hand raised in a blessing gesture. Accent color: jade green.` |
| Maestro borracho | Shaolin | `avatar_drunken.png` | `An old, round-bellied kung fu master with a mischievous grin and rosy cheeks, a long thin mustache, holding a gourd of wine, wobbling in a drunken-boxing pose. Accent color: warm red.` |
| Guerrera del bastón | Shaolin | `avatar_staff.png` | `A young female Shaolin warrior with a short shaved head, determined expression, a long wooden staff held diagonally behind her shoulders. Accent color: golden yellow.` |
| Rey Mono | Shaolin | `avatar_monkey.png` | `The Monkey King Sun Wukong, grinning, golden circlet on his head, a fur collar, a golden staff resting on his shoulder, playful and proud. Accent color: gold.` |
| Jōnin | Ninja | `avatar_jonin.png` | `A veteran ninja clan leader, face covered by a dark mask showing only sharp narrow eyes, a scar across one eyebrow, a black hood. Accent color: crimson.` |
| Kunoichi del abanico | Ninja | `avatar_fan.png` | `A female ninja with a high ponytail and a lower-face mask, holding an iron war fan open beside her face, cold confident eyes. Accent color: deep violet.` |
| Rōnin | Ninja | `avatar_ronin.png` | `A wandering masterless samurai under a wide straw hat that shades his eyes, stubble, a straw toothpick in his mouth, a katana hilt visible at his shoulder. Accent color: rust brown.` |
| Máscara oni | Ninja | `avatar_oni.png` | `A ninja wearing a red horned oni demon mask with fangs, only the mask and hood visible, intimidating. Accent color: blood red.` |
| Espíritu kitsune | Ninja | `avatar_kitsune.png` | `A mysterious figure wearing a white fox kitsune mask with red markings, long silver hair, wisps of blue spirit fire floating around. Accent color: ice blue.` |

Al integrarlos: el juego los pasa a WebP de 256 px. El novicio y el jōnin serían los avatares iniciales gratis.

## 12. Marcos de avatar ⏸

El aro decorativo que rodea al avatar. Se ganan por rango en la ladder o se compran. El centro es un **agujero
transparente** donde el juego pone el avatar.

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel).

PURPOSE: A decorative circular frame for a player avatar in a mobile game. The game places a round portrait in the transparent center hole.

SUBJECT: A circular ring frame. <pegá acá el SUBJECT de la tabla>

SHAPE: The ring is centered. Its outer edge touches about 96% of the canvas width; the inner hole is a perfect circle of about 74% of the canvas width and is COMPLETELY TRANSPARENT. Ornaments may stick out slightly at the top and bottom only, never covering the hole.

LIGHTING: Soft light from the upper left, clear highlights and soft shadows so it reads as a thick physical object.

DO NOT INCLUDE: anything inside the center hole; a background; any text, letters or numbers; a portrait or face.
```

| Marco | Archivo | SUBJECT |
|---|---|---|
| Bronce (rango 1) | `frame_bronze.png` | `Simple polished bronze ring with a thin engraved wave pattern.` |
| Plata y jade (rango 2) | `frame_jade.png` | `Polished silver ring inlaid with four small rounded green jade stones at the top, bottom, left and right.` |
| Oro imperial (rango 3) | `frame_gold.png` | `Ornate gold ring with carved cloud motifs, a small golden dragon head peeking over the top edge.` |
| Obsidiana carmesí (rango máximo) | `frame_obsidian.png` | `Black obsidian ring with glowing crimson cracks, a small brass shuriken ornament at the top and two thin red tassels hanging from the bottom.` |

## 13. Emotes ⏸

Hoy son íconos genéricos (una mano, un pulgar, un rayo). La propuesta es reemplazarlos por **stickers** de dos
personajes chibi: un monjecito y un ninjita. Cada jugador usa el de su facción, y en la tienda se venden otros
sets (por ejemplo, el Rey Mono o la Kitsune). Son 8 por personaje, los mismos 8 que hay hoy.

Flujo: una conversación por personaje. Pegá la plantilla con el primer SUBJECT de la tabla. Para los otros 7,
*"Same exact character, style, line weight and colors as the previous image."* más la plantilla con el nuevo SUBJECT.

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel).

PURPOSE: An emote sticker for a mobile board game. It pops up in a small speech bubble (about 56×56 pixels) when a player reacts during a match, so the emotion must be readable instantly at that size.

CHARACTER: <MONJE o NINJA, copiá una de estas dos líneas>
  MONJE: A chibi little Shaolin monk with a big round shaved head, tiny body, saffron orange robe, a string of green jade beads.
  NINJA: A chibi little ninja with a big round head in a black hood and mask showing only big expressive eyes, tiny body, a red scarf.

EXPRESSION: <pegá acá el SUBJECT de la tabla>

STYLE: Cute, bold sticker style: thick clean dark outline, flat colors with soft cel shading, and a thin white sticker border around the whole silhouette. Big head (about 60% of the height), exaggerated expression.

COMPOSITION: The character is centered and fills about 85% of the canvas. Bold, simple silhouette.

DO NOT INCLUDE: any background, speech bubble, text, letters or characters (except for the GG emote); extra characters; realistic style.
```

| Emote | Archivos | SUBJECT |
|---|---|---|
| Hola | `emote_monk_hello.png` · `emote_ninja_hello.png` | `Waving one hand happily with a big smile, a small bow of the head.` |
| Bien jugado | `emote_monk_nice.png` · `emote_ninja_nice.png` | `Giving a thumbs up with a proud confident smile and one eye winking.` |
| ¡Wow! | `emote_monk_wow.png` · `emote_ninja_wow.png` | `Shocked with huge round eyes and mouth wide open, hands on cheeks, tiny sparkles around the head.` |
| Pensando | `emote_monk_think.png` · `emote_ninja_think.png` | `Thinking hard, eyes looking up, one hand on the chin, a small question mark floating above.` |
| ¡Fuego! | `emote_monk_fire.png` · `emote_ninja_fire.png` | `Fired up with burning determined eyes, fists raised, small orange flames around the body.` |
| Canchero | `emote_monk_smug.png` · `emote_ninja_smug.png` | `Smug and cocky, half-closed eyes, a sly grin, arms crossed.` |
| Uy | `emote_monk_oops.png` · `emote_ninja_oops.png` | `Embarrassed with a nervous smile, a big sweat drop on the forehead, scratching the back of the head.` |
| GG | `emote_monk_gg.png` · `emote_ninja_gg.png` | `Bowing respectfully with both hands holding a small wooden sign that reads exactly "GG" in bold letters.` |

## 14. Piedras de ficha ⏸ (skins)

Variantes de la piedra de las fichas (sección 7). Es el cosmético más barato de producir: una sola imagen
cambia el aspecto de las 6 fichas del jugador. **Usá el prompt de la sección 7 de su facción** y reemplazá
solo el párrafo SUBJECT por el de la tabla. Tiene que seguir contrastando con la figura: clara bajo la figura
negra Ninja, más oscura bajo la figura blanca Shaolin.

| Piedra | Facción | Archivo | SUBJECT |
|---|---|---|---|
| Jade imperial | Shaolin | `shaolin_stone_imperial.png` | `SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed (matte) deep imperial jade, base color a rich muted green (around #6E9A7E), with soft cloudy lighter patches (#8DB39A) and a fine mineral speckle. Dark enough that a white marble carving stands out clearly on it.` |
| Arenisca dorada | Shaolin | `shaolin_stone_sandstone.png` | `SUBJECT: A perfectly flat, straight-on, top-down view of a slab of honed warm golden sandstone (around #B9A27A), very fine sandy grain, a few faint soft horizontal layers in a slightly darker tone (#A48D66).` |
| Laca bermellón | Ninja | `ninja_stone_vermilion.png` | `SUBJECT: A perfectly flat, straight-on, top-down view of worn satin vermilion lacquer (around #8E3B32) over wood, a very faint wood grain showing through, slightly lighter worn patches (#A2493E). Light enough that a black obsidian carving stands out clearly on it.` |
| Hierro oxidado | Ninja | `ninja_stone_iron.png` | `SUBJECT: A perfectly flat, straight-on, top-down view of a plate of dark weathered iron (around #4A4440), matte, with soft rust-brown mottling (#6A4A38) and a fine even grain.` |

## 15. Íconos de la tienda ⏸

Fondo transparente, se ven chicos (24 a 64 px). Mismo estilo de piedra y metal tallado que el resto del juego.
Pedí los tres en la misma conversación: el segundo y el tercero con *"Same exact style, lighting and finish as the previous image."*

```
Create a SQUARE image (1:1, 1024×1024), PNG with a fully transparent background (real alpha channel).

PURPOSE: A user-interface icon for a mobile strategy game about Shaolin monks and ninjas. It will be shown small (24 to 64 pixels), so it needs one bold, simple shape.

SUBJECT: <pegá acá el SUBJECT de la tabla>

STYLE: A physical, slightly stylized 3D object with clear volume, polished materials and a soft light from the upper left. Centered, filling about 80% of the canvas.

DO NOT INCLUDE: any background, shadow on a floor, text, letters or numbers, frame or extra objects.
```

| Ícono | Archivo | SUBJECT |
|---|---|---|
| Moneda de jade | `icon_jade.png` | `A thick round coin carved from glossy green jade (#2F9E6E), with a square hole in the center like an ancient Chinese coin and a thin gold rim.` |
| Cofre | `icon_chest.png` | `A small treasure chest of black lacquered wood with brass corners and a red silk tassel on the lock, the lid slightly open with a soft golden glow inside.` |
| Tienda | `icon_shop.png` | `A small market stall with a curved Asian tiled roof and a red paper lantern hanging from the front.` |
