# Prompts para generar assets de arte

Prompts (en inglés) para el generador de imágenes externo. Cada asset tiene: nombre de archivo exacto,
tamaño, fondo, prompt y negative prompt. Fuente de las fichas: `lib/engine/pieces.dart`
(`displayName`, `rulesText`, `glyph` de cada `PieceType`).

Resumen de archivos:

| Archivo | Tamaño | Fondo |
|---|---|---|
| `assets/pieces/shaolin_<type>.png` (6) | 1024×1024 | transparente |
| `assets/pieces/ninja_<type>.png` (6) | 1024×1024 | transparente |
| `assets/emblems/shaolin_emblem.png`, `assets/emblems/ninja_emblem.png` | 1024×1024 | transparente |
| `assets/textures/shaolin_board.png`, `assets/textures/ninja_board.png` | 1024×1024 tileable | opaco |
| `assets/textures/shaolin_menu_bg.png`, `assets/textures/ninja_menu_bg.png` | 2048×2048 (no tileable) | opaco |
| `assets/textures/stone_tile_empty.png` | 512×512 tileable | opaco |

> Nota: al integrarlos habrá que declarar `assets/pieces/`, `assets/emblems/` y `assets/textures/` en `pubspec.yaml`
> (hoy solo está `assets/sfx/`).

---

## 1. Estilo base (pegar al inicio de todos los prompts de fichas)

**Base Shaolin:**

```
Low bas-relief carving in polished white marble with inlaid green jade accents, single subject, front view, perfectly centered, symmetrical composition where possible, bold clean silhouette readable at 40 pixels, deep carved edges with soft directional light from the top-left, subtle ambient occlusion in the grooves, game piece icon, isolated on a fully transparent background, no frame, no border, no hexagon, no base plate, 1024x1024 PNG
```

**Base Ninja:**

```
Low bas-relief carving in polished black obsidian stone with thin glowing crimson veins running through it, single subject, front view, perfectly centered, symmetrical composition where possible, bold clean silhouette readable at 40 pixels, deep carved edges with soft directional light from the top-left, subtle ambient occlusion in the grooves, game piece icon, isolated on a fully transparent background, no frame, no border, no hexagon, no base plate, 1024x1024 PNG
```

**Negative prompt común (fichas y emblemas):**

```
hexagon, frame, border, circle medallion, coin, plaque, base, pedestal, background scene, landscape, text, letters, chinese characters, kanji, watermark, signature, logo, multiple subjects, cropped, cut off, perspective tilt, 3/4 view, photorealistic skin, color painting, cartoon, anime, flat vector, blurry, noisy, low contrast, busy fine detail, drop shadow on ground
```

## 2. Consejos de consistencia

- **Generá primero una ficha de referencia por facción** (recomendado: Tigre de Mármol y Shinobi) hasta que el material,
  la luz y la profundidad del relieve te convenzan. Después usala como **referencia de estilo / image prompt**
  (style reference, `--sref`, IP-Adapter, "use as style" según el generador) para las 5 restantes.
- **Misma seed** para las 6 fichas de una facción, y misma seed entre facciones si el generador lo permite: mantiene
  la luz y el grosor del tallado. Anotá la seed ganadora acá abajo.
- **No cambies el bloque de estilo base** entre fichas; solo cambiá la descripción del sujeto.
- **Luz siempre arriba-izquierda**: el código dibuja el hexágono con la misma convención y un relieve iluminado desde
  otro lado se ve "hundido".
- **Ocupación**: el sujeto debe llenar ~75 % del lienzo, con margen parejo. La ficha lo va a recortar a un hexágono
  inscripto, así que nada importante en las esquinas.
- **Prueba a 40 px**: achicá cada resultado a 40×40 y verificá que la silueta se distinga de las otras 5 de su facción.
  Si no, simplificá (menos detalle interno, contorno más marcado).
- **Transparencia**: si el generador no da alfa real, pedí fondo blanco liso (Shaolin) o gris medio liso (Ninja) y
  removelo después; no uses fondo negro con la piedra negra.
- **Líderes**: llevan un halo/aura tallado detrás (Shaolin: anillo de jade; Ninja: sol rojo partido) que ninguna otra
  ficha tiene. Es la marca de "Líder" a simple vista.
- Las texturas tileables: verificá el tile en 2×2 (sin costuras visibles) antes de exportar.

Seeds usadas: Shaolin `______` · Ninja `______`

---

## 3. Fichas Shaolin (mármol blanco + jade verde)

Para cada una: **Prompt = Base Shaolin + Sujeto**. Negative = común (+ extra si se indica).
Tamaño 1024×1024, fondo transparente.

### Monje Superior (Líder) — `assets/pieces/shaolin_monk.png`
Habilidad: Líder, se desliza 1 casilla.

```
Subject: a serene elder Shaolin grandmaster shown from the chest up, shaved head, long flowing beard, eyes closed in meditation, palms pressed together in prayer, simple robe with folded collar, a large carved halo ring of green jade behind his head marking him as the leader, prayer beads of jade around his neck, calm and immovable presence
```

