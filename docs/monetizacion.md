# Monetización: facción Ronin, variantes de fichas y economía

Borrador para revisar antes de tocar código. Los números son un primer tiro: se ajustan con
`tool/stages.dart` (IA contra IA) y con datos reales de TestFlight.

## 0. Principios

1. **Se paga por tiempo o por estilo, nunca por poder.** Todo lo que cambia el juego se puede
   ganar jugando; la plata solo lo adelanta.
2. **Las fichas nuevas son variantes, no mejoras.** Cada una reemplaza a una ficha base de su
   facción: la mano sigue teniendo 11 fichas y se balancea de a pares (base contra variante).
3. **El azar queda solo en lo cosmético.** El gacha (Omikuji) nunca da fichas jugables.
4. **Sin publicidad que interrumpa.** Solo videos con recompensa, opcionales.
5. **El competitivo futuro tiene modo Clásico**, solo con fichas base, como el Hive sin
   expansiones.

## 1. Variantes y mini mazo

### Cómo funciona
- Cada facción tiene **ranuras**: una por tipo de ficha base. En la mayoría hay una sola
  opción, la base.
- En las ranuras con variante desbloqueada, el jugador elige **base o variante**. Cambia
  todas las copias de esa ranura. Por ejemplo, 2 Tigres pasan a ser 2 Mantis.
- La elección se guarda por facción (`loadout` en `AppSettings`) y se cambia en una pantalla
  "Preparar mano", accesible desde la elección de facción y desde el códice.
- **Dónde se usa:** Local, matchmaking simulado y desafíos. La historia, los rompecabezas y
  el modo Clásico usan siempre la mano base, porque están diseñados para ella.
- **Los rivales de la IA usan variantes** a medida que sube el nivel del matchmaking. Ver la
  ficha en acción es lo que genera las ganas de tenerla.

### Las 4 variantes de lanzamiento

| Facción | Reemplaza a | Variante | Cant. | Regla |
|---|---|---|---|---|
| Shaolin | Tigre (2) | **Mantis** 螳 | 2 | Se desliza 1 casilla. Después puede **atraer** 1 casilla hacia ella a una ficha enemiga adyacente (no Líder), si la colmena no se rompe. Es el espejo del empuje del Tigre: controla en vez de embestir. |
| Shaolin | Serpiente (3) | **Tortuga** 龟 | 3 | Se desliza 1 casilla. No la afectan Kawarimi, Jade, empujes ni atracciones. Es un ancla defensiva y pierde la anulación de la Serpiente. |
| Ninja | Kunoichi (2) | **Kusarigama** 鎖 | 2 | Se desliza hasta 2 casillas. En vez de paralizar, **trae** a su lado a una ficha enemiga (no Líder) que esté a exactamente 2 casillas en línea recta. |
| Ninja | Sombra (1) | **Kagemusha** 影武 | 1 | Se desliza 1 casilla. El intercambio del Shogun (una vez por partida) puede hacerse con el Kagemusha **a cualquier distancia**, en lugar de con un Shinobi adyacente. |

**Criterio de balance:** en partidas de IA contra IA en nivel Maestro, la variante contra su
ficha base, con todo lo demás igual, tiene que quedar entre **46 % y 54 %** de victorias. Si
se sale, se toca el número o el alcance de la variante y no la ficha base.

**A vigilar:**
- **Kagemusha:** escapar de lejos puede ser demasiado fuerte. Una alternativa es limitarlo a
  3 casillas.
- **Mantis y Kusarigama:** pueden armar cercos rápidos. Ninguna de las dos puede mover al
  Líder, y si hace falta se aplica la misma regla del Tengu: no pueden cerrar el cerco del
  Líder con su efecto.

## 2. Facción Ronin

### Identidad
Son los expulsados, "los sin señor". Juegan al revés que el enjambre: **sus fichas se
fortalecen cuando están en duelo**, es decir, cuando no tocan a ninguna ficha aliada
(pueden tocar enemigas). Rompen la forma compacta y castigan al rival que deja huecos.

- Piedra: un tono nuevo de acero o índigo, distinto del verde Shaolin, el rojo Ninja y la
  ceniza del Oni.
