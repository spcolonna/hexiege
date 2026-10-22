# Hexiege

Juego de estrategia abstracta por facciones sobre tablero hexagonal sin límites (inspirado en *Hive*).
Diseño original: [`../HexaGame.md`](../HexaGame.md).

## Estado: MVP
- Facciones: **Templo Shaolin** y **Sombras Ninja**, 11 fichas cada una.
- Modos: **Buscar partida** (por puntos, contra rivales simulados por la IA), **Local** (Pass & Play), tutorial, **Problemas**, **Desafíos** y **Campaña**. Sin backend.

## Correr
```
flutter test          # motor de reglas (incluye 300 partidas aleatorias)
flutter run           # en simulador iOS / emulador Android
dart run tool/balance.dart 60 normal                  # IA vs IA en paralelo: victorias por facción, Asedio, quién empieza
dart run tool/balance.dart 60 easy 300 --shinobi=3 --detalle  # prueba una variante de reglas (ver opciones en el archivo)
dart run tool/arena.dart hard normal 10                # nivel contra nivel: victorias y ms por jugada
dart run tool/puzzles.dart [p12]                       # dibuja cada problema y lista sus soluciones
dart run tool/puzzle_gen.dart 1400 15                  # busca problemas "cerco en 2" en partidas IA vs IA
dart run tool/stages.dart normal 12 c01 s6             # ¿se puede ganar? un jugador IA contra desafíos o batallas
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
| En Maestro Ninja ganaba ~70% (ver abajo) | **Tengu**: puede llegar junto al Líder rival, pero no cerrar el cerco con el teletransporte (`TenguNearLeader.notClosing`) |
| Ninja seguía arriba en todos los niveles (Difícil 24% / 65% con 80 partidas) | **Shinobi**: hasta **3** casillas (antes 4) |

Se descartó desempatar por "Líder más rodeado" al llegar al límite: quien movía último ganaba 24 de 28 veces.

Resultado con las reglas oficiales (Shaolin / Ninja, resto empates o límite):

| Nivel | Shinobi 4 (antes) | **Shinobi 3 (actual)** | Terminan en Asedio |
|---|---|---|---|
| Aprendiz (200) | 28% / 51% | 25% / 41% | 38% |
| Fácil (200) | 38% / 52% | 40% / 41% | 45% |
| Normal (200) | 25% / 39% | 28% / 35% | 43% |
| Difícil (80) | 24% / 65% | 45% / 40% | 35% |
| Maestro (60) | 36% / 54% | 32% / 50% | 45% |

Con ~60 partidas el ruido es de ±15 puntos (Maestro con las mismas reglas dio 77%, 66% y 66% para Ninja en tres corridas).

### Ventaja Ninja en Maestro
`--detalle` cuenta cada efecto (usos, partidas en que aparece, % de victoria de quien lo usa, usos en los 2 últimos turnos antes de ganar), qué ficha cierra el cerco ganador y la profundidad media de la búsqueda. Para ablaciones: `--sin-intercambio`, `--sin-paralisis`, `--sin-sello`, `--tengu-lider=allowed|notClosing|never`, `--shinobi-lider=0`.

Maestro, 28 partidas por orden (Shaolin / Ninja):

| Variante | Maestro | Lectura |
|---|---|---|
| Reglas previas | 18–27% / 66–77% | — |
| Sin intercambio del Shogun | 25% / 66% | Se usa 5 veces en 56 partidas: irrelevante |
| Sin parálisis de la Kunoichi | 14% / 82% | Gana quien paraliza ~73%, igual que la media Ninja: no decide |
| Sin Sello de Sombra | 25% / 70% | 1 sello activado en 56 partidas |
| Shinobi sin cruzar compuertas junto al Líder | 29% / 55% | Algo, dentro del ruido |
| Tengu nunca junto al Líder | 52% / 39% | Corrige, pero hunde a Ninja en Fácil–Difícil (16–23%) |
| **Tengu sin cerrar el cerco** | **36% / 54%** | Elegida: corrige Maestro sin tocar los demás niveles |
| Tengu sin cerrar + Shinobi | 34% / 48% | Igual a la anterior dentro del ruido; no compensa otra regla |

Causa: el cierre del cerco. El Tengu y el Shinobi cerraban 22 de las 37 victorias Ninja en Maestro: el último hueco junto al Líder casi siempre toca 3 fichas, así que el Tengu llegaba desde cualquier lado. La búsqueda a 4 turnos de Maestro lo planifica; los niveles bajos lo encuentran menos. No era una asimetría de la IA: la profundidad media es la misma para las dos facciones (~2,9 turnos en Maestro, ~2,6 en Difícil).

## Visual y game feel (`lib/ui/`)
- **Temas** (`theme/hex_theme.dart`): claro "papel de arroz" y oscuro "tinta". Son un `ThemeExtension`, así que el cambio en plena partida es un fundido (botón sol/luna). Preferencia persistida en `theme/settings.dart` (tema, sonido, vibración, nombre).
- **Cosméticos a futuro**: una arena/skin nueva = otra instancia de `HexTheme` (fondo, materiales de fichas). `PlayerProfile` (nick, avatar, IA) y `Emote` (vectoriales, no emojis del sistema) ya son modelos separados de la UI.
- **Layout**: tablero a pantalla completa; arriba el oponente, abajo vos + mano + acciones (listo para avatares y emotes online).
- **Animación por diff** (`fx/board_fx.dart`): se compara el tablero antes/después de cualquier acción (tuya, de la IA o una habilidad) y se anima sola: caída con gravedad al colocar, levantar → arco → caer al mover, rebote al asentarse, onda + polvo, temblor de cámara, empujón a las vecinas. Parálisis = escarcha, sello = estampado.
- **Claridad de efectos** (`engine/events.dart`): con `GameState.recordEvents` cada acción deja eventos (colocar, mover, empuje, parálisis, sello, anulación de la Serpiente, habilidades). Las copias de la IA no los registran. La UI los usa para:
  - un aviso bajo el rival con lo que se disparó en la última acción (propia o del rival);
  - el **Registro** (botón en la barra): la partida por ronda; tocar una jugada la resalta;
  - el resaltado del último turno completo (acción + habilidad + efectos, no solo la última acción).
  - Además: las fichas cuyo efecto anula una Serpiente rival llevan un anillo punteado de jade con 蛇, y los Shinobis con los que puede intercambiarse el Shogun se marcan en dorado con ⇄.
- **Fichas con volumen** (`fx/piece_renderer.dart`): canto, sombra que se difumina con la altura, vetas y brillo.
- **Sonido** (`fx/sfx.dart`): efectos sintetizados por `tool/gen_sfx.py` (golpe grave al colocar, más liviano al mover, "clack" al apilar, campana de habilidad, gong de victoria). Para regenerarlos: `python3 tool/gen_sfx.py`.

## Onboarding y tutorial
- **Primer arranque** (`ui/onboarding_screen.dart`): 3 pantallas (objetivo animado, facciones, nombre) y la invitación al tutorial. Se muestra una sola vez (`AppSettings.onboarded`).
- **Tutorial** (`tutorial/lessons.dart` + `GameScreen.tutorial`): 7 lecciones de una jugada sobre escenarios armados (colocar, Líder, One-Hive, movimiento, victoria, habilidad). El Sensei explica y marca la casilla clave; si la jugada no es la pedida, las fichas vuelven a su lugar y se reintenta. Al final ofrece una partida contra el Sensei en Fácil.
- Agregar una lección = otro `Lesson` en la lista; `test/tutorial/lessons_test.dart` verifica que cada una se pueda resolver en una acción.

## Un jugador (`lib/solo/`)
- Entrada única desde el menú: **Un jugador** (`ui/solo_screen.dart`) muestra el progreso total y por modo, y **Continuar** abre la próxima etapa disponible (campaña Shaolin, luego Ninja, desafíos y problemas).
- Todo el contenido es una `Stage`: posición inicial (`build`), objetivo, facciones y nivel de IA. `GameScreen.stage` la juega y `StageListScreen` la lista; se desbloquean de a una y el progreso se guarda en `AppSettings` (`cleared`).
- **Problemas** (`puzzles.dart`): 18 "cerco en N" (12 en 1 turno, uno por ficha o habilidad, y 6 en 2). El rival defiende con `solver.dart`, que busca por fuerza bruta la respuesta que evita el cerco. `test/solo/puzzles_test.dart` exige que cada uno tenga cerco forzado en N y no antes. Los de 2 turnos p13–p18 salieron de `tool/puzzle_gen.dart`.
- **Desafíos** (`challenges.dart`): 10 partidas contra la IA con reglas u objetivos especiales: límite de rondas, Asedio temprano, sin habilidad, sin Dragones, 3 Tengu rivales, espejos Shaolin/Ninja, una posición de arranque con el Monje rodeado y el nivel Maestro. Ganar los supera; empatar o llegar al límite, no. Se calibraron simulando un jugador Normal contra cada uno (ganables, ninguno trivial).
- **Campaña** (`campaign.dart`, `ui/campaign_screen.dart`): una historia por facción, 8 batallas cada una con texto previo, de Aprendiz a Maestro. Mezcla reglas normales, rivales sin habilidad, emboscadas (el Líder empieza con 3 fichas enemigas al lado), Asedio temprano, manos reforzadas y habilidades rápidas.

## Buscar partida (`lib/match/`)
- **Sin selector de dificultad**: el nivel de la IA sale de los puntos del jugador (`LadderRecord`, cinco rangos de Novicio a Leyenda, uno por nivel) y se corre un escalón por rachas: 3+ victorias seguidas → más difícil; 3+ derrotas → más fácil (5+ → dos escalones). Ganar suma 25 (+5 por victoria en racha, hasta +15); perder resta 20.
- **Emparejamiento detrás de una interfaz** (`Matchmaker`): hoy `BotMatchmaker` simula la espera (2,5–7 s, ampliando el rango de puntos) y arma un rival con nick, avatar, facción y puntos creíbles (`Opponent.bot` = nivel de IA). El online real será otro `Matchmaker` que devuelva rivales con `bot == null`; la UI no cambia.
- Flujo: radar de búsqueda → presentación VS con quién empieza → cuenta regresiva → partida sin deshacer, con abandono (cuenta como derrota) → resultado con puntos animados, cambio de rango y "Buscar otra". El rival piensa con tiempos de persona (1–2,7 s).

## Estructura
- `lib/engine/` — reglas en Dart puro (sin Flutter): `hex.dart`, `board.dart`, `moves.dart`, `game_state.dart`, `pieces.dart`, `rules.dart` (parámetros de balance).
- `lib/ui/` — bienvenida, menú, pantalla de juego y `BoardPainter` (CustomPainter).
- `lib/tutorial/` — lecciones del tutorial.
- `lib/match/` — puntos/rachas (`ladder.dart`) y emparejamiento (`matchmaker.dart`).
- `lib/solo/` — contenido de un jugador: etapas, problemas y el solver de cercos.
- `test/engine/` — tests del motor.

## Interpretaciones de reglas (MVP)
- Turno = 1 sola acción: colocar, mover (incluye el intercambio del Shogun) o usar la habilidad de facción. El turno se cierra solo; si no hay ninguna acción legal, se pasa automáticamente.
- Colocación al estilo Hive: tocando solo fichas propias. Líder obligatorio en el 4.º turno; sin Líder no se mueve ni se usa la habilidad.
- Libertad de movimiento: nadie se desliza por un hueco estrecho, salvo el Shinobi.
- Habilidad: 3 usos por partida; tras usarla vuelve a estar disponible 3 turnos propios después.
- Asedio: desde la ronda 35 (un turno de cada uno = una ronda) el Líder cae con 5 lados ocupados. Al terminar la ronda 50, empate.
- **Rey Mono**: al copiar a otra ficha copia solo el movimiento, no sus efectos.
- **Tigre**: empuja automáticamente si termina frente a una enemiga sola en su celda y el empuje no rompe la colmena.
- **Serpiente**: anula efectos de unidad de enemigas adyacentes (parálisis, empuje, sello, intercambio del Shogun). No afecta habilidades de facción.
- **Kitsune**: sin disfraz en el MVP (rompería "cero azar" y no se puede ocultar en Pass & Play).
- **Sello de Sombra**: visible; uno activo por jugador; paraliza 1 turno a la ficha enemiga que caiga ahí.
- **Tengu**: puede teletransportarse junto al Líder rival, pero no al hueco que completaría el cerco.
- **Kawarimi / Meditación de Jade**: nunca sobre Líderes; solo fichas perimetrales (solas en su celda, removibles sin romper la colmena).