### Dragón Celestial — `assets/pieces/shaolin_dragon.png`
Habilidad: vuela en línea recta sobre fichas contiguas y aterriza en el primer hueco.

```
Subject: a Chinese celestial dragon in mid-flight, long serpentine body forming a strong horizontal S-curve across the frame as if flying straight ahead, head facing forward with flowing whiskers and antlers, clawed limbs tucked, carved swirling cloud motifs beneath its body, jade pearl held in one claw, sense of fast straight-line flight
```

### Rey Mono — `assets/pieces/shaolin_wukong.png`
Habilidad: se sube encima de fichas (las bloquea); en el suelo copia el movimiento de una ficha adyacente.

```
Subject: Sun Wukong the Monkey King crouched as if perched on top of something, mischievous grin, golden-circlet headband rendered in jade, holding his staff horizontally across his shoulders, one hand raised to his brow scanning around as if studying and mimicking others, curled tail, playful agile pose
```

### Tigre de Mármol — `assets/pieces/shaolin_tiger.png`
Habilidad: embiste 1–3 casillas en línea recta y empuja una ficha enemiga.

```
Subject: a powerful tiger charging straight toward the viewer, head lowered, shoulders hunched, front paw slammed forward, mouth open in a roar, stripes carved as deep grooves inlaid with green jade, muscular mass conveying a ramming, pushing force
```

### Grulla de Viento — `assets/pieces/shaolin_crane.png`
Habilidad: salta en línea recta sobre 1 o 2 fichas.

```
Subject: a red-crowned crane in a leaping pose, wings spread wide and raised, long legs pushing off as if springing over obstacles, neck extended upward, jade crown on its head, a few carved wind streaks curving under its wings, elegant and light
```

### Serpiente de Jade — `assets/pieces/shaolin_serpent.png`
Habilidad: se desliza 1 o 2 casillas; las fichas enemigas adyacentes pierden sus efectos especiales.

```
Subject: a coiled serpent carved mostly in green jade with white marble belly scales, raised head facing forward, calm hypnotic gaze, body coiled into a compact spiral, faint concentric carved ripples radiating outward from the coil like a suppressing aura, smooth and sinuous
```
Negative extra: `cobra hood, fangs dripping, aggressive gore`

---

## 4. Fichas Ninja (piedra negra + vetas rojas)

Para cada una: **Prompt = Base Ninja + Sujeto**. Negative = común (+ extra si se indica).
Tamaño 1024×1024, fondo transparente.

### Gran Shogun (Líder) — `assets/pieces/ninja_shogun.png`
Habilidad: Líder, se desliza 1 casilla; una vez por partida intercambia lugar con un Shinobi adyacente.

```
Subject: an imposing shogun warlord shown from the chest up in ornate samurai armor, kabuto helmet with tall crescent maedate crest, menacing menpo face mask, arms crossed with a katana hilt visible, a large carved red rising-sun disc split in two behind his head marking him as the leader, faint red veins tracing the armor plates, commanding presence
```

### Shinobi — `assets/pieces/ninja_shinobi.png`
Habilidad: se desliza hasta 4 casillas por el perímetro, incluso por huecos estrechos.

```
Subject: a hooded ninja in a low sprinting pose, body turned sideways and compressed as if slipping through a narrow gap, only the eyes visible through the mask, one hand forward, ninjato strapped across the back, scarf tails streaming behind to suggest long swift movement
```

### Kunoichi — `assets/pieces/ninja_kunoichi.png`
Habilidad: se desliza hasta 2 casillas y paraliza a una ficha enemiga adyacente por 1 turno.

```
Subject: a female ninja (kunoichi) in a poised stance, hair tied in a high ponytail, face half-masked, arm extended holding a slender needle or senbon between two fingers, a small carved paralysis mark of red veins radiating from the needle tip, graceful and precise
```

### Tengu — `assets/pieces/ninja_tengu.png`
Habilidad: se teletransporta a cualquier hueco que toque al menos 3 fichas.

```
Subject: a karasu tengu crow-demon with a crow beak and feathered head, small tokin cap, large wings folded around its body, holding a feather fan, its silhouette partly breaking apart into scattered carved feathers on one side as if blinking out of existence, red veins glowing in the eyes
```

### Kitsune — `assets/pieces/ninja_kitsune.png`
Habilidad: se desliza 1 o 2 casillas (ficha ágil básica).

```
Subject: a sly kitsune fox sitting upright, sharp ears, narrow cunning eyes, several fluffy tails fanned behind it, a small carved fox-fire flame floating beside its head traced in red veins, sleek compact silhouette
```

### Sombra Errante — `assets/pieces/ninja_shadow.png`
Habilidad: se desliza 1 casilla y puede dejar un Sello de Sombra que paraliza a quien caiga ahí.

```
Subject: a faceless hooded wraith of shadow, cloak dissolving into wisps at the bottom, two faint red eyes under the hood, one hand lowered pressing a glowing circular red seal sigil onto the ground in front of it, eerie and silent
```
Negative extra: `skull, gore, horror face`

---

## 5. Emblemas de facción

Tamaño 1024×1024, fondo transparente. Negative = común (acá **sí** se permite un medallón circular: sacá
`circle medallion, coin` del negative).

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