- Líder: **Jubei**. Ya existe como personaje (avatar `ronin`) y es neutral en la historia.

### Fichas (11)

| Ficha | Cant. | Regla |
|---|---|---|
| **Rōnin** 浪 (Líder) | 1 | Se desliza 1 casilla. **En duelo**, hasta 2. |
| **Samurái** 侍 | 3 | Se desliza 1 casilla. **En duelo**, hasta 3. |
| **Kenshi** 刀 | 2 | Se desliza 1 casilla **o** intercambia lugar con una ficha enemiga adyacente (no Líder), si la colmena no se rompe. |
| **Yumi** 弓 | 2 | Salta en línea recta a la casilla que está **exactamente a 2**, haya o no ficha en el medio. |
| **Yōjimbō** 守 | 2 | Se desliza 1 casilla. Mientras toque a su Líder, ni él ni el Líder pueden ser movidos por efectos rivales (Jade, Kawarimi, empujes, atracciones). |
| **Komusō** 虚 | 1 | Salta a cualquier hueco a 3 casillas o menos, **solo si al llegar queda en duelo**. |

### Habilidad: **Bushidō**
Mové **otra vez** una ficha tuya que esté en duelo (puede ser el Líder). Usa las mismas
cargas y la misma recarga que las otras habilidades: 3 cargas en `Rules`.

**Riesgo principal:** un movimiento extra puede cerrar un cerco en un solo turno. Si las
partidas lo muestran, se aplica la regla del Tengu: el movimiento extra no puede cerrar el
cerco del Líder rival.

### Variantes Ronin
No salen en el lanzamiento. Llegan en la segunda tanda (2 variantes), para que la facción
primero se balancee con su set base.

### Historia: "El camino del ronin"
Es una campaña de **12 batallas** después del epílogo:
- Jubei reúne a los expulsados de los dos bandos.
- Los duelos de honor se convierten en torneo.
- Jubei sospecha que la grieta no fue la única.

Reusa el sistema de viñetas y deja preparada la próxima facción (Yōkai, con la Zorra
Blanca).

## 3. Economía

### Moneda: **Koban** 小判
Hay una sola moneda. Se gana jugando, viendo videos o comprándola.

| Fuente | Koban | Límite |
|---|---|---|
| Victoria en matchmaking | 20 | — |
| Derrota en matchmaking | 5 | — |
| Desafío diario | 30 | 1 por día |
| Batalla de campaña (primera vez) | 25 | una vez por batalla |
| Rompecabezas resuelto (primera vez) | 15 | una vez por rompecabezas |
| Racha de 3 victorias | +20 | — |
| Video con recompensa | 25 | 5 por día |

**Jugador activo típico:** 5 partidas (60 + 10), el desafío diario (30) y 2 videos (50) dan
unos **150 koban por día**. Sin videos son unos 100.

### Tienda (compra directa, sin azar)

| Ítem | Koban | Plata |
|---|---|---|
| Variante (una ficha, todas sus copias) | 600 | USD 0,99 |
| Facción Ronin (jugable) | 2.400 | — |
| **Pack Ronin**: facción + campaña "El camino del ronin" | — | USD 2,99 |
| Campaña Ronin sola (si ya tenés la facción) | — | USD 1,99 |

- Una variante se consigue en **4 a 6 días** de juego normal.
- La facción se consigue en **2 a 3 semanas**, o enseguida con el pack.
- La campaña Ronin solo se compra con plata, como la historia actual. Las campañas son el
  producto principal; la moneda es para lo que se ve en el tablero.

**Paquetes de koban:**

| Paquete | Koban | Precio |
|---|---|---|
| Chico | 500 | USD 0,99 |
| Mediano | 1.200 | USD 1,99 |
| Grande | 3.500 | USD 4,99 |

**Gesto con quien ya pagó:** quienes compraron la historia (USD 1,99) reciben 600 koban, el
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
- Las probabilidades se muestran en la pantalla del Omikuji, como exige Apple (3.1.1).
- Se apoya en lo que ya existe: la galería de piezas, los regalos y los estilos Caja, Ema y
  Panal.
- **Catálogo inicial:** unos 30 ítems (18 comunes, 9 raros y 3 legendarios). Se suman
  ítems en cada actualización.

