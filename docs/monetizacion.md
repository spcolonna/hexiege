# Monetización: la Horda Mongola, variantes de fichas y economía

Esto es un borrador para revisar antes de tocar código. Los números son un primer tiro y se
ajustan con `tool/stages.dart` (partidas de IA contra IA) y con los datos reales de
TestFlight.

## 0. Principios

1. **Se paga por tiempo o por estilo, nunca por poder.** Todo lo que cambia el juego se
   puede ganar jugando; la plata solo lo adelanta.
2. **Las fichas nuevas son variantes, no mejoras.** Cada una reemplaza a una ficha base de
   su facción. La mano sigue teniendo 11 fichas y se balancea de a pares, base contra
   variante.
3. **El azar queda solo en lo cosmético.** El gacha (Omikuji) nunca da fichas jugables.
4. **No hay publicidad que interrumpa.** Solo videos con recompensa, y son opcionales.
5. **El competitivo futuro tiene un modo Clásico** con solo fichas base, como el Hive sin
   expansiones.

### Reglas de diseño para fichas nuevas
Ninguna ficha nueva debería generar dudas de balance. Para eso, todas cumplen estas tres
reglas:

- **Ningún efecto que mueva fichas rivales puede dejarlas tocando a un Líder** (atraer,
  empujar o traer). Esos efectos sirven para desarmar la posición del rival, nunca para
  cerrarle el cerco.
- **No hay movimientos extra en el mismo turno.**
- **El Líder no puede escapar a distancia.** Solo se mueve por su cuenta, sin intercambios ni
  traslados lejanos.

## 1. Variantes y mini mazo

### Cómo funciona
- Cada facción tiene **ranuras**, una por tipo de ficha base. En la mayoría de las ranuras la
  única opción es la base.
- En las ranuras que tienen una variante desbloqueada, el jugador elige **base o variante**.
  La elección cambia todas las copias de esa ranura: por ejemplo, 2 Tigres pasan a ser 2
  Mantis.
- La elección se guarda por facción (`loadout` en `AppSettings`). Se cambia en la pantalla
  "Preparar mano", que se abre desde la elección de facción y desde el códice.
- **Dónde se usan las variantes:**
  - Sí: Local, matchmaking simulado y desafíos.
  - No: la historia, los rompecabezas y el modo Clásico, que usan siempre la mano base
    porque están diseñados para ella.
- **Los rivales de la IA usan variantes** a medida que sube el nivel del matchmaking. Ver la
  ficha en acción es lo que genera las ganas de tenerla.

### Las 4 variantes de lanzamiento

| Facción | Reemplaza a | Variante | Cant. | Regla |
|---|---|---|---|---|
| Shaolin | Tigre (2) | **Mantis** 螳 | 2 | Se desliza 1 casilla. Después puede **atraer** 1 casilla hacia ella a una ficha enemiga adyacente (no Líder). Es el espejo del empuje del Tigre: controla en vez de embestir. |
| Shaolin | Serpiente (3) | **Tortuga** 龟 | 3 | Se desliza 1 casilla. No la afectan Kawarimi, Jade, Retirada fingida, empujes ni atracciones. Es un ancla defensiva y no tiene la anulación de la Serpiente. |
| Ninja | Kunoichi (2) | **Kusarigama** 鎖 | 2 | Se desliza hasta 2 casillas. En vez de paralizar, **trae** a su lado a una ficha enemiga (no Líder) que esté a exactamente 2 casillas en línea recta. |
| Ninja | Sombra (1) | **Kemuri** 煙 | 1 | Se desliza 1 casilla. Puede dejar **humo** en un hueco adyacente durante 2 turnos, y nadie puede entrar a ese hueco mientras dure. Solo puede haber un humo a la vez. |

Además:
- Mantis y Kusarigama cumplen la regla de los Líderes: la ficha atraída o traída nunca queda
  tocando a un Líder.
- El humo no es una ficha. No cuenta para rodear y no sostiene la colmena.

**Criterio de balance:** en partidas de IA contra IA en nivel Maestro, la variante contra su
ficha base, con todo lo demás igual, tiene que ganar entre el **46 % y el 54 %** de las
veces. Si se sale de ese rango, se ajusta el número de copias o el alcance de la variante, no
la ficha base.

## 2. Facción nueva: la Horda Mongola

### Por qué encaja
- **Es histórica:** los mongoles invadieron Japón dos veces (1274 y 1281) y conquistaron
  China.
- **Da la continuación de la historia:** después del Sello llega una amenaza de afuera que
  obliga a Shaolin y Ninja a unirse de nuevo.
- **Tiene una identidad bien distinta:** los Shaolin controlan, los Ninja se infiltran y la
  Horda **flanquea**. Juega con caballería, saltos en L, golpes a distancia y retiradas
  fingidas.
- **Se distingue a la vista:** piedra azul del Cielo Eterno (Tengri), distinta del verde
  Shaolin, el rojo Ninja y la ceniza del Oni.

### Fichas (11)

