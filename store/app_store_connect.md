# Hexiege — App Store Connect (versión 1.0 a revisión)

Datos del build: bundle `com.spcolonna.hexiege`, equipo RZGQPAGH53 (Sebastian Perez),
versión 1.0.0, iOS 15+, iPhone y iPad, Game Center activo, cifrado exento
(`ITSAppUsesNonExemptEncryption = NO`). La IPA sale de `tool/build_ipa.sh` y se sube con
Transporter. Cada build nuevo sube el número en `pubspec.yaml` (`1.0.0+N`).

Idiomas del juego: inglés (por defecto si el sistema no tiene ninguno de los otros),
español, chino simplificado y japonés.

---

## 1. Información de la app (General → Información de la app)

| Campo | Valor |
|---|---|
| Idioma principal | English (U.S.) |
| Categoría principal | Juegos → Estrategia |
| Categoría secundaria | Juegos → Juegos de mesa |
| Derechos de contenido | No contiene, muestra ni accede a contenido de terceros |
| Clasificación por edad | ver §5 |

**Localizaciones a agregar** (menú de idioma arriba a la derecha → +): English (U.S.),
Spanish (Mexico), Spanish (Spain), Chinese (Simplified), Japanese. Spanish (Spain) lleva
el mismo texto que México: sin ella, la tienda de España muestra la ficha en inglés.

Nombre y subtítulo (máx. 30 caracteres cada uno):

| Idioma | Nombre | Subtítulo |
|---|---|---|
| en | `Hexiege` | `Surround the enemy Leader` |
| es-MX / es-ES | `Hexiege` | `Rodea al Líder enemigo` |
| zh-Hans | `Hexiege` | `包围敌方首领` |
| ja | `Hexiege` | `敵の首領を包囲せよ` |

## 2. Privacidad de la app

- URL de la política (todas las localizaciones): `https://spcolonna.github.io/hexiege/privacidad.html`
- Prácticas de datos → **Sí, recopilamos datos** (por Sentry):
  - **Diagnóstico → Datos de fallos** y **Otros datos de diagnóstico**.
  - En cada uno: uso = **Funcionalidad de la app**; vinculado a la identidad = **No**;
    rastreo = **No**.
- Nada más: sin contacto, identificadores, uso ni compras (StoreKit y Game Center son de
  Apple y no se declaran).

## 3. Precio y disponibilidad

- Precio: **Gratis**.
- Disponibilidad: todos los países **menos China continental**. Allí un juego necesita
  licencia (ISBN) del gobierno y Apple lo rechaza sin ella. El chino simplificado igual
  sirve para Singapur, Malasia y la diáspora.
- Apps para iPhone/iPad en Mac con Apple silicon: desmarcar (no está probado).

## 4. Compra dentro de la app (Monetización → Compras dentro de la app)

`hexiege_story`, no consumible, USD 1,99. Tiene que estar en **Listo para enviar** con:

| Idioma | Nombre visible | Descripción (máx. 55) |
|---|---|---|
| en | `Full story` | `Acts II–IV of both campaigns and The Seal.` |
| es-MX / es-ES | `Historia completa` | `Actos II a IV de ambas campañas y El Sello.` |
| zh-Hans | `完整故事` | `两场战役的第二至第四幕，以及结局《封印》。` |
| ja | `完全版ストーリー` | `両陣営の第二幕〜第四幕と、真の結末「封印」。` |

- Captura de revisión: la hoja de desbloqueo (Ajustes → «Full story · $1.99»).
- Nota de revisión: `Unlocks battles 7–24 of both campaigns and the finale. Open it from Settings → "Full story". Restore purchases is right below.`
- **Acuerdos, impuestos y banca**: el acuerdo de Apps de pago tiene que estar activo, si no
  StoreKit no devuelve el producto.

## 5. Clasificación por edad (cuestionario)

Responder **Ninguno / No** a todo salvo:
- **Violencia de dibujos animados o fantasía: Poco frecuente/leve.** La historia muestra
  peleas entre monjes y ninjas, sin sangre. Resultado esperado: **9+**.
- Funciones: sin contenido generado por usuarios, sin mensajería, sin navegador web, sin
  publicidad, sin juegos de azar, sin cajas de botín. Controles parentales: No.

