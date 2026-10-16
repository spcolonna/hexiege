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
