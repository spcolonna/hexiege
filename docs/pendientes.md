# Pendientes de diseño

## Códice de fichas (próximo)
Apartado propio, accesible desde el menú y enlazado desde el tutorial, para estudiar las fichas de a una.

- Listado de las 12 fichas, agrupadas por facción, con arte, nombre y una línea de resumen.
- Al tocar una se abre su ficha de detalle:
  - Cómo se mueve, con un mini tablero animado que muestra un ejemplo de movimiento (casillas alcanzables resaltadas).
  - Su habilidad, también con un ejemplo animado.
  - Particularidades (líder, apilarse, inmunidades, etc.).
- Se puede recorrer a su ritmo: anterior/siguiente, sin obligación de verlas todas.
- Opcional: marcar las fichas ya vistas y mostrar "nueva" en las que el jugador todavía no abrió.
- Reutiliza `PieceRenderer` y el motor real para los ejemplos, así no se desincroniza con las reglas.

## Galería de fichas desbloqueables (a futuro)
Sección donde el jugador va desbloqueando las fichas como obsequios o regalos y puede verlas en detalle.

- Cada ficha se recibe como regalo (por ejemplo al ganar campaña, desafíos, rachas o hitos); la bloqueada se ve como silueta.
- Vista de detalle: zoom con pellizco y rotación de la ficha de piedra para apreciar el arte, el canto y la textura.
- Animación de "abrir el regalo" la primera vez.
- Depende de tener todo el arte final de las 12 fichas (ver `asset_prompts.md`) y probablemente un arte de mayor resolución para el zoom.
- Puede compartir datos con el códice (fichas vistas / obtenidas).
