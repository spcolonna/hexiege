# Hexiege

Juego de estrategia abstracta por facciones sobre tablero hexagonal sin límites (inspirado en *Hive*).
Diseño original: [`../HexaGame.md`](../HexaGame.md).

## Estado: MVP
- Facciones: **Templo Shaolin** y **Sombras Ninja**, 11 fichas cada una.
- Modos: **Buscar partida** (por puntos, contra rivales simulados por la IA), **Local** (Pass & Play) y tutorial. Sin backend.

## Correr
```
flutter test          # motor de reglas (incluye 300 partidas aleatorias)
flutter run           # en simulador iOS / emulador Android
dart run tool/balance.dart 60 normal                  # IA vs IA en paralelo: victorias por facción, Asedio, quién empieza
dart run tool/balance.dart 60 easy 300 --shinobi=3 --detalle  # prueba una variante de reglas (ver opciones en el archivo)
dart run tool/arena.dart hard normal 10                # nivel contra nivel: victorias y ms por jugada
```

## IA (`lib/engine/ai.dart`)
- Turnos candidatos = acción principal, o habilidad (las 2–5 mejores) + acción principal.
- Cinco niveles: **Aprendiz** y **Fácil** (greedy con ruido), **Normal** (minimax de 2 capas, el rival sin habilidades), **Difícil** y **Maestro** (alfa-beta por turnos completos con profundización iterativa, haz acotado y tiempo límite de 1,2 s / 2,5 s; el rival también usa habilidades).
- Medido con `tool/arena.dart`: Difícil le gana a Normal 4–0 (2 sin terminar, ~0,35 s por jugada) y Maestro a Difícil 3–1.
- Evaluación: presión sobre los Líderes (vecinos ocupados, inmovilizado, Rey Mono encima), desarrollo, movilidad aproximada, parálisis y cercanía de las fichas al Líder rival.
- Castiga volver a posiciones que ya dejó (evita idas y vueltas que estancaban la partida).
- Corre en un isolate para no congelar la UI.

## Balance (`lib/engine/rules.dart`, `tool/balance.dart`)
Las reglas ajustables viven en `Rules`; `Rules.standard` es el juego oficial y `Rules.classic` el prototipo. Se ajustaron con miles de partidas IA vs IA por nivel.

| Problema medido (reglas del prototipo) | Cambio |
|---|---|
| 68–86% de partidas sin terminar en 200 turnos: Kawarimi y Jade despegaban atacantes del propio Líder cada 3 turnos | Habilidad con **3 usos por partida** (se mantiene la recarga de 3) |
| Sin habilidades, Ninja ganaba 67–91%: Shinobi y Tengu llegaban junto al Líder rival en el 72% de sus jugadas (Shaolin ~25%) | **Shinobi**: hasta 4 casillas. **Tengu**: hueco que toque 3 fichas. **Grulla**: salta 1 o 2 |
| Partidas trabadas con el Líder a 5 vecinos y el último hueco inalcanzable | **Asedio**: desde la ronda 35 alcanzan 5 lados; en la ronda 50, empate |
| La IA iba y venía con la misma ficha | Castigo por repetir posiciones |

Se descartó desempatar por "Líder más rodeado" al llegar al límite: quien movía último ganaba 24 de 28 veces.

Resultado con las reglas oficiales (Shaolin / Ninja, resto empates o límite):

| Nivel | Shaolin | Ninja | Empieza y gana | Terminan en Asedio |
|---|---|---|---|---|
| Aprendiz (120) | 22% | 53% | 46% | 33% |
| Fácil (120) | 38% | 42% | 52% | 38% |
| Normal (120) | 34% | 40% | 47% | 37% |
| Difícil (70) | 44% | 27% | 52% | 33% |
| Maestro (56) | 38% | 61% | 55% | 9% |

Pendiente: en Maestro Ninja gana ~60–66% en todas las variantes probadas (también sin habilidades, con 1 Tengu o Shinobi a 3), así que la ventaja no viene de esas piezas. En Difícil el ruido es de ±15 puntos con ~60 partidas.