(Si preferís 4+, marcar la violencia como «Ninguna»; es defendible porque las partidas son
abstractas, pero el cómic tiene combates.)

## 6. Versión 1.0 (la página de la versión, por idioma)

| Campo | Valor |
|---|---|
| Capturas iPhone 6,9" | `store/screenshots/en/` (1320×2868), las 5 en orden. Sirven para todos los idiomas. |
| Capturas iPad 13" | `store/screenshots/en_ipad/` (2064×2752), las 5 en orden. **Obligatorias** porque la app corre en iPad. |
| URL de soporte | `https://spcolonna.github.io/hexiege/privacidad.html` (tiene el correo de contacto) |
| URL de marketing | vacío |
| Copyright | `2026 Oraki Games` |
| Build | 17 (o el último subido) |
| Inicio de sesión | **No requerido** (desmarcar «Se requiere iniciar sesión») |
| Contacto | tu nombre, `orakigames.uy@gmail.com`, teléfono |
| Lanzamiento | Manual (lo publicás vos cuando Apple lo aprueba) |

Game Center: en la página de la versión, activar **Game Center** y agregar los 8 logros y
las 2 clasificaciones de §6b (tienen que existir antes en Funciones → Game Center).

**Notas para el revisor** (App Review Information → Notes):

```
Hexiege is a turn-based strategy board game. No account or sign-in is needed.
The in-app purchase "Full story" (hexiege_story, non-consumable) unlocks battles 7-24 of
both story campaigns and the finale. To see it: Settings (gear icon in the main menu) ->
"Full story". "Restore purchases" is the button right below it. It also appears after
winning battle 6 of a campaign. Game Center is optional (achievements and leaderboards).
```

### Texto promocional (máx. 170, se puede cambiar sin revisión)

- **en:** `Two rival schools, one buried secret. Surround the enemy Leader in a hex strategy game with no luck and no ads.`
- **es:** `Dos escuelas rivales, un secreto enterrado. Rodea al Líder enemigo en un juego de estrategia hexagonal sin azar y sin anuncios.`
- **zh-Hans:** `两大流派，一个尘封的秘密。在这款没有运气、没有广告的六角策略游戏中，包围敌方首领。`
- **ja:** `二つの流派、ひとつの隠された秘密。運も広告もない六角形の戦略ゲームで、敵の首領を包囲せよ。`

### Palabras clave (máx. 100 caracteres, separadas por coma, sin espacios)

- **en:** `strategy,board game,hex,hive,ninja,shaolin,kung fu,puzzle,abstract,tactics,turn based,offline,2 player`
  → si pasa de 100, quitar `2 player`.
- **es:** `estrategia,juego de mesa,hexágono,ninja,shaolin,kung fu,puzle,táctica,por turnos,sin conexión,2 jugadores`
- **zh-Hans:** `策略,棋类,六角,忍者,少林,功夫,解谜,战术,回合制,离线,双人,桌游`
- **ja:** `戦略,ボードゲーム,六角形,忍者,少林寺,カンフー,パズル,詰め,戦術,ターン制,オフライン,二人対戦`

(Las palabras del nombre y subtítulo ya cuentan; no repetirlas.)

### Descripción

**en**
```
Hexiege is a turn-based strategy game on a hexagonal board. No luck, no captures: you win by surrounding the enemy Leader on all six sides.

TWO SCHOOLS, ONE SECRET
Play the Shaolin Temple or the Ninja Shadows. Every piece moves its own way: the Dragon flies over the hive, the Monkey King climbs on top of other pieces, the Tiger charges and pushes, the Kunoichi paralyzes, the Tengu teleports. Each faction has an ability that can turn the game around.

A STORY YOU PLAY
Two campaigns of 24 battles each, told in illustrated scenes: Ren, the Abbot's disciple, and Aya, kunoichi of the clan. Two sides of the same night. Finish both to reach The Seal, the true ending.

ALWAYS SOMETHING TO PLAY
• A new daily challenge, with streaks to share.
• Puzzles and challenges with three stars to earn.
• Play the computer at five levels, or a friend on the same device.
• A guided first match with the Sensei, and a codex with every piece in motion.
• Collectible pieces in a 3D gallery, avatars, frames and tables.
• Game Center achievements and leaderboards.

FAIR AND QUIET
Act I of both campaigns is free. One purchase unlocks the rest of the story, forever. No ads, no account, no internet needed.
```