## 4. Publicidad, privacidad y temas legales

- **Videos con recompensa:**
  - Opción: AdMob o AppLovin MAX.
  - Solo se ven si el jugador toca "Ver video (+25)". No hay intersticiales ni banners.
  - Quien compró algo con plata puede ocultar el botón.
- **Cambios obligatorios cuando entra la publicidad:**
  - App Store Connect → Privacidad: pasa de "Datos no recopilados" a declarar
    identificadores y datos de uso para publicidad.
  - Hay que mostrar el permiso de seguimiento de Apple (ATT) antes del primer video.
  - Hay que mostrar el consentimiento de la UE (UMP de Google) y actualizar
    `docs/privacidad.html`.
  - La clasificación por edad debe declarar compras y anuncios.
- **Omikuji:**
  - Hay que mostrar las probabilidades y declarar "compras con ítems aleatorios".
  - En **Bélgica** (y por prudencia en **Países Bajos**) el Omikuji se desactiva: el país se
    detecta con `SKStorefront.countryCode`, y el incienso y la tienda directa siguen
    funcionando.
- **China:** los juegos con compras necesitan licencia (ISBN). Se sugiere no publicar ahí con
  esta economía, aunque la app esté traducida.

## 5. Implementación (resumen técnico)

- **Motor:**
  - `Faction.ronin` y las fichas nuevas se agregan **al final** de `PieceType`, para no
    romper índices guardados. Hay que reescribir `faction`, `isLeader` y `glyph`.
  - Se agrega a `playableFactions`.
  - Helper `Board.inDuel(hex)`.
  - Movimientos nuevos en `moves.dart` y la habilidad Bushidō en `abilityActions`.
  - En `Rules`: alcance del Kagemusha y regla de no cerrar cerco para Mantis, Kusarigama y
    Bushidō.
- **Mano:** `Rules.hands` sale del loadout: ranura → base o variante. El modo Clásico fuerza
  la mano base.
- **IA:** los movimientos nuevos entran en la generación de jugadas. La heurística de
  `ai.dart` tiene que valorar el duelo en el caso de los Ronin.
- **Tienda:**
  - `lib/store/purchases.dart` suma productos:
    - `hexiege_koban_s`, `_m` y `_l`: consumibles.
    - `hexiege_ronin_pack`: no consumible.
    - `hexiege_variant_*`: no consumibles, uno por variante.
  - El saldo de koban se guarda en local, en `AppSettings`.
  - **Riesgo:** sin servidor, el saldo se puede manipular con el dispositivo liberado. Se
    acepta mientras no haya online; con online, el saldo pasa al servidor.
- **UI:**
  - Pantalla "Preparar mano".
  - Tienda: pestañas Fichas, Facciones y Koban.
  - Omikuji, con animación de papel desplegándose.
  - Contador de koban en el inicio.
- **Contenido:**
  - Arte de 6 fichas Ronin y 4 variantes, con el mismo pipeline de prompts de
    `docs/prompts.md`.
  - Ejemplos en el códice.
  - Textos en `tool/i18n_strings.json` en los 3 idiomas.

## 6. Orden

1. **Variantes y mini mazo.** Las 4 variantes, la pantalla "Preparar mano" y el balance
   con IA contra IA. Todavía no se cobra nada: se desbloquean con koban ganados jugando.
2. **Facción Ronin.** Fichas, Bushidō, IA y balance contra Shaolin y Ninja, con el
   objetivo de 45 % a 55 % en Maestro.
3. **Koban y tienda directa** con compras de StoreKit, más el Pack Ronin y su campaña.
4. **Omikuji y videos con recompensa**, que es lo más caro en lo legal y la privacidad.

Cada paso se puede publicar por separado en TestFlight.

## 7. Preguntas abiertas

- ¿Las variantes también se venden con plata (USD 0,99), o solo se consiguen con koban?
- ¿Arrancamos con publicidad, o probamos primero solo con compras y vemos si hace falta?
- ¿La campaña Ronin es de 12 batallas, o más corta (6) para sacarla antes?
- ¿Kagemusha a cualquier distancia, o limitado a 3 casillas desde el principio?