| Ficha | Cant. | Regla |
|---|---|---|
| **Khan** 汗 (Líder) | 1 | Se desliza 1 casilla. |
| **Jinete** 骑 | 3 | Salta en **L**: 2 casillas en línea recta y 1 girando 60°, por encima de lo que haya. Tiene que caer tocando la colmena. |
| **Arquero** 弓 | 2 | Se desliza 1 casilla **o**, en vez de moverse, **empuja 1 casilla, alejándola**, a una ficha enemiga (no Líder) que esté a 2 o 3 casillas en línea recta, si la colmena no se rompe. |
| **Lancero** 枪 | 2 | Se desliza 1 casilla. Mientras toque a otro Lancero o al Khan, los efectos rivales no lo mueven. |
| **Lobo** 狼 | 2 | Se desliza hasta 2 casillas, o hasta 3 si arranca tocando al otro Lobo. |
| **Chamán** 巫 | 1 | Se desliza 1 casilla **o** intercambia lugar con una ficha aliada en cualquier parte de la colmena (no el Khan). Como queda ocupada la misma casilla, no puede cerrar ningún cerco. |

### Habilidad: **Retirada fingida**
Tomá una ficha tuya del perímetro (no el Khan) y ponela en otro hueco del perímetro que
**no toque al Líder rival**. Usa las mismas cargas y la misma recarga que Jade y Kawarimi.

### Por qué no preocupa el balance
- El Khan no tiene escape. El Chamán no puede intercambiarse con él.
- Ningún efecto termina un cerco:
  - El empuje del Arquero aleja y nunca deja una ficha tocando a un Líder.
  - La Retirada fingida no puede caer junto al Líder rival.
  - El intercambio del Chamán no cambia qué casillas están ocupadas.
- No hay movimientos extra.
- Lo que puede necesitar ajuste son **números**, no reglas: cuántos Jinetes y el alcance del
  Lobo. Se ajustan con IA contra IA hasta que la Horda gane entre el **45 % y el 55 %**
  contra cada facción en Maestro.

### Variantes de la Horda
No salen en el lanzamiento. Llegan en una segunda tanda (2 variantes), para que la facción
primero se balancee con su set base.

### Historia: "La tormenta del Khan"
Es una campaña de **12 batallas** que se juega con la Horda:
- **Protagonista:** **Khutulun**, la princesa luchadora (figura histórica, sobrina de Kublai
  Khan), que cruza el mar para tomar el Templo y el clan.
- **A mitad de campaña** descubre que Shaolin y Ninja ahora pelean juntos y que bajo el
  Templo hay algo que su abuelo también buscaba.
- **El final** es el *kamikaze*, el viento divino: una tormenta que se lleva la flota. La
  campaña termina con una tregua y deja abierta la próxima facción.
- Se reusa el sistema de viñetas.
- **Personajes nuevos:** Khutulun, el Khan y un chamán. Hacen falta retratos y figuras.

**Próxima facción (ideas):** el Ashram del Himalaya, de la India, enganchado con
Bodhidharma, el fundador del Shaolin. Su mecánica sería de posturas: cada ficha tiene dos
modos.

## 3. Economía

### Moneda: **Koban** 小判
Hay una sola moneda. Se gana jugando, viendo videos o comprándola.

| Fuente | Koban | Límite |
|---|---|---|
| Victoria en matchmaking | 20 | — |
| Derrota en matchmaking | 5 | — |
| Desafío diario | 30 | 1 por día |
| Batalla de campaña (primera vez) | 25 | 1 vez por batalla |
| Rompecabezas resuelto (primera vez) | 15 | 1 vez por rompecabezas |
| Racha de 3 victorias | +20 | — |
| Video con recompensa | 25 | 5 por día |

Un jugador activo típico junta **unos 150 koban por día**: 5 partidas (60 + 10), el desafío
diario (30) y 2 videos (50). Sin videos, son unos 100.

### Tienda (compra directa, sin azar)

| Ítem | Koban | Plata |
|---|---|---|
| Variante (una ficha, todas sus copias) | 600 | USD 0,99 |
| Horda Mongola (facción jugable) | 2.400 | — |
| **Pack Horda**: facción + campaña "La tormenta del Khan" | — | USD 2,99 |
| Campaña de la Horda sola (si ya tenés la facción) | — | USD 1,99 |

- Con juego normal, una variante se consigue en 4 a 6 días.
- La facción lleva 2 a 3 semanas, o se tiene enseguida con el pack.
- La campaña solo se compra con plata, igual que la historia actual. Las campañas son el
  producto principal; la moneda es para lo que se ve en el tablero.

**Paquetes de koban:**

| Paquete | Koban | Precio |
|---|---|---|
| Chico | 500 | USD 0,99 |
| Mediano | 1.200 | USD 1,99 |
| Grande | 3.500 | USD 4,99 |

**Gesto con quien ya pagó:** quien compró la historia (USD 1,99) recibe 600 koban, el
equivalente a una variante gratis.

### Omikuji (gacha cosmético)
Es el papel de la suerte de los templos, así que encaja con la ambientación.