**es** (México y España)
```
Hexiege es un juego de estrategia por turnos en un tablero hexagonal. Sin azar y sin capturas: ganas cuando rodeas al Líder enemigo por sus seis lados.

DOS ESCUELAS, UN SECRETO
Juega con el Templo Shaolin o con las Sombras Ninja. Cada ficha se mueve a su manera: el Dragón vuela sobre la colmena, el Rey Mono se sube encima de otras fichas, el Tigre embiste y empuja, la Kunoichi paraliza, el Tengu se teletransporta. Cada facción tiene una habilidad capaz de dar vuelta la partida.

UNA HISTORIA QUE SE JUEGA
Dos campañas de 24 batallas cada una, contadas en escenas ilustradas: Ren, el discípulo del Abad, y Aya, kunoichi del clan. Dos lados de la misma noche. Termina las dos para llegar a El Sello, el verdadero final.

SIEMPRE HAY ALGO PARA JUGAR
• Un desafío nuevo cada día, con rachas para compartir.
• Problemas y desafíos con tres estrellas para ganar.
• Juega contra la computadora en cinco niveles, o contra un amigo en el mismo dispositivo.
• Una primera partida guiada por el Sensei y un códice con cada ficha en movimiento.
• Fichas coleccionables en una galería 3D, avatares, marcos y mesas.
• Logros y clasificaciones de Game Center.

JUSTO Y TRANQUILO
El Acto I de las dos campañas es gratis. Una sola compra desbloquea el resto de la historia para siempre. Sin anuncios, sin cuenta y sin necesidad de internet.
```

**zh-Hans**
```
Hexiege 是一款在六角棋盘上进行的回合制策略游戏。没有运气，也没有吃子：从六个方向包围敌方首领即可获胜。

两大流派，一个秘密
选择少林寺或忍者暗影。每枚棋子都有独特的走法：天龙飞越棋群，美猴王爬到其他棋子之上，石虎冲锋推挤，女忍使敌人麻痹，天狗瞬间移动。每个阵营都有一项足以扭转战局的技能。

亲手推动的故事
两场战役，各 24 场战斗，以插画场景讲述：方丈的弟子仁，与忍者一族的女忍绫。同一个夜晚的两面。通关两场战役，迎来真正的结局《封印》。

随时都有得玩
• 每天一个新挑战，连胜可以分享。
• 残局与挑战，每关可赢取三颗星。
• 与五个难度的电脑对战，或在同一台设备上与朋友对战。
• 由师父带领的入门对局，以及展示每枚棋子走法的图鉴。
• 3D 画廊中的收藏棋子、头像、边框与棋桌。
• Game Center 成就与排行榜。

公平、安静
两场战役的第一幕免费。一次购买，永久解锁其余故事。无广告、无需账号、无需联网。
```

**ja**
```
Hexiege は六角形の盤で遊ぶターン制の戦略ゲームです。運も駒取りもありません。敵の首領を六方向から包囲すれば勝利です。

二つの流派、ひとつの秘密
少林寺か忍びの影を選んで戦いましょう。駒はそれぞれ独自の動きを持ちます。天龍は駒の群れを飛び越え、美猴王は他の駒の上に登り、大理石の虎は突進して押し出し、くノ一は敵を麻痺させ、天狗は瞬間移動します。各陣営には戦局をひっくり返す特殊能力があります。

遊んで進める物語
各24戦、二つの物語を挿絵付きの場面で描きます。方丈の弟子レンと、一族のくノ一・綾。同じ夜の表と裏。両方をクリアすると、真の結末「封印」へ。

いつでも遊べる
• 毎日新しい「今日の挑戦」。連勝記録をシェアできます。
• 三つ星を目指す詰めと挑戦。
• 五段階の強さのコンピュータ、または同じ端末で友だちと対戦。
• 師範が導く最初の一局と、すべての駒の動きを見られる図鑑。
• 3Dギャラリーで集める駒、アバター、枠、盤。
• Game Center の実績とランキング。

フェアで静か
両陣営の第一幕は無料。一度の購入で残りの物語がずっと遊べます。広告なし、アカウント不要、オフラインで遊べます。
```

