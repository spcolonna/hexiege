# Pendientes de diseño

## Códice de fichas ✅ hecho
Se entra desde Reglas ("Explorar las fichas" o tocando una ficha). Falta decidir si además va un acceso directo en el menú.

- Listado de las 12 fichas, agrupadas por facción, con arte, nombre y una línea de resumen.
- Al tocar una se abre su ficha de detalle:
  - Cómo se mueve, con un mini tablero animado que muestra un ejemplo de movimiento (casillas alcanzables resaltadas).
  - Su habilidad, también con un ejemplo animado.
  - Particularidades (líder, apilarse, inmunidades, etc.).
- Se puede recorrer a su ritmo: anterior/siguiente, sin obligación de verlas todas.
- Opcional: marcar las fichas ya vistas y mostrar "nueva" en las que el jugador todavía no abrió.
- Reutiliza `PieceRenderer` y el motor real para los ejemplos, así no se desincroniza con las reglas.

## Galería de fichas desbloqueables ✅ hecho
Botón "Galería" en el menú (con un punto si hay regalos sin abrir).

- Cada ficha se gana con un hito (`lib/codex/gifts.dart`): tutorial, primera victoria, batallas de cada campaña, 6 problemas y 3 desafíos. Todas se pueden jugar desde el principio; el regalo es la pieza de colección.
- Al ganar una aparece un aviso arriba ("¡Regalo!"), también al abrir el menú si hay ganadas de antes.
- En la galería: las bloqueadas son silueta (al tocarlas dicen cómo se ganan); las ganadas aparecen envueltas y se abren con una animación (la caja tiembla, se abre y la ficha sube entre rayos).
- Visor 3D: girar con un dedo (con inercia), pellizcar o doble toque para zoom; el dorso lleva el emblema de la facción.
- Pendiente: el arte está a 512 px; para un zoom más nítido harían falta las ilustraciones a 1024 px o más.

## Marca Oraki Games ✅ hecho
- La pantalla de carga nativa muestra el logo de Oraki. Al abrir, la intro (`lib/ui/brand_intro.dart`) arranca en el mismo lugar: halo cálido, destello de la estrella y "GAMES" debajo; después funde al menú. Tocar la salta.
- Pie "Un juego de Oraki Games" con el símbolo al final de Ajustes.
- Logos en `assets/brand/` (versión crema para fondo oscuro y versión color para fondo claro).

## Tienda (idea, sin implementar)
Todo cosmético; nada da ventaja en la partida. Prompts del arte en `docs/asset_prompts.md`, secciones 6 y 11 a 15.

- **Moneda: jade.** Se gana con victorias (más contra niveles altos de IA o en la ladder), misiones del día ("ganá con el Tigre", "colocá 3 Serpientes"), batallas de campaña la primera vez y rachas de días jugados. Sin dinero real por ahora; si algún día se suma, se venden paquetes de jade, nunca ventajas.
- **Qué se vende:**
  - Avatares: 10 retratos en tinta. Novicio y Jōnin vienen gratis.
  - Marcos de avatar: bronce, jade y oro se ganan por rango en la ladder; obsidiana solo en el rango máximo. Pueden venderse variantes.
  - Sets de emotes: monjecito y ninjita de base, después otros personajes.
  - Piedras de ficha: 2 por facción. Una imagen cambia las 6 fichas, así que es lo más barato de producir.
  - Tapetes de mesa: al final, porque se ven poco.
- **Pantalla:**
  - Arriba, el saldo de jade.
  - Pestañas por categoría.
  - Grilla de ítems con precio. Los que ya tenés muestran "Equipar".
  - Vista previa en vivo: el avatar con el marco, la ficha con la piedra nueva en el visor 3D (reutiliza `PieceToken3D`) y el emote en su globo.
  - Una "oferta del día" rotativa.
- **Perfil:** una pantalla nueva o una sección de la galería para equipar avatar, marco, set de emotes y piedra. El rival simulado del emparejamiento también usaría avatares y marcos, así la tienda se ve en uso.
- **Se integra con lo que ya hay:**
  - La galería de regalos puede dar jade al abrir cada ficha.
  - `AppSettings` guarda el saldo, lo comprado y lo equipado.
  - `Emote` ya está pensado para ser cosmético.