## Visual y game feel (`lib/ui/`)
- **Temas** (`theme/hex_theme.dart`): claro "papel de arroz" y oscuro "tinta". Son un `ThemeExtension`, así que el cambio en plena partida es un fundido (botón sol/luna). Preferencia persistida en `theme/settings.dart` (tema, sonido, vibración, nombre).
- **Cosméticos a futuro**: una arena/skin nueva = otra instancia de `HexTheme` (fondo, materiales de fichas). `PlayerProfile` (nick, avatar, IA) y `Emote` (vectoriales, no emojis del sistema) ya son modelos separados de la UI.
- **Layout**: tablero a pantalla completa; arriba el oponente, abajo vos + mano + acciones (listo para avatares y emotes online).
- **Animación por diff** (`fx/board_fx.dart`): se compara el tablero antes/después de cualquier acción (tuya, de la IA o una habilidad) y se anima sola: caída con gravedad al colocar, levantar → arco → caer al mover, rebote al asentarse, onda + polvo, temblor de cámara, empujón a las vecinas. Parálisis = escarcha, sello = estampado.
- **Fichas con volumen** (`fx/piece_renderer.dart`): canto, sombra que se difumina con la altura, vetas y brillo.
- **Sonido** (`fx/sfx.dart`): efectos sintetizados por `tool/gen_sfx.py` (golpe grave al colocar, más liviano al mover, "clack" al apilar, campana de habilidad, gong de victoria). Para regenerarlos: `python3 tool/gen_sfx.py`.

## Onboarding y tutorial
- **Primer arranque** (`ui/onboarding_screen.dart`): 3 pantallas (objetivo animado, facciones, nombre) y la invitación al tutorial. Se muestra una sola vez (`AppSettings.onboarded`).
- **Tutorial** (`tutorial/lessons.dart` + `GameScreen.tutorial`): 7 lecciones de una jugada sobre escenarios armados (colocar, Líder, One-Hive, movimiento, victoria, habilidad). El Sensei explica y marca la casilla clave; si la jugada no es la pedida, las fichas vuelven a su lugar y se reintenta. Al final ofrece una partida contra el Sensei en Fácil.
- Agregar una lección = otro `Lesson` en la lista; `test/tutorial/lessons_test.dart` verifica que cada una se pueda resolver en una acción.

## Buscar partida (`lib/match/`)
- **Sin selector de dificultad**: el nivel de la IA sale de los puntos del jugador (`LadderRecord`, cinco rangos de Novicio a Leyenda, uno por nivel) y se corre un escalón por rachas: 3+ victorias seguidas → más difícil; 3+ derrotas → más fácil (5+ → dos escalones). Ganar suma 25 (+5 por victoria en racha, hasta +15); perder resta 20.
- **Emparejamiento detrás de una interfaz** (`Matchmaker`): hoy `BotMatchmaker` simula la espera (2,5–7 s, ampliando el rango de puntos) y arma un rival con nick, avatar, facción y puntos creíbles (`Opponent.bot` = nivel de IA). El online real será otro `Matchmaker` que devuelva rivales con `bot == null`; la UI no cambia.
- Flujo: radar de búsqueda → presentación VS con quién empieza → cuenta regresiva → partida sin deshacer, con abandono (cuenta como derrota) → resultado con puntos animados, cambio de rango y "Buscar otra". El rival piensa con tiempos de persona (1–2,7 s).

## Estructura
- `lib/engine/` — reglas en Dart puro (sin Flutter): `hex.dart`, `board.dart`, `moves.dart`, `game_state.dart`, `pieces.dart`, `rules.dart` (parámetros de balance).
- `lib/ui/` — bienvenida, menú, pantalla de juego y `BoardPainter` (CustomPainter).
- `lib/tutorial/` — lecciones del tutorial.
- `lib/match/` — puntos/rachas (`ladder.dart`) y emparejamiento (`matchmaker.dart`).
- `test/engine/` — tests del motor.

## Interpretaciones de reglas (MVP)
- Turno = 1 acción principal (colocar o mover) + habilidad de facción opcional (antes o después).
- Colocación al estilo Hive: tocando solo fichas propias. Líder obligatorio en el 4.º turno; sin Líder no se mueve ni se usa la habilidad.
- Libertad de movimiento: nadie se desliza por un hueco estrecho, salvo el Shinobi.
- Habilidad: 3 usos por partida; tras usarla vuelve a estar disponible 3 turnos propios después.
- Asedio: desde la ronda 35 (un turno de cada uno = una ronda) el Líder cae con 5 lados ocupados. Al terminar la ronda 50, empate.
- **Rey Mono**: al copiar a otra ficha copia solo el movimiento, no sus efectos.
- **Tigre**: empuja automáticamente si termina frente a una enemiga sola en su celda y el empuje no rompe la colmena.
- **Serpiente**: anula efectos de unidad de enemigas adyacentes (parálisis, empuje, sello, intercambio del Shogun). No afecta habilidades de facción.
- **Kitsune**: sin disfraz en el MVP (rompería "cero azar" y no se puede ocultar en Pass & Play).
- **Sello de Sombra**: visible; uno activo por jugador; paraliza 1 turno a la ficha enemiga que caiga ahí.
- **Kawarimi / Meditación de Jade**: nunca sobre Líderes; solo fichas perimetrales (solas en su celda, removibles sin romper la colmena).