## 6b. Game Center (Funciones → Game Center)

**Logros** (Achievements → +). Para todos: «Hidden» No, «Achievable more than once» No.
Imagen obligatoria, 1024×1024 sin transparencia: `store/gamecenter/ach_<nombre>.png` (prompts en `docs/prompts.md`, bloque E). La descripción vale para «Pre-earned» y «Earned».
Los puntos suman 1000, el máximo.

| ID (= Reference name) | Pts | en | es | zh-Hans | ja |
|---|---|---|---|---|---|
| `hexiege.initiation` | 10 | Initiation · Finish the guided match with the Sensei. | Iniciación · Termina la partida guiada con el Sensei. | 入门 · 完成与师父的引导对局。 | 手ほどき · 師範との最初の一局を終える。 |
| `hexiege.firstWin` | 20 | First victory · Win your first battle. | Primera victoria · Gana tu primera batalla. | 初次胜利 · 赢得你的第一场战斗。 | 初勝利 · 初めての戦いに勝つ。 |
| `hexiege.firstBoss` | 50 | Worthy rival · Defeat the first master of a campaign. | Rival digno · Derrota al primer maestro de una campaña. | 势均力敌 · 击败战役中的第一位强敌。 | 好敵手 · 物語で最初の強敵を倒す。 |
| `hexiege.shaolinDone` | 150 | The Temple's path · Finish the Shaolin Temple campaign. | El camino del Templo · Termina la campaña del Templo Shaolin. | 少林之路 · 完成少林寺战役。 | 寺の道 · 少林寺の物語をクリアする。 |
| `hexiege.ninjaDone` | 150 | Shadows over the Temple · Finish the Ninja Shadows campaign. | Sombras sobre el Templo · Termina la campaña de las Sombras Ninja. | 寺上暗影 · 完成忍者暗影战役。 | 寺に落ちる影 · 忍びの影の物語をクリアする。 |
| `hexiege.seal` | 300 | The Seal · Reach the true ending. | El Sello · Llega al verdadero final. | 封印 · 抵达真正的结局。 | 封印 · 真の結末にたどり着く。 |
| `hexiege.streak7` | 70 | Weekly discipline · Solve the daily challenge 7 days in a row. | Disciplina semanal · Resuelve el desafío diario 7 días seguidos. | 七日修行 · 连续 7 天完成每日挑战。 | 七日の修行 · 今日の挑戦を7日連続でクリアする。 |
| `hexiege.streak30` | 250 | Monthly discipline · Solve the daily challenge 30 days in a row. | Disciplina de un mes · Resuelve el desafío diario 30 días seguidos. | 三十日修行 · 连续 30 天完成每日挑战。 | 三十日の修行 · 今日の挑戦を30日連続でクリアする。 |

(En cada celda: título · descripción.)

**Clasificaciones** (Leaderboards → + → Classic). Score format **Integer**, submission
**Best Score**, sort **High to Low**, sin rango.

| ID (= Reference name) | en | es | zh-Hans | ja |
|---|---|---|---|---|
| `hexiege.daily_best` | Best daily streak · ` days` | Mejor racha diaria · ` días` | 最佳每日连胜 · ` 天` | 今日の挑戦・最高連勝 · `日` |
| `hexiege.wins` | Victories · ` wins` | Victorias · ` victorias` | 胜场 · ` 胜` | 勝利数 · `勝` |

(Nombre · sufijo del puntaje. Formato del sufijo: «Integer», singular y plural iguales.)

## 7. Enviar

1. Build 17 procesado → elegirlo en la versión.
2. En «Compras dentro de la app», agregar `hexiege_story`.
3. Agregar para revisión → Enviar a revisión. Suele tardar 1–2 días.

## Después del lanzamiento

- `kShareUrl` en `lib/config.dart` con la URL de la App Store.
- Google Play: mismas descripciones; Play Juegos con `kPlayGames` y los IDs de Android.