| | |
|---|---|
| Tirada | 100 koban |
| 10 tiradas | 900 koban |
| Común (70 %) | emotes, marcos de avatar |
| Raro (25 %) | avatares, tableros |
| Legendario (5 %) | skins de ficha (arte alternativo de una ficha) |
| Garantía | un legendario como máximo cada 40 tiradas |
| Repetidas | se convierten en **incienso**: común 5, raro 15, legendario 50 |
| Tienda de incienso | elegís cualquier ítem: común 40, raro 120, legendario 300 |

- Al ritmo gratis sale **una tirada por día**.
- Las probabilidades se muestran en la pantalla del Omikuji, como exige Apple (regla 3.1.1).
- Se apoya en lo que ya existe: la galería de piezas, los regalos y los estilos Caja, Ema y
  Panal.
- El catálogo inicial tiene unos 30 ítems (18 comunes, 9 raros y 3 legendarios) y se suman
  más en cada actualización.

## 4. Publicidad, privacidad y temas legales

### Videos con recompensa
- Se usaría AdMob o AppLovin MAX.
- Solo se ven si el jugador toca "Ver video (+25)". No hay intersticiales ni banners.
- Quien compró algo con plata puede ocultar el botón.

### Cambios obligatorios cuando entre la publicidad
- **App Store Connect → Privacidad:** pasa de "Datos no recopilados" a declarar
  identificadores y datos de uso para publicidad.
- **Permisos:** hay que mostrar el permiso de seguimiento de Apple (ATT) antes del primer
  video y el consentimiento de la UE (UMP de Google).
- **Política de privacidad:** hay que actualizar `docs/privacidad.html`.
- **Clasificación por edad:** tiene que declarar compras y anuncios.

### Omikuji
- Hay que mostrar las probabilidades y declarar "compras con ítems aleatorios".
- En **Bélgica**, y por prudencia también en **Países Bajos**, el Omikuji se desactiva. El
  país se detecta con `SKStorefront.countryCode`. El incienso y la tienda directa siguen
  funcionando.

### China
Los juegos con compras necesitan una licencia (ISBN). Con esta economía conviene no publicar
ahí, aunque la app esté traducida.

## 5. Implementación (resumen técnico)

### Motor
- `Faction.horde` y las fichas nuevas se agregan **al final** de `PieceType`, para no romper
  índices guardados. Hay que reescribir `faction`, `isLeader` y `glyph`, y sumar la facción a
  `playableFactions`.
- **Movimientos nuevos en `moves.dart`:**
  - El salto en L del Jinete, sobre coordenadas axiales.
  - El empuje a distancia del Arquero.
  - El intercambio del Chamán.
  - La atracción de Mantis y Kusarigama.
- **Humo de Kemuri:** es un marcador temporal en `Board`, como el Sello de Sombra.
- **Retirada fingida** va en `abilityActions`.
- **Un solo chequeo para todos los efectos que mueven fichas rivales:** el destino no puede
  tocar a un Líder.

### Mano
`Rules.hands` sale del loadout de cada ranura (base o variante). El modo Clásico fuerza la
mano base.

### IA
Los movimientos nuevos entran en la generación de jugadas. La heurística de `ai.dart` tiene
que valorar el flanqueo, para que la IA aproveche los Jinetes.

### Tienda
- `lib/store/purchases.dart` suma estos productos:
  - `hexiege_koban_s`, `_m` y `_l`, consumibles.
  - `hexiege_horde_pack`, no consumible.
  - `hexiege_variant_*`, no consumibles.
- El saldo de koban se guarda en local, en `AppSettings`.
- **Riesgo:** sin servidor, el saldo se puede manipular en un dispositivo liberado. Se acepta
  mientras no haya online; con online, el saldo pasa al servidor.

### UI
- Pantalla "Preparar mano".
- Tienda con pestañas Fichas, Facciones y Koban.
- Omikuji, con una animación de papel que se despliega.
- Contador de koban en el inicio.

### Contenido
- Arte de las 6 fichas de la Horda y de las 4 variantes, con el mismo pipeline de
  `docs/prompts.md`.
- Ejemplos en el códice.
- Textos en `tool/i18n_strings.json` en los 3 idiomas.

## 6. Orden

1. **Variantes y mini mazo:** las 4 variantes, la pantalla "Preparar mano" y el balance con
   IA contra IA. Todavía no se cobra nada: se desbloquean con koban ganados jugando.
2. **Horda Mongola:** fichas, Retirada fingida, IA y balance contra Shaolin y Ninja.
3. **Koban y tienda directa** con compras de StoreKit, más el Pack Horda y su campaña.
4. **Omikuji y videos con recompensa:** van al final porque son lo más caro en lo legal y
   en privacidad.

Cada paso se puede publicar por separado en TestFlight.

## 7. Preguntas abiertas

- ¿Las variantes también se venden con plata (USD 0,99), o solo con koban?
- ¿Arrancamos con publicidad, o primero probamos solo con compras para ver si hace falta?
- ¿La campaña de la Horda es de 12 batallas, o una más corta (6) para sacarla antes?
