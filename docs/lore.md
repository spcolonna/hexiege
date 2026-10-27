# Hexiege — Biblia de la historia y guion

> Fuente del guion: `tool/gen_story.py` lo convierte en `lib/story/script.g.dart` y las
> traducciones en/zh viven en `tool/story_tr.json`. Cada batalla tiene una charla **antes** (viñetas que entran de a una) y
> una **después** (al ganar). Las líneas en *cursiva* son separadores de momento (tiempo o
> lugar) y marcan los puntos a los que se puede saltar en la línea de tiempo.

---

## 1. El mundo

**El Sello de los Seis.** Hace trescientos años el **Oni de Ceniza** quemó los valles.
El monje **Daishin** y la ninja **Kagerō** lo vencieron juntos: no lo mataron, lo
**rodearon** con seis piedras en hexágono y lo encerraron bajo la montaña. Sobre la
grieta se levantó el Templo de Jade. El ritual quedó escrito en el **Pergamino de Jade**,
y para renovarlo hacen falta dos manos: una del Templo y una del clan.

**La mitad de la verdad.** Con los siglos los bandos se pelearon y cada uno guardó media
historia:
- El **Templo** custodia el pergamino y el sello, pero borró que el ritual necesita a un
  ninja. Para los monjes, los ninjas son ladrones.
- El **Clan de la Sombra** recuerda que el pergamino "también es suyo", pero olvidó para
  qué sirve. Para los ninjas, los monjes se lo robaron.

**El juego como ritual.** Rodear al líder enemigo es la forma en que se sella a un
demonio. Por eso monjes y ninjas entrenan con el tablero hexagonal desde hace siglos,
aunque ya nadie recuerda por qué.

**Hoy.** El sello se agrieta. El Abad lo sabe hace años y quiere renovarlo solo, por
orgullo. El Shogun manda a robar el pergamino para "recuperar lo que es del clan". Los
dos llevan a sus bandos a una guerra que despierta al Oni.

## 2. Personajes

| Personaje | Bando | Retrato | Rol |
|---|---|---|---|
| **Ren** | Templo | `novice` | Discípulo joven. Protagonista Shaolin. Leal, curioso, demasiado obediente. |
| **Aya** | Clan | `fan` | Kunoichi joven. Protagonista Ninja. Hábil, desconfiada, hace preguntas que no debe. |
| **Abad Hōshin** | Templo | `abbot` | Maestro de Ren. Sabio y orgulloso. Esconde que el sello se rompe. |
| **Gran Shogun Kage** | Clan | `shogun` | Líder del clan. Duro pero no cruel. Obedece una leyenda que no entiende. |
| **Maestra Mei** | Templo | `abbess` | Segunda del Templo. Sabe parte de la verdad y calla por lealtad. |
| **Tao, el monje borracho** | Templo | `drunken` | Guardián de la cripta. Parece un payaso; es el que más sabe. |
| **Gon** | Templo | `staff` | Compañero de Ren, rival amistoso. |
| **Kuro** | Clan | `jonin` | Jonin, mentor de Aya. Fiel al Shogun hasta el final. |
| **Jubei, el ronin** | Ninguno | `ronin` | Ex monje expulsado por preguntar demasiado. Ayuda a los dos protagonistas. |
| **Sora** | Clan | `scout` | Hermano mayor de Aya, explorador. Es el que Gon captura. A escondidas lleva mensajes de la Zorra Blanca: "venimos a advertir". |
| **La Zorra Blanca** | Espíritu | `kitsune` | Aparece en las dos campañas. Habla en acertijos. Es el lazo entre Daishin y Kagerō. |
| **El Oni de Ceniza** | — | `ashoni` | El demonio sellado. Casi no habla: cuando lo hace, en ceniza. |

**Hilos abiertos del Acto I (resolver en los actos II–IV):**
- **El chico de la manta.** Ren llegó al Templo de bebé, envuelto en una manta, una noche de lluvia gris (ceniza: la primera grieta del sello). El clan lo conoce por ese nombre y el Shogun ordena no hacerle daño. Propuesta: la manta es del clan; Ren es hijo de una kunoichi y un monje, las "dos manos" del ritual en una sola persona.
- **Sora y la Zorra.** Sora cruza el muro para dejar la marca de los seis puntos y advertir al Templo, por encargo de la Zorra, sin que el clan lo sepa. Aya lo descubre al final del Acto I (n6).
- **La marca bordada.** La manta de Ren tiene bordados los seis puntos alrededor de uno, en hilo gris (s1). El Abad no lo encontró en el escalón: «ella» se lo puso en los brazos (s6). Kuro juró callar hace dieciséis años.
- **Kiku**, la abuela de Aya y Sora, rezaba con el tablero, decía que «le faltaba una mano» y murió tosiendo gris. Sus últimas palabras: «Cuando la piedra lata, volvé a rodear.» La Zorra le llevó mensajes durante cuarenta años.
- **Gon** cuidó en secreto la escalera de la cripta por orden del Abad («ni a Ren»), perdió contra Aya y atrapó a Sora para no volver con las manos vacías. Su hermana **Hana**, de ocho años, vive en el pueblo.

**Cronología del Acto I (las dos campañas se cruzan):** noche 1, s1 y n1-n5 (Aya duda antes de saltar el muro; Sora deja la marca; Aya vence a Gon en la escalera) · alba, Gon atrapa a Sora · día 2, s2 y s3 (la emboscada es de ninjas que desobedecen al Shogun) · noche 2, s4 y n6 al mismo tiempo (los golpes en el techo son la distracción; Aya pelea con Mei mientras la Zorra saca a Sora) · alba 3, s5 (cubren la huida de Aya y Sora) y s6.

**Hilos del Acto II (resolver en III–IV):**
- **Natsu**, hija menor de Kiku y tía de Aya, «murió» hace dieciséis años; su tumba está vacía. Es la madre de Ren: terminó de bordar la manta que empezó Kiku. Con **Jubei** (entonces monje) bajó a la cripta en luna nueva a renovar el sello «sola», sin el ritual completo; esa noche cayó la lluvia gris. Le puso el bebé en brazos al Abad.
- **Jubei** es el padre de Ren y no lo sabe del todo: el Abad le dijo que el bebé había muerto con ella y lo echó esa noche. Sus nombres están tallados en la piedra central del jardín de piedra. Tras ver la manta (s9) se va a buscar «a un viejo que no quiere ser encontrado» y no llega al santuario.
- **Tao y el Abad** juraron esa noche: el Abad, no hablar nunca de ella; Tao, no cruzar el río. Tao le manda a Jubei: «no fue culpa suya».
- **Kage** sabe más de lo que dice: se mira la mano cuando Aya cuenta que la piedra late. Llama a Ren «una deuda del clan». Encierra a Sora en la torre por los mensajes de la Zorra.
- La canción de Kiku: «Una mano del monte, una mano de la sombra. Seis piedras alrededor, y el fuego se duerme.»

**Cronología del Acto II:** día 3, n7 (castigo y entrenamiento) · noche 4, n8-n9 (jardín de piedra) · día 5, s7-s8 (Ren sale con Tao; los ninjas castigados cuidan el puente), n10 a la mañana y s9 a la tarde (Jubei encuentra a los dos) · noche 5, s10 (Jubei se va) · día 6, s11 · noche 6, n11 (Gon busca a Ren por orden del Abad) · alba 7, s12/n12.

**Hilos del Acto III (resolver en IV y el final):**
- **Natsu** esperó a Jubei al pie de la escalera; el Abad lo había hecho encerrar por Tao. Le dio el bebé al Abad («Si no bajan dos, bajo sola. Cuidalo. Que no baje nunca.») y bajó sola. Desde entonces «le tiene la mano» al Oni: su sacrificio sostuvo el sello dieciséis años y se está cansando. Su abanico quemado quedó junto a la grieta (Aya se lo lleva) y su mano está marcada en la pared de la escalera.
- **El Abad** se quema las manos sosteniendo las piedras rajadas cada noche y piensa bajar solo en luna nueva, como ella. Manda a Ren a la pagoda para alejarlo de la cripta. Le habla a una piedra sin nombre en el patio de atrás, con un hilo gris atado.
- **Mei** arrancó y quemó la página de la crónica de ese año; le revela a Ren que Natsu era su madre.
- **Tao** encerró a Jubei esa noche. Jubei bajó a la cripta la noche 7 y le pidió perdón; después fue a la pagoda a pedirle a Kage una mano del clan. Tao le dice a Ren que Jubei es su padre y a Aya le confirma todo: Ren es su primo.
- **Kage** le negó a Natsu una mano del clan hace dieciséis años («el clan no le da la mano a ladrones»). Ahora quiere hacer el ritual solo con manos del clan: el mismo error del Abad, del otro lado. Tiene a Jubei encerrado en la torre con Sora.
- **Kuro** llevó a Natsu hasta el muro la noche de la lluvia gris; ella le pidió que el clan le debiera una vida al chico. Le dice a Aya que lleve el Pergamino «a quien tenga la otra mano».
- **Las castigadas del puente** (la kunoichi de s3/s8) entran al Templo al alba 9 sin orden, para sacar a Ren antes de la luna nueva: Natsu les enseñó a tirar estrellas.
- **El Oni** llama a Daishin en los sueños de los novicios y a Kagerō frente a Aya («sos de su sangre»). Sus «dedos» de ceniza escapan por las grietas. En el pueblo los chicos tosen gris, también Hana.
- Una figura de ceniza con forma de mujer dibuja la marca y señala hacia arriba: hacia la otra mano.

**Cronología del Acto III:** día 7, s13 (Ren vuelve con la patrulla de Gon) · noche 7, s14 (sueños; el Abad en la piedra sin nombre, dieciséis años de la lluvia gris); Jubei baja a ver a Tao · día 8, n13 en la torre (Sora); Jubei llega a la pagoda · noche 8, s15 (Ren en la biblioteca con Mei) y al mismo tiempo n13-n17 (Aya en la cripta; el ruido de la biblioteca la cubre; el Abad baja antes del alba) · alba 9, s16 (las castigadas entran por el muro; Aya las ve al salir) · día 9, s17 y n18 · noche 9, s18 (Ren sale hacia la pagoda); Kuro, vencido, deja ir a Aya al Templo · noche 10: luna nueva.

**Cronología del Acto IV:** alba 10, Aya llega al Templo y se esconde en los tejados · tarde 10, Ren llega a la pagoda (s19-s21) · anochecer, s22 (Ren libera a Jubei y a Sora, que corren al Templo por los tejados del valle) y n19-n20 · cerca de la medianoche, n21-n23 y s23 · medianoche, s24 y n24 a la misma hora: Kage le cuenta a Ren que Daishin y Kagerō fueron marido y mujer y que sus dos hijos fundaron el Templo y el clan; Aya lee el Pergamino. La mano de Natsu se suelta y el Oni sube (el Sello). En el epílogo, la figura de ceniza de Natsu se despide y su nombre queda tallado en la piedra del patio de atrás.

**Retratos:** todos los personajes que hablan tienen retrato y figura (`assets/avatars/`, `assets/story/char_*`). El Abad, Kage y el Oni (`ashoni`) son solo de la historia; el avatar elegible `oni` es un ninja con máscara.
Opcional: versiones con otra expresión de Ren y Aya.

## 3. Estructura

- **Dos campañas de 24 batallas**, en 4 actos de 6. La batalla 6, 12, 18 y 24 de cada
  campaña es un jefe con nombre.
- **Gratis:** Acto I de cada campaña (12 batallas). El Acto I termina en un cliffhanger y
  ahí aparece el desbloqueo de **USD 1,99**.
- **Batalla 12:** Ren contra Aya. Es la misma escena contada desde cada lado.
- **Fin de campaña:** tarjeta "Hay otra mitad de esta historia. Terminá *{otra campaña}*
  para descubrir el verdadero final."
- **El Sello (final):** se abre con las dos campañas terminadas. Tres batallas: Ren solo,
  Aya sola, y los dos juntos.

Dificultad por acto: I novato/fácil · II fácil/normal · III normal/difícil · IV
difícil/maestro. Las reglas especiales de cada batalla se indican como *Regla*.

---

## 4. Campaña Shaolin — «El camino del Templo» (Ren)

### Acto I · La sombra en el muro *(gratis)*

#### s1 · Las puertas del Templo
Rival: explorador ninja · IA: novato · Regla: normal
**Antes**
- *Medianoche. El muro del Templo.* [plano .82,.3 x1.4]
- [plano .4,.55 x1.15 lento]
- [arte art_wall · plano .2,.3 x1.5]
- Narración [plano .45,.5 x1.05 lento]: Una sombra cruza el muro. Después, otra. Y una tercera, más chica, que duda antes de saltar.
- *Dentro, el dormitorio de los discípulos.* [lugar dormitory · plano .5,.5 x1.25]
- Narración: Veinte esteras en fila. Diecinueve discípulos duermen.
- Ren [entra izq] *(pensando)*: Rodear. Esperar. Cerrar. Rodear. Esperar. Cerrar…
- Ren *(pensando)*: En tres días es la prueba de los novicios. Si la paso, me dan el bastón.
- Gon [off] *(dormido)*: Ren… apagá esa cabeza. Se te oye pensar desde acá.
- Ren *(pensando)*: Gon duerme como una piedra. Yo nunca duermo la noche antes de algo.
- [plano .78,.45 x1.35]
- Narración: La puerta corrediza se abre sin un ruido.
- Abad [entra der sombra]: ¿Otra vez jugando de memoria?
- Ren: ¡Maestro! No… no podía dormir.
- Abad: Mejor. Esta noche te necesito despierto.
- Narración: El Abad Hōshin tiene setenta inviernos y nunca le tembló la voz. Esta noche le tiemblan las manos.
- Ren *(pensando)*: Y tiene polvo gris en las mangas. ¿De dónde viene a esta hora?
- Abad: Alguien saltó el muro. Andá a ver quién se atreve.
- Ren: ¿Yo? ¿No despertamos a la Maestra Mei?
- Abad: Mei tiene otra guardia esta noche. Y nadie más tiene que despertarse.
- Ren: ¿Por qué?
- Abad: Porque un Templo que grita de noche es un Templo que tiene miedo. Y nosotros no tenemos miedo.
- Abad: Si es uno, alcanza con vos.
- Abad: Si son más… no grites. Volvé a buscarme.
- Ren: Sí, maestro.
- [sale Abad sombra · plano .35,.5 x1.3 lento]
- Narración: Ren llegó al Templo envuelto en una manta, una noche de lluvia gris. Fue el Abad quien lo levantó del escalón.
- Narración: Dieciséis años después, la manta sigue doblada en el fondo de su baúl. Nunca supo quién la tejió.
- Ren *(pensando)*: Me cuidó toda la vida. Esta noche me toca a mí.

**Después**
- *El muro, un instante después.* [lugar wall · plano .35,.5 x1.3]
- Ren [entra izq corre]: ¡Alto! ¡No te escapes!
- [entra Explorador der sombra · plano .62,.4 x1.45]
- Explorador: Peleás bien para estar descalzo, monjecito.
- Ren: ¿Qué viniste a robar?
- Explorador: Nada. Vine a dejar algo.
- [sale Explorador corre · plano .85,.28 x1.3 lento]
- Narración: El ninja salta y la noche se lo traga.
- Ren *(pensando)*: ¿Dejar algo?
- [plano .7,.45 x1.5 lento]
- Narración: En la piedra del muro hay una marca fresca, hecha con carbón: seis puntos alrededor de uno.
- Ren *(pensando)*: Como un Líder rodeado en el tablero…
- Ren *(pensando)*: No. Esto ya lo vi en otro lado.
- *Más tarde. El dormitorio.* [lugar dormitory · plano .5,.6 x1.35]
- Narración: Diecinueve discípulos duermen. Ren abre su baúl sin hacer ruido.
- [plano .45,.7 x1.6 lento]
- Narración: En una esquina de la manta, bordado con hilo gris, hay un dibujo que vio mil veces sin mirarlo.
- Narración: Seis puntos alrededor de uno.
- Ren [entra izq] *(pensando)*: …¿Quién la bordó?
- Ren *(pensando)*: ¿Y por qué un ninja deja el mismo dibujo en nuestro muro?

#### s2 · Patio de entrenamiento
Rival: el explorador capturado · IA: fácil · Regla: el rival no usa habilidad
**Antes**
- *A la mañana. Patio de entrenamiento.* [plano .2,.55 x1.3]
- [plano .75,.5 x1.15 lento]
- Narración: El sol pega sobre los postes de madera. En el patio nadie habla de otra cosa: anoche entraron ninjas al Templo.
- Gon [entra der corre]: ¡Ren! ¿Te enteraste?
- Ren [entra izq]: ¿De qué?
- Gon: Atrapé a un explorador en el bosque, al alba. Yo solo.
- Ren: ¿Vos solo? ¿Y ese brazo vendado?
- Gon: …Me caí. Persiguiéndolo.
- Ren *(pensando)*: Gon no se cae nunca.
- Gon: El ninja que perseguiste vos se escapó, me dijeron.
- Ren: Saltó el muro. No llegué.
- Gon: Ya sé. Lo sabe todo el Templo.
- Gon: Esta vez el Abad me felicitó a mí.
- Ren: Te lo ganaste, Gon. De verdad.
- Gon *(pensando)*: Dos palabras me dijo. «Bien hecho.» A Ren le habría dicho diez.
- Gon *(pensando)*: Y nadie puede saber dónde estaba yo antes del alba.
- Mei [entra centro]: Basta de charla.
- Mei: Antes de interrogar al explorador que atrapó Gon, el Abad quiere ver cómo pelea Ren contra él.
- Gon: ¿Ren? ¡Lo atrapé yo!
- Mei: Por eso hoy descansás vos. Con ese brazo, además.
- Gon: …
- [sale Gon · entra Explorador der sombra]
- Narración: Traen al preso con las muñecas atadas. Tiene la edad de un hermano mayor y la sonrisa de alguien que no tiene miedo.
- Ren *(pensando)*: Es el del muro. El que dejó la marca.
- Mei: Con las manos atadas no puede usar el Kawarimi. Jugá limpio igual, Ren.
- Explorador: Atado y todo, te gano, monjecito.
- Explorador: ¿Dormiste bien? Yo no. Las celdas de ustedes tienen goteras.

**Después**
- *El patio, al mediodía.* [lugar yard · plano .5,.55 x1.2]
- Mei [entra der]: Bien. Rodeás con paciencia. Eso es lo importante.
- Ren [entra izq]: Maestra, ¿por qué siempre rodeamos?
- Ren: ¿Por qué no golpeamos y ya? Sería más rápido.
- [plano .72,.45 x1.45 lento]
- Mei: …
- Mei: Yo le hice la misma pregunta a mi maestra. Tenía tu edad.
- Ren: ¿Y qué le contestó?
- Mei: «Porque así nos enseñaron.»
- Ren: Eso no es una respuesta.
- Mei: No. No lo es.
- Mei: Ella se murió sin contestarla. Yo me prometí que no iba a hacer lo mismo.
- Mei: Y acá estoy. Haciendo lo mismo.
- [sale Mei · plano .4,.5 x1.2 lento]
- Ren *(pensando)*: Nunca había visto a la Maestra Mei bajar la vista.
- Explorador [entra der sombra]: En el clan también rodeamos, ¿sabés?
- Ren: ¿Ustedes?
- Explorador: Mi abuela decía que no es una pelea. Que es una oración.
- Ren: ¿Una oración a quién?
- Explorador: Eso nunca lo dijo. Se murió el invierno pasado, tosiendo.
- Explorador: Tosía gris, monjecito. Como ceniza.
- Ren: La marca del muro. Seis puntos alrededor de uno. ¿Qué significa?
- Explorador: …
- Explorador: ¿Dónde más la viste?
- Ren *(pensando)*: Lo preguntó demasiado rápido.
- Explorador: Te propongo un cambio. Vos me decís dónde la viste y yo te digo a qué vine.
- Mei [off]: Ren. Con el preso no se negocia.
- Explorador: Pensalo. Esta noche me traen arroz frío. Si querés, traelo vos.

#### s3 · Emboscada en el bosque
Rival: tres ninjas · IA: fácil · Regla: tu Monje empieza con 3 fichas enemigas al lado
**Antes**
- *Esa tarde. El camino al pueblo.* [plano .2,.45 x1.35]
- [plano .6,.5 x1.1 lento]
- Narración: Ren baja al pueblo a buscar arroz. El canasto vacío le golpea la espalda.
- Ren [entra izq] *(pensando)*: «¿Dónde más la viste?» Lo preguntó como si le fuera la vida.
- Ren *(pensando)*: Una abuela que tosía ceniza. Polvo gris en las mangas del maestro. Una marca en el muro y en mi manta.
- Ren *(pensando)*: Nada de esto tiene sentido. Y todo se parece.
- Ren: Qué silencio…
- [plano .22,.3 x1.5]
- Narración: Ni un pájaro. Ni el viento. El bosque contiene la respiración.
- [entra Ninja der sombra · entra Kunoichi centro sombra · temblor · destello]
- Narración: Tres sombras caen de los árboles. Antes de tocar el suelo, ya lo rodearon.
- Ninja: Es él. El discípulo del Abad.
- Ren: ¿Me conocen?
- Kunoichi: Todo el clan conoce al chico de la manta.
- Ren *(pensando)*: …La manta.
- Ren: ¿Qué saben de mi manta?
- Ninja: Que vale lo mismo que un explorador preso.
- Kunoichi: Te llevamos a la pagoda. Mañana el Templo nos devuelve a Sora y vos volvés a casa.
- Ren: ¿Sora? ¿Así se llama?
- Ninja: Sin lastimarlo. El Shogun fue claro.
- Kunoichi: El Shogun no sabe que estamos acá. ¡Rodéenlo!

**Después**
- *El camino, al caer el sol.* [lugar road · plano .55,.5 x1.2]
- [entra Ren izq · entra Ninja der]
- Ren: ¿Por qué tu Shogun no quiere que me lastimen?
- Ninja: …
- Ren: ¿Qué es eso del chico de la manta? ¡Contestame!
- Ninja: No es a mí a quien tenés que preguntarle.
- Ninja: Preguntale a tu Abad qué guarda abajo. Y qué encontró en el escalón hace dieciséis años.
- [sale Ninja corre · plano .85,.4 x1.3 lento]
- Ren *(pensando)*: ¿Abajo?
- [plano .4,.65 x1.4 lento]
- Narración: El canasto quedó volcado. El arroz, desparramado en el camino.
- Ren *(pensando)*: Tres ninjas desobedecen a su Shogun por un explorador.
- Ren *(pensando)*: Junto el arroz igual. Si nadie le lleva la cena a Sora, se la llevo yo.

#### s4 · La celda
Rival: rescatistas ninja · IA: fácil · Regla: normal
**Antes**
- *Noche. Las celdas del Templo.* [plano .15,.45 x1.5]
- [plano .7,.5 x1.25 lento]
- Narración: Bajo el ala vieja del Templo arde una sola antorcha. Detrás de los barrotes, alguien no duerme.
- [entra Explorador der sombra · plano .72,.55 x1.4]
- Ren [entra izq]: Te traje arroz.
- Explorador: …¿Envenenado?
- Ren: Con tierra, nada más. Tus amigos me lo tiraron en el camino.
- Explorador: ¿Mis amigos?
- Ren: Tres. Querían cambiarme por vos.
- Explorador: …Idiotas. El Shogun los va a colgar de los pulgares.
- Explorador: ¿Te lastimaron?
- Ren: No. Tenían órdenes de no hacerlo.
- Explorador: …
- Explorador: Gracias por el arroz. Me llamo Sora.
- Ren: Ya sé. Lo gritaron ellos.
- Ren: A mí me llamaron «el chico de la manta». ¿Qué saben de mí?
- Explorador: Menos de lo que creés. Más de lo que deberíamos.
- Ren: Mi manta tiene bordada la marca que dejaste en el muro.
- Narración: Sora deja de comer.
- Explorador: …¿Seis puntos alrededor de uno?
- Ren: En hilo gris. En una esquina.
- Explorador: Entonces era verdad. Ella tenía razón.
- Ren: ¿Quién?
- Explorador: No, chico. Si te lo digo yo, no me vas a creer. Lo tenés que ver.
- Explorador: Mi hermana menor es igual que vos. Pregunta y pregunta. Algún día se van a conocer.
- [plano .5,.15 x1.4 · onom golpe · temblor]
- Narración: Un golpe seco en el techo. Después, otro.
- Explorador: …No. Le dije a mi hermana que no viniera.
- [humo · destello]
- Gon [entra centro corre]: ¡Ren! ¡Vinieron a sacarlo! ¡Están en el techo!

**Después**
- *El humo se disipa. Las celdas.* [plano .25,.5 x1.45]
- [plano .68,.5 x1.25 lento]
- Narración: Los rescatistas huyeron por el techo. Al preso lo dejaron atrás.
- [entra Explorador der sombra]
- Ren [entra izq]: Tus amigos te abandonaron.
- Explorador: No venían a sacarme. Venían a distraerte.
- Ren: ¿Distraerme de qué?
- Explorador: De la que vino de verdad: mi hermana. Ahora mismo está peleando con tu Maestra Mei en el pasillo de arriba.
- Explorador: Escuchame, que no hay tiempo. No venimos a robar.
- Explorador: **Venimos a advertir.**
- Ren: ¿Advertir qué?
- Explorador: Lo que tu Abad guarda abajo…
- [niebla · plano .5,.5 x1.1 lento]
- Narración: La antorcha se apaga sola. Por debajo de la puerta entra una niebla fría.
- [arte art_fox_cell · plano .82,.45 x1.2 · latido]
- Narración [plano .38,.5 x1.1 lento]: En la puerta de la celda hay una zorra blanca. Nadie la vio entrar.
- Zorra Blanca [plano .54,.5 ancho .8 lento]: Todavía no es momento de que el chico sepa lo que hay abajo.
- [lugar cells · entra Ren izq ya · entra Explorador der ya · entra Zorra Blanca centro humo · niebla · plano .55,.5 x1.2]
- Explorador: …Sí, señora.
- Ren: ¿Señora? ¿Le hablás a una zorra?
- Zorra Blanca: Sora me escucha. Es más de lo que hace la mayoría de los hombres.
- Zorra Blanca: Comé vos el arroz, chico de la manta. Lo vas a necesitar.
- Ren: ¡Esperá! ¿Sabés quién bordó mi manta?
- Zorra Blanca: Cuando la piedra lata, lo vas a saber.
- [sale Zorra Blanca humo · sale Explorador humo · destello · niebla]
- Narración: La zorra y el preso desaparecen en la niebla.
- [plano .72,.5 x1.55 lento]
- Ren *(pensando)*: La celda sigue cerrada. Con llave. Desde afuera.
- Ren *(pensando)*: ¿Qué piedra?

#### s5 · El muro norte
Rival: el clan cubre la huida · IA: fácil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Minutos después. El muro norte.* [plano .6,.45 x1.4 · humo]
- Gon [entra der corre]: ¡Están por todo el muro! Cubren la huida de alguien.
- Ren [entra izq corre]: Gon, ¿viste a una zorra? ¿O al preso?
- Gon: ¿Qué zorra? ¡El preso no está! ¡Y la celda seguía cerrada!
- Gon: Ren, si cruzan el muro norte, bajan derecho al pueblo.
- Ren: …Tu hermana. Hana.
- Gon: Mi hermana tiene ocho años. Duerme al lado del camino.
- [plano .72,.42 x1.45]
- Gon: Por eso no pasa ninguno. Ninguno.
- Ren: Gon. Lo del brazo. No te caíste.
- Gon: …
- Gon: Después. Si salimos de esta, te cuento.
- Gon: ¡Concentrate, Ren! Son muchos, y la noche es larga.

**Después**
- [plano .5,.5 x1.1 lento]
- Narración: Los ninjas se retiran al bosque. El muro queda en silencio.
- Gon [entra der]: ¡Corren como conejos!
- Ren [entra izq]: El brazo, Gon.
- Gon: …
- Gon: La otra noche el Abad me despertó. A mí solo. Me mandó a cuidar la escalera de la cripta.
- Gon: Me dijo: «Nadie baja. Y no se lo cuentes a nadie. Ni a Ren.»
- Ren *(pensando)*: Ni a mí.
- Gon: Vino una ninja. Chiquita, con un abanico. Me ganó en tres movimientos.
- Gon: Y antes de bajar me pidió perdón.
- Ren: ¿Bajó?
- Gon: Hasta la puerta de piedra. Después sonaron las campanas y se fue.
- Gon: Por eso salí a cazar al explorador. No podía volver con las manos vacías.
- Gon: No se lo cuentes a nadie, Ren.
- Ren: ¿Que perdiste?
- Gon: Que tengo miedo de lo que hay ahí abajo.
- [sale Gon · plano .4,.5 x1.2 lento]
- Ren *(pensando)*: «Venimos a advertir.» «Lo que guarda abajo.» Una escalera que yo no puedo conocer.
- [plano .9,.3 x1.5 lento]
- Ren *(pensando)*: Mañana le pregunto al Abad. Aunque se enoje.

#### s6 · JEFE — Kuro, el jonin del humo
Rival: Kuro · IA: fácil (jefe) · Regla: Kuro tiene un Shinobi de más
**Antes**
- *Amanecer. El portón principal.* [plano .3,.55 x1.3]
- [plano .55,.5 x1.15 lento]
- Narración: La niebla del alba cubre los escalones. Alguien espera en la puerta, solo. No se esconde.
- [entra Kuro der sombra · humo]
- Kuro: El chico de la manta.
- Ren [entra izq]: ¿Por qué todos me llaman así? ¿Quién sos?
- Kuro: Kuro. El que se queda atrás para que los demás lleguen a casa.
- Kuro: Me contaron que rodeás bien. Que le llevaste arroz a un preso.
- Kuro: Un monje que le da de comer a un ninja… Eso no se ve seguido.
- Ren: ¿Llegaron? Sora y la del abanico.
- Kuro: …Sabés demasiado para ser un novicio.
- Ren: Y no entiendo nada. ¿Qué quieren del Templo?
- Kuro: Lo que es nuestro. El Pergamino de Jade. Hoy, o la próxima vez.
- Ren: El Pergamino es sagrado. Nadie lo saca de la biblioteca.
- Kuro: ¿Lo viste alguna vez?
- Ren: …
- Kuro: Yo tampoco. Ninguno de los dos defiende algo que haya visto.
- Kuro: Hagamos que al menos la pelea valga la pena.

**Después**
- Kuro [entra der]: Bien peleado. Mejor que cualquiera de los míos a tu edad.
- Kuro: Pero no entendés nada de lo que defendés.
- Ren [entra izq]: ¡Entonces explicame!
- Kuro: No me toca. Hace dieciséis años juré no contarlo.
- Ren: ¿Dieciséis años? ¿Vos estabas…?
- Kuro: Preguntale a tu maestro quién te dejó en el escalón. Y mirale los ojos cuando conteste.
- [sale Kuro humo · humo]
- Ren: ¡Esperá!
- *Más tarde. La sala del Abad.* [lugar abbotHall · plano .7,.5 x1.3]
- Ren [entra izq]: Maestro, los ninjas dicen que vienen a advertir.
- Abad [entra der]: …
- Ren: Hablan de algo que guardamos abajo. Usted puso a Gon a cuidar la cripta y le prohibió decírmelo.
- Abad: Gon habla de más.
- Ren: Y mi manta tiene bordada la marca del muro. Seis puntos alrededor de uno.
- Narración: El Abad no contesta. Por primera vez en dieciséis años, no mira a Ren a los ojos.
- Ren *(pensando)*: «Mirale los ojos cuando conteste.»
- Ren: Maestro. ¿Quién me dejó en el escalón?
- Abad [temblor]: **Olvidalo.** Es una orden.
- Ren *(pensando)*: Nunca me había gritado.
- [temblor · onom temblor]
- Narración: El suelo tiembla, apenas.
- [arte art_ash_ceiling · plano .3,.65 x1.25]
- Narración [plano .55,.25 x1.15 lento]: Del techo cae un polvo gris.
- Ren [plano .43,.5 ancho .8 lento]: ¿Maestro…?
- Narración: No es polvo. Es **ceniza**.
- Ren *(pensando)*: Lo mismo que el Maestro tenía en las mangas la noche del muro.
- Abad *(pensando)*: Ya empezó.
- Abad *(pensando)*: Igual que la noche en que ella me puso a este chico en los brazos.
- **→ Fin del Acto I · desbloqueo**

### Acto II · El bosque de los susurros

#### s7 · Huellas
Rival: exploradores · IA: fácil · Regla: normal
**Antes**
- *Dos días después. La escalera de la montaña, antes del alba.* [plano .8,.45 x1.4]
- [plano .55,.55 x1.1 lento]
- Narración: Desde la noche de la ceniza, el Abad no le habla. Mei tampoco. A Gon lo mandaron a cuidar la cripta día y noche.
- Narración: Ren baja la escalera con un atado al hombro. Adentro, la manta.
- Ren [entra izq] *(pensando)*: «Preguntale a tu Abad qué guarda abajo.» Le pregunté. Me gritó.
- Ren *(pensando)*: Si nadie en el Templo me contesta, voy a buscar a alguien de afuera.
- Tao [off]: ¿Saliendo a escondidas, chico? *hip*
- Ren: ¡Maestro Tao!
- Tao [entra der]: Yo no vi nada. Nunca veo nada. Es mi mayor talento. *hip*
- Ren: ¿Le va a decir al Abad?
- Tao: ¿Al Abad? Hace dieciséis años que el Abad y yo no nos decimos nada importante.
- Ren *(pensando)*: Dieciséis años. Otra vez ese número.
- Tao: ¿Qué llevás en ese atado?
- Ren: …Mi manta.
- Narración: Tao deja de sonreír. Por un momento, parece que no tomó nada en toda su vida.
- Tao: Guardala bien. Y no se la muestres a cualquiera.
- Tao: Te acompaño hasta el río. Más allá no.
- Ren: ¿Por qué no más allá?
- Tao: Porque estoy viejo. Y porque lo juré. *hip*
- [plano .2,.4 x1.4]
- Narración: Entre los pinos, alguien los mira. Exploradores del clan, vigilando el Templo desde la noche del muro.
- Tao: Ah. Tenemos público. Andá, chico. Yo aplaudo.

**Después**
- *El sendero, más adelante.* [lugar mountainPath · plano .3,.6 x1.5]
- [plano .25,.65 x1.8 lento]
- Narración: Los exploradores huyen. Dejan huellas en el barro: pies livianos, de los que no quieren ser vistos.
- Tao [entra der]: Van al este. Al santuario viejo.
- Ren [entra izq]: ¿Hay un santuario al este? Nunca lo oí nombrar.
- Tao: Porque al Templo no le gusta nombrarlo. Ahí hay piedras que cuentan lo que el Templo calla.
- Ren: ¿Usted las vio?
- Tao: Yo veo poco. Tomo mucho. *hip*
- Tao: Pero la última vez que alguien siguió estas huellas fue hace dieciséis años.
- Tao: Un monje joven, el mejor de su generación. Bajó la montaña con preguntas.
- Ren: ¿Y qué le pasó?
- Tao: Volvió sin el hábito. El Abad lo echó esa misma noche.
- Tao: La misma noche en que vos llegaste al escalón.
- Ren *(pensando)*: …
- Ren *(pensando)*: Para alguien que olvidó todo, lee muy bien las huellas. Y las fechas.

#### s8 · El puente de piedra
Rival: guardia del puente · IA: normal · Regla: el Asedio empieza en la ronda 15
**Antes**
- *El único puente sobre el río.* [plano .5,.35 x1.4]
- [plano .5,.6 x1.15 lento]
- Narración: El río ruge abajo. Del otro lado empieza la tierra del clan.
- Narración: Los ninjas bloquean el puente de punta a punta.
- Ren [entra izq]: Maestro, ¿me ayuda?
- Tao [entra centro]: Yo de acá no paso. Este río es mi frontera.
- Ren: ¿La de quién?
- Tao: La mía y la del Abad. La juramos juntos, una noche en que llovía gris.
- Tao: Él juró no hablar nunca más de esa noche. Yo juré no cruzar este puente nunca más.
- Tao: Él cumplió. Yo también. Y mirá cómo nos fue. *hip*
- [entra Kunoichi der sombra]
- Kunoichi: …No puede ser.
- Kunoichi: ¡El chico de la manta! ¡Otra vez vos!
- Ren *(pensando)*: Es la del camino. La que quería cambiarme por Sora.
- Ren: ¿Qué hacés acá?
- Kunoichi: El Shogun nos castigó por desobedecer. Un mes cuidando este puente, comiendo pescado crudo.
- Kunoichi: Todo por tu culpa.
- Ren: ¿Mi culpa? ¡Me emboscaron ustedes!
- Kunoichi: Detalles. Esta vez no hay órdenes de cuidarte. Bueno, sí hay. Pero no de dejarte pasar.
- Tao [off]: ¡La batalla va a ser larga, chico! ¡Y no hay por dónde retirarse!
- Ren: ¡Gracias, maestro!
- Tao [off]: ¡De nada! *hip*

**Después**
- *La otra orilla.* [lugar bridge · plano .85,.55 x1.4]
- Ren [entra izq corre]: ¡Pasé!
- [entra Kunoichi der sombra]
- Kunoichi: Pasaste. Ahora el Shogun me va a dar otro mes.
- Ren: ¿Por qué tu Shogun me cuida? Decímelo y te dejo tranquila.
- Kunoichi: Porque sos una deuda.
- Kunoichi: Es lo único que sé. Lo dijo él mismo, la noche que llegaste al Templo. Yo era una nena.
- Kunoichi: «El clan le debe una vida a ese chico. Y el clan paga lo que debe.»
- [sale Kunoichi corre · plano .2,.55 x1.4 lento]
- Narración: Del otro lado del río, Tao levanta la calabaza en un brindis.
- Tao [entra der]: ¡Nunca dudé!
- Tao: Bueno. Un poco.
- Tao: ¡Chico! Si encontrás a un ronin con una cicatriz en la ceja, decile una cosa de mi parte.
- Ren: ¿Qué cosa?
- Tao: Que Tao todavía le guarda el cuenco. Y que no fue culpa suya.
- Ren *(pensando)*: ¿Qué no fue culpa suya?

#### s9 · Las tallas
Rival: Jubei, el ronin · IA: normal · Regla: normal
**Antes**
- *El santuario abandonado.* [plano .2,.4 x1.4]
- [plano .55,.55 x1.1 lento]
- Narración: Musgo, piedras caídas, un torii que nadie cuida. Y algo tallado en la roca.
- [arte art_carvings · plano .45,.3 x1.6]
- Narración [plano .48,.45 ancho .7 lento]: Seis piedras en hexágono, alrededor de una figura con cuernos. De un lado, una mano con cuentas de monje. Del otro, una mano con un tantō.
- Ren: Ese es el símbolo del Templo…
- Ren: …y ese es el del clan. Las dos manos cierran el mismo círculo.
- Ren *(pensando)*: Seis puntos alrededor de uno. Como mi manta.
- [lugar shrine · entra Ren izq ya · plano .7,.5 x1.25]
- Jubei [entra der sombra]: Nadie mira esas piedras hace siglos. ¿Qué hace un monje acá?
- Ren: Busco a alguien que me diga la verdad.
- Jubei: Mal lugar. Acá solo hay piedras y un ronin que perdió las ganas de hablar.
- Ren: ¿Tenés una cicatriz en la ceja?
- Jubei: …
- Jubei: ¿Quién te mandó?
- Ren: Tao. Dijo que te guarda el cuenco.
- Narración: El ronin se ríe sin ganas, como quien recibe una carta muy vieja.
- Jubei: Ese borracho. Sigue vivo.
- Jubei: Esta mañana me crucé con una ninja que me dijo un nombre que no oía hace dieciséis años. Y ahora vos me traés a Tao.
- Jubei: Hoy los muertos tienen ganas de hablar.
- Jubei: Mostrame cómo peleás. Si rodeás como te enseñó Hōshin, no tenemos nada que decirnos.

**Después**
- [entra Jubei der · entra Ren izq]
- Jubei: No rodeás como Hōshin. Rodeás como alguien que espera.
- Jubei: Fui monje, ¿sabés? Me echaron por preguntar qué dice el Pergamino de Jade.
- Ren: Tao dijo que te echaron la noche en que yo llegué.
- Jubei: …
- Ren: Me dejaron en el escalón del Templo, envuelto en esto.
- Narración: Ren desata el atado y abre la manta sobre la piedra.
- [plano .45,.6 x1.6 lento]
- Narración: Seis puntos alrededor de uno, en hilo gris.
- Jubei: …
- Jubei: ¿De dónde sacaste esto?
- Ren: Ya te dije. Llegué envuelto en ella.
- Jubei: No. No puede ser.
- Jubei: Hōshin me dijo que el bebé había muerto esa noche. Con ella.
- Ren: ¿Con quién?
- Narración: Jubei no contesta. Mira la manta como si quemara.
- Jubei: Esta noche no. No puedo.
- Jubei: Mañana te cuento todo. Te lo juro, chico.
- Ren *(pensando)*: Todos juran algo. Nadie me cuenta nada.

#### s10 · Cuatro sombras
Rival: refuerzos del clan · IA: normal · Regla: el rival tiene 4 Shinobi
**Antes**
- *El bosque, de noche.* [plano .65,.3 x1.4 · niebla]
- [plano .3,.55 x1.15 lento]
- Narración: Jubei hizo un fuego y no habló en horas. Ahora lo mira a Ren como si buscara algo en su cara.
- Jubei [entra der]: ¿Hōshin te trató bien?
- Ren [entra izq]: Como a un hijo. Me enseñó a leer, a rodear, a no tener miedo.
- Jubei: …Bien. Eso es bueno.
- Jubei: Siempre fue mejor maestro que persona.
- Ren: ¿Por qué te importa tanto cómo me trató?
- Jubei: Porque…
- [plano .12,.5 x1.5]
- Narración: Entre los bambúes, una sombra. Dos. Cuatro.
- Jubei: Te siguieron desde el santuario. No son exploradores: son shinobi del Shogun.
- Ren: Los Shinobi se meten por cualquier rendija.
- Jubei: Entonces no dejes rendijas. Y no te alejes del fuego.

**Después**
- [plano .5,.65 x1.5 lento]
- Narración: Un shinobi caído suelta algo al huir: un pergamino pequeño, atado con hilo rojo.
- Ren [entra izq]: Tiene el sello del Shogun.
- Jubei [entra der]: Leelo.
- Ren *(leyendo)*: «Traigan el Pergamino de Jade antes de la luna nueva. Si cae ceniza, ya no hay tiempo de pedirlo.»
- Jubei: La luna nueva es en diez días.
- Ren: ¿Por qué la luna nueva?
- Jubei: Porque es la noche más oscura. Las cosas que duermen bajo tierra la sienten.
- Jubei: Hace dieciséis años también cayó ceniza. Y también faltaban diez días para la luna nueva.
- Ren: ¿Qué pasó esa luna nueva?
- Jubei: Alguien bajó a la cripta a hacer algo que no sabía hacer sola.
- Jubei: Y yo llegué tarde.
- *Más tarde. El fuego, casi apagado.* [lugar forest · plano .5,.6 x1.3 lento]
- Narración: Ren se duerme envuelto en la manta. Jubei vela hasta el alba.
- Narración: Cuando Ren despierta, el ronin no está. En su lugar quedó un cuenco de madera y una nota.
- Ren [entra izq] *(leyendo)*: «Perdón. Antes de contarte, tengo que hablar con alguien. Esperame en el santuario pasado mañana, al alba.»
- Ren *(pensando)*: ¿Con quién? ¿Con el Abad?
- Ren *(pensando)*: El cuenco tiene algo tallado abajo. Un nombre: Natsu.

#### s11 · Niebla en el valle
Rival: patrulla en la niebla · IA: normal · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *El valle. Niebla espesa.* [plano .5,.5 x1.3 · niebla]
- [plano .25,.6 x1.15 lento]
- Narración: En la niebla nada se queda quieto. Ren camina hacia el santuario sin saber si va bien.
- Ren [entra izq] *(pensando)*: Natsu. ¿Quién es Natsu?
- Ren *(pensando)*: «El bebé murió esa noche. Con ella.» ¿Natsu es «ella»?
- [plano .75,.55 x1.3 · latido]
- Zorra Blanca [entra der humo]: Si seguís por ahí, caés al río, pequeño monje.
- Ren: ¡Vos! La de la celda.
- Zorra Blanca: La de la celda, la del muro, la del bosque. Siempre la misma. Pocos me miran dos veces.
- Ren: ¿Qué sos?
- Zorra Blanca: La que recuerda.
- Ren: Entonces recordame algo. ¿Quién es Natsu?
- Zorra Blanca: Una chica que bordaba mal y rodeaba bien.
- Zorra Blanca: Tu manta la empezó una mano vieja y la terminó una mano joven. Las dos temblaban.
- Ren: ¿Por qué temblaban?
- Zorra Blanca: Porque sabían adónde ibas a ir.
- Narración: En la niebla se mueven formas. Una patrulla del clan, peinando el valle.
- Zorra Blanca [sale Zorra Blanca humo]: Primero salí del valle. Después preguntá.

**Después**
- *La salida del valle.* [lugar valley · plano .8,.4 x1.35]
- [entra Ren izq · entra Zorra Blanca der]
- Zorra Blanca: Mañana, en el santuario, vas a conocer a alguien que hace tus mismas preguntas.
- Ren: ¿El ronin? Dijo que me esperaba ahí.
- Zorra Blanca: El ronin fue a buscar a un viejo amigo del Templo. Hace dieciséis años que no se miran a la cara.
- Zorra Blanca: La que vas a conocer viene del otro lado.
- Ren: ¿Del otro lado del valle?
- Zorra Blanca: Del otro lado de la guerra.
- Zorra Blanca: No la lastimes. Es la única que puede contestarte.
- Ren: ¿Y si ella me lastima a mí?
- Zorra Blanca: Entonces van a aprender rápido. Los dos.
- [sale Zorra Blanca humo · plano .85,.35 x1.5 lento]
- Ren *(pensando)*: Una mano vieja y una mano joven.
- Ren *(pensando)*: Alguien me bordó una despedida.

#### s12 · JEFE — Aya *(duelo cruzado)*
Rival: Aya · IA: normal (jefe) · Regla: normal
**Antes**
- *El santuario, al amanecer.* [plano .2,.45 x1.4]
- [arte art_duel_shrine · plano .5,.45 x1.6]
- Narración [plano .5,.5 ancho .8 lento]: Dos sombras en el mismo claro. Ninguna se mueve primero.
- Aya [lugar shrine · entra der sombra · plano .65,.5 x1.25]: Un monje. Solo. En mi bosque.
- Ren [entra izq]: No es tu bosque. Y no vine solo: me mandó una zorra.
- Aya: …A mí también.
- Ren: Sos la del abanico. La que le ganó a Gon en la escalera y le pidió perdón.
- Aya: Y vos sos el que le llevó arroz a mi hermano.
- Ren: ¿Sora es tu hermano? Me dijo que tenía una hermana que preguntaba demasiado.
- Aya: Y él dijo que el arroz tenía tierra. Y que fue lo más rico que comió en una semana.
- Ren: Busco a un ronin. Jubei. Me citó acá.
- Aya: Yo también lo busco. A mí me citó la zorra.
- Ren: No vino.
- Aya: No.
- Aya: En el clan te dicen el chico de la manta. El Shogun te cuida como a un tesoro y no dice por qué.
- Aya: Mostrame esa manta.
- Ren: Todos quieren algo de mí y nadie me da nada. Primero ganame.
- Aya: Igual te iba a ganar.

**Después**
- Aya [entra der]: Ganaste. Esta vez.
- Ren [entra izq]: Igual te la voy a mostrar. Quiero ver qué cara ponés.
- Narración: Ren abre la manta sobre la piedra del santuario.
- [plano .5,.6 x1.6 lento]
- Narración: Seis puntos alrededor de uno, en hilo gris.
- Aya: …
- Aya: Ese bordado lo conozco. Puntada por puntada.
- Ren: ¿De dónde?
- Aya: Mi abuela Kiku lo bordaba. En el paño de su tablero. En la capa de mi primera misión.
- Aya: Y solo bordaba para la familia.
- Ren: …
- Aya: Esa puntada torcida en la esquina… Esa no es de ella. Es de alguien que estaba aprendiendo.
- Ren *(pensando)*: «La empezó una mano vieja y la terminó una mano joven.»
- Ren: ¿Quién es Natsu?
- Narración: Aya da un paso atrás, como si le hubieran pegado.
- Aya: ¿Dónde oíste ese nombre?
- [onom campana · plano .15,.4 x1.4]
- Narración: Entre los árboles suenan cascabeles. Una patrulla del Templo sube por el sendero.
- Aya: Monjes. Tuyos. Vienen a buscarte.
- Ren: ¡Esperá! ¡Contestame!
- Aya: Natsu era la hermana de mi madre. La hija menor de mi abuela Kiku.
- Aya: Murió hace dieciséis años. Eso dice su tumba.
- [sale Aya humo · humo · destello]
- Narración: Una bomba de humo. Aya ya no está.
- [plano .5,.6 x1.4 lento]
- Ren *(pensando)*: Solo bordaba para la familia.
- Ren *(pensando)*: …¿La familia de quién soy yo?
- **→ Fin del Acto II**

### Acto III · La biblioteca cerrada

#### s13 · El regreso
Rival: Gon (entrenamiento) · IA: normal · Regla: normal
**Antes**
- *El Templo. Ren vuelve con la patrulla.* [plano .5,.6 x1.4]
- [plano .3,.5 x1.15 lento]
- Narración: El incienso sigue ardiendo, como siempre. Pero hay guardias donde nunca hubo, y nadie lo mira a los ojos.
- Gon [entra der]: Dos días, Ren. Dos días sin decir nada.
- Ren [entra izq]: ¿Te mandó el Abad a buscarme?
- Gon: Me mandó a traerte antes de que hablaras con el ronin.
- Gon: ¿Hablaste con el ronin?
- Ren: …
- Gon: Lo sabía.
- Ren: ¿Por qué el Abad le tiene miedo a un hombre que vive solo en el bosque?
- Gon: No sé. No me lo explica. Me da órdenes y yo las cumplo. Como vos antes.
- Ren: ¿Y la biblioteca? Vi el candado desde el portón.
- Gon: El Abad le puso candado la noche que te fuiste. Y puso guardias en la cripta. Algo pasa abajo, Ren.
- Gon: Peleemos, como antes. Así me olvido un rato.

**Después**
- Gon [entra der]: Peleás distinto.
- Gon: Más… como ellos. Rodeás antes de atacar.
- Ren [entra izq]: Me lo enseñó una kunoichi. Sin querer.
- Gon: ¿La de la escalera? A mí también me enseñó algo. Que no sé perder.
- Ren: Gon, ¿vos sabés qué hay en la cripta?
- Gon: Sé que el Abad baja todas las noches. Y que sube con las manos grises, como si las hubiera metido en el fuego.
- Gon: Y sé otra cosa. En el pueblo los chicos tosen gris. Hana también.
- Ren: ¿Tu hermana?
- Gon: Tiene ocho años y tose ceniza, Ren. Por eso cumplo órdenes. Para que alguien arregle lo que está roto.
- [plano .85,.55 x1.5 lento]
- Gon: Si vos sabés algo, decímelo. Por Hana.
- Ren *(pensando)*: Sé un nombre. Natsu. Y no sé qué hacer con él.

#### s14 · Los novicios que sueñan
Rival: novicios inquietos · IA: normal · Regla: el rival no usa habilidad
**Antes**
- *El dormitorio de novicios.* [plano .2,.4 x1.4 · oscuro]
- [plano .6,.6 x1.15 lento]
- Narración: Es de noche y los más chicos no duermen. Se sientan juntos, con los ojos muy abiertos.
- Novicio [entra der]: Hermano Ren… soñamos con fuego.
- Ren [entra izq]: ¿Todos?
- Novicio: Todos. El mismo sueño. Desde que cayó la ceniza.
- [latido]
- Novicio: Una cosa con cuernos debajo de nuestros pies. Llama a alguien.
- Ren: ¿A quién?
- Novicio: Dice «Daishin». Una y otra vez. Como si lo extrañara.
- Ren: No conozco a ningún Daishin.
- Novicio: Y hay una señora que le tiene la mano. Para que no suba.
- Novicio: Tiene la cara de ceniza. Pero canta.
- Ren: …¿Qué canta?
- Novicio: No me acuerdo. Me despierto siempre antes del final.
- Narración: El más chico de todos dibuja algo en el polvo del piso, sin mirar. Seis puntos alrededor de uno.
- Ren *(pensando)*: El bordado de mi manta.
- Ren: Vamos. A entrenar, hasta que se cansen. Los cansados no sueñan.

**Después**
- [plano .5,.5 x1.2 lento · oscuro]
- Narración: Los novicios se duermen al fin, agotados. Ren no.
- *El patio de atrás, después de medianoche.* [lugar yard · plano .8,.5 x1.4 · oscuro]
- Narración: Detrás del pozo hay una piedra sin nombre. Ren pasó al lado mil veces y nunca la miró.
- Narración: Hoy tiene incienso fresco. Y un hilo gris atado alrededor.
- [plano .2,.5 x1.4]
- Narración: Alguien viene. Ren se esconde detrás del pozo.
- Abad [entra der sombra] *(en voz baja)*: Dieciséis años esta noche.
- Abad: Lo cuidé, como te prometí. Come bien. Pelea mejor que todos. Pregunta demasiado.
- Abad: Igual que vos.
- Ren *(pensando)*: ¿Esta noche? Esta noche… es la noche en que llegué al Templo.
- Abad: Ya no aguantás, ¿no? Lo siento en las manos.
- Abad: No te preocupes. Esta vez bajo yo.
- [plano .5,.5 x1.5 lento · latido]
- Abad: Y a él no lo voy a dejar bajar nunca. Nunca, Natsu.
- [sale Abad]
- Ren *(pensando)*: Natsu.
- Ren *(pensando)*: El maestro le habla a una piedra. Y la piedra sabe mi nombre.

#### s15 · La biblioteca
Rival: Maestra Mei · IA: normal · Regla: normal
**Antes**
- *La noche siguiente. La biblioteca.* [plano .1,.5 x1.4 · oscuro]
- [plano .55,.55 x1.2 lento]
- Narración: Ren fuerza la puerta. Los estantes huelen a polvo y a cera.
- Narración: No busca el Pergamino. Busca la crónica del Templo. El año en que él llegó.
- Ren [entra izq] *(pensando)*: Año del Buey de Agua. Otoño. La noche de la lluvia gris…
- [plano .45,.6 x1.5]
- Narración: La página no está. Alguien la arrancó con cuidado, a ras del lomo.
- Mei [entra der sombra]: La arranqué yo.
- Ren: ¡Maestra!
- Mei: Por orden del Abad. Hace dieciséis años. La quemé en este mismo brasero.
- Ren: ¿Qué decía?
- Mei: Lo que vos estás a punto de saber, si me ganás.
- Ren: ¿Y si pierdo?
- Mei: Vuelvo a cerrar con llave. Y mañana te olvidás de esta noche, como yo me olvidé de aquella.
- Mei: Nunca me olvidé.

**Después**
- Mei [entra der]: …
- Mei: Hay un sello, Ren. Abajo del Templo. Encierra algo que quemó estos valles hace trescientos años.
- [latido]
- Mei: Se está rompiendo. Ya se rompió una vez.
- Ren [entra izq]: Hace dieciséis años.
- Mei: Un monje joven y una chica del clan intentaron renovarlo. Sabían algo que el Templo olvidó a propósito: que hacen falta dos.
- Mei: El Abad se enteró. Hizo encerrar al monje esa noche.
- Ren: ¿Y la chica?
- Mei: La chica esperó al monje al pie de la escalera hasta que la luna se fue.
- Mei: Después subió al patio. Me encontró a mí y al Abad. Tenía un bebé envuelto en una manta.
- [plano .7,.45 x1.6 lento]
- Mei: Te puso en los brazos del Abad y le dijo: «Si no bajan dos, bajo sola. Cuidalo. Que no baje nunca.»
- Ren: …
- Mei: Esa noche llovió gris. Y el sello aguantó dieciséis años con una sola mano adentro.
- Ren: Se llamaba Natsu.
- Mei: Se llamaba Natsu. Era tu madre.
- Ren: ¿Y el monje? ¿Quién era?
- Mei: El Abad lo borró de todos los registros. Y yo juré no decir su nombre.
- Mei: Pero vos ya lo conociste, Ren. Te dio un cuenco.

#### s16 · Ceniza en el patio
Rival: incursión ninja · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Amanecer. El patio cubierto de ceniza.* [plano .5,.7 x1.5]
- [plano .5,.5 x1.05 lento]
- Narración: El temblor de la noche abrió una grieta en el patio. De ella sale humo gris.
- Ren [entra izq] *(pensando)*: Un cuenco tallado. «Natsu.»
- Ren *(pensando)*: Jubei lloró al ver la manta. Dijo que el bebé había muerto.
- Ren *(pensando)*: No murió. Está acá. Soy yo.
- [onom campana · temblor]
- Gon [entra der corre]: ¡Ninjas en el muro! ¡Aprovechan el caos!
- Narración: Cuatro sombras bajan por el muro norte. Pero no van hacia la biblioteca.
- Narración: Vienen derecho hacia Ren.
- Kunoichi [entra centro sombra]: ¡Ahí está! ¡El de la manta! ¡Llévenselo!
- Ren: ¿A mí?
- Kunoichi: Antes de la luna nueva la montaña se cobra lo que le deben. ¡No te vamos a dejar acá!

**Después**
- [plano .5,.6 x1.2 lento · humo]
- Narración: Los ninjas se retiran por el muro. La kunoichi se queda la última.
- Kunoichi [entra der sombra]: Sos testarudo. Igual que tu madre.
- Ren [entra izq]: ¿Conociste a mi madre?
- Kunoichi: Me enseñó a tirar estrellas. Yo tenía diez años.
- Kunoichi: El clan le debe una vida, chico. No a vos: a tu madre.
- Kunoichi: El Shogun no nos mandó. Nadie nos mandó. Vinimos igual.
- [sale Kunoichi humo]
- [plano .5,.72 x1.8 · latido · oscuro]
- Narración: La ceniza sigue cayendo, como nieve sucia. Entre la ceniza, por un momento, Ren ve dos ojos rojos.
- Narración: Y al lado, una mano gris que los tapa.
- Ren: …¿Lo viste?
- Gon [entra der]: ¿Ver qué? Ren, estás pálido.
- Ren *(pensando)*: Como en el sueño de los novicios: una mujer le tiene la mano al demonio, para que no suba.

#### s17 · La orden del Abad
Rival: kunoichi capturadas · IA: difícil · Regla: el rival tiene 3 Kunoichi
**Antes**
- *La sala del Abad.* [plano .6,.5 x1.3]
- Abad [entra der]: Tres kunoichi cayeron en el muro al alba. El temblor es culpa del clan.
- Ren [entra izq]: El temblor viene de abajo, maestro. Y usted lo sabe.
- Abad: …
- Ren: Anoche lo escuché. En la piedra sin nombre. Le habló a Natsu.
- Narración: El Abad no se da vuelta. Pero sus manos, grises hasta la muñeca, se cierran.
- Ren: Era mi madre. Mei me lo contó. ¿Por qué usted no?
- Abad: Porque tu madre me pidió una sola cosa. Que no bajaras nunca.
- Abad: El sello se cobra a quien lo cierra mal, Ren. Se la cobró a ella. No te va a cobrar a vos.
- Ren: ¡Y por eso encerró a mi padre!
- Abad [plano .65,.45 x1.45]: Tu padre quería bajar con ella. Yo quería que vivieran los dos.
- Abad: No vivió ninguno de los dos como debía. Esa culpa es mía. Y la voy a pagar yo.
- Abad: Vas a ir a la pagoda del clan. Vas a vencer a Kage.
- Ren: ¿Ahora? ¿Con el patio partido?
- Abad: Kage quiere el Pergamino. Si lo detenés, el Templo tiene tiempo.
- Abad: Las tres kunoichi esperan en el patio. Vencelas, y te doy la orden por escrito.

**Después**
- *El pasillo, al salir.* [lugar abbotHall · plano .15,.5 x1.4 · oscuro]
- Mei [entra der sombra] *(en voz baja)*: Ren. No vayas.
- Ren [entra izq]: Es una orden del Abad.
- Mei: Es una mentira con forma de orden.
- Mei: La luna nueva es mañana a la noche. Te manda lejos para que no estés cerca de la cripta.
- Ren: ¿Y el Abad?
- Mei: Va a bajar solo. Como bajó tu madre.
- [plano .2,.45 x1.6 lento]
- Mei: Y no va a subir.

#### s18 · JEFE — Tao, el monje borracho
Rival: Tao · IA: difícil (jefe) · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *El portón, de noche.* [plano .5,.4 x1.3 · oscuro]
- [plano .5,.6 x1.15 lento]
- Narración: Ren sale con la manta y el cuenco. No sabe si va a la pagoda o a la cripta. Solo sabe que no puede quedarse quieto.
- Narración: En el último escalón, alguien le bloquea el paso.
- Tao [entra der]: ¿Adónde, chico? *hip*
- Ren [entra izq]: No sé. Lejos de las mentiras.
- Tao: Entonces vas a caminar mucho.
- Ren: Usted también sabía. Todos sabían menos yo.
- Tao: Yo sé más que todos. Por eso tomo.
- Tao [plano .62,.45 x1.5]: Esa noche el Abad me dio una llave. «Encerrá al monje hasta que pase la luna.»
- Tao: Y yo lo encerré. Al monje más bueno que tuvo este Templo.
- Ren: …
- Tao: Natsu esperó a tu padre al pie de mi escalera. Tu padre golpeaba la puerta de mi celda. Y yo, del otro lado, tomando para no oírlo.
- Narración: Por una vez, Tao no parece borracho. Parece muy viejo.
- Ren: Dígame el nombre de mi padre. Quiero oírselo decir a alguien.
- Tao: Ganame y te lo digo. Perdé y te quedás, y mañana bajamos juntos a morir con el Abad.

**Después**
- Tao [entra der]: Bah.
- Tao: Sos terco como Daishin.
- Ren [entra izq]: El nombre, maestro.
- [plano .65,.4 x1.5 lento]
- Tao: Jubei.
- Tao: Tu padre se llama Jubei. Hace dos noches bajó a mi cripta por primera vez en dieciséis años.
- Tao: No me pegó. Me pidió perdón a mí. ¿Te das cuenta? A mí.
- Ren: ¿Dónde está?
- Tao: Se fue a la pagoda. A pedirle a Kage la mano que el clan no le dio a tu madre.
- Tao: Y Kage no presta su mano. La corta.
- Ren: Entonces voy a la pagoda. Pero no por el Abad.
- Tao: Por tu padre.
- Ren: Por los dos. Por los tres.
- [sale Tao · plano .5,.4 x1.1 lento]
- Narración: Ren baja la montaña. A su espalda, la campana del Templo no suena.
- Tao [off] *(desde el portón)*: ¡Ren! ¡Preguntale a Kage quién es Daishin! ¡Que te lo cuente entero!
- **→ Fin del Acto III**

### Acto IV · La pagoda

#### s19 · El primer piso
Rival: guardia de la pagoda · IA: difícil · Regla: normal
**Antes**
- *La pagoda del clan. La tarde de la luna nueva.* [plano .85,.3 x1.4]
- [arte art_pagoda · plano .2,.75 x1.6]
- Narración [plano .75,.35 x1.15 lento]: Ren camina toda la noche y toda la mañana. Llega con el sol bajando. La puerta está abierta, como si lo esperaran.
- [lugar pagoda · plano .82,.5 x1.4]
- Guardia [entra der]: El chico de la manta.
- Ren [entra izq]: ¿Me conocen?
- Guardia: Todo el clan te conoce. El Shogun dejó una orden por si venías.
- Ren: ¿Cuál?
- Guardia: Que subas si podés. Y que bajes entero si no.
- Ren: Busco a un hombre. Un ronin. Llegó hace dos días.
- Guardia [plano .7,.45 x1.4]: Los que suben preguntando, suben peleando.

**Después**
- Guardia [entra der]: …El Shogun tenía razón. Peleás como alguien de acá.
- Ren [entra izq]: ¿Como quién?
- Guardia: Preguntá arriba. Yo no quiero perder la cabeza.
- [sale Guardia corre · plano .82,.2 x1.6 lento]
- Narración: Desde arriba baja un silbido. Dos notas largas, una corta.
- Ren *(pensando)*: Alguien avisa que subo.
- Ren *(pensando)*: O alguien me llama.

#### s20 · El piso de los abanicos
Rival: kunoichi del clan · IA: difícil · Regla: el rival tiene 3 Kunoichi
**Antes**
- *Segundo piso. El de los abanicos.* [lugar pagodaTop · oscuro · plano .15,.5 x1.5]
- [plano .4,.45 x1.25 lento]
- Narración: Linternas rojas, cortinas que se mueven sin viento. En la pared, una fila de abanicos colgados. Uno de los ganchos está vacío.
- Kunoichi [entra der sombra]: No mires ese gancho, monje.
- Ren [entra izq]: ¿De quién era?
- Kunoichi: De una que se fue hace dieciséis años y no volvió. Nadie lo ocupó desde entonces.
- Ren: …Natsu.
- Narración: Las cortinas dejan de moverse.
- Kunoichi [plano .3,.45 x1.45]: Ese nombre no se dice en este piso. Y menos un monje.
- Kunoichi: Sacate esa manta. No es tuya.
- Ren: Es lo único que tengo de ella.

**Después**
- Kunoichi [entra der]: Tirás de costado, como ella. Nadie te lo enseñó, ¿no?
- Ren [entra izq]: Nadie.
- Kunoichi: Entonces lo traés en la sangre.
- Kunoichi *(en voz baja)*: Tu padre está encerrado en el cuarto piso, con Sora, el hermano de Aya. El Shogun espera en el quinto.
- Kunoichi: Y Aya se fue al Templo anoche. Mientras vos subís, ella entra en tu casa.
- [plano .55,.5 x1.2 lento]
- Ren *(pensando)*: Aya en el Templo. El Abad bajando solo.
- [latido]
- Ren *(pensando)*: Y la luna nueva, esta noche.

#### s21 · El piso de los Tengu
Rival: guardianes Tengu · IA: difícil · Regla: el rival tiene 3 Tengu
**Antes**
- *Tercer piso. Las vigas.* [lugar pagodaTop · oscuro · plano .1,.3 x1.6]
- [plano .35,.2 x1.4 lento]
- Narración: Los Tengu saltan de viga en viga. Nunca tocan el suelo.
- [entra Ninja der corre · temblor]
- Ren [entra izq]: ¡Bajen a pelear!
- Ninja: Un monje no pasa del tercer piso. Nunca pasó.
- Ren: Uno sí. Mi padre.
- Ninja: Tu padre subió con las manos abiertas. Lo dejamos pasar. Y el Shogun lo encerró igual.
- [plano .85,.3 x1.5 · niebla]
- Zorra Blanca [entra centro humo]: Dos caminos, una misma noche.
- Zorra Blanca: Apurate, pequeño monje. La mano que sostiene la piedra está temblando.

**Después**
- Ren [entra izq]: ¡Esperá! ¿La mano de quién?
- Zorra Blanca [entra der]: Ya sabés de quién.
- Ren: ¿La conociste?
- Zorra Blanca: La vi bordar tu manta junto al fuego de Kiku. Se pinchaba los dedos y se reía.
- Zorra Blanca [plano .7,.45 x1.4]: La noche que bajó me pidió una sola cosa: que te mirara crecer. Te miré.
- [sale Zorra Blanca humo]
- [plano .85,.25 x1.6 lento]
- Narración: Por la baranda se ve el Templo, lejos. Sobre él, una luz roja que no es el amanecer.

#### s22 · Kuro, otra vez
Rival: Kuro · IA: difícil · Regla: Kuro tiene un Shinobi de más
**Antes**
- *Cuarto piso. Las celdas.* [lugar pagodaTop · plano .5,.5 x1.3 · humo]
- Narración: Un pasillo de puertas con barrotes. Al fondo, dos sombras sentadas. Una tose.
- Kuro [entra der sombra]: Te dije que nos íbamos a ver.
- Ren [entra izq]: No vengo a robar nada.
- Ren: Vengo por el hombre de esa celda.
- Kuro: Ayer me ganó tu prima. Hoy vos. El clan se está poniendo viejo.
- Ren: ¿Mi prima?
- Kuro [plano .65,.45 x1.45]: Aya. ¿Nadie te lo dijo? Natsu era su tía.
- Ren: …
- Kuro: Ganame y abro. Perdé y te quedás con ellos hasta que pase la luna.

**Después**
- Kuro [entra der]: …
- Kuro: La última vez que alguien de tu sangre me ganó fue tu madre. Después la llevé hasta el muro del Templo, bajo la lluvia gris.
- Narración: Kuro saca una llave. La gira. La puerta chirría.
- [sale Kuro humo · plano .2,.5 x1.5 lento · oscuro]
- Jubei [entra der sombra]: …
- Ren [entra izq]: …
- Narración: Ninguno de los dos sabe qué decir. Jubei mira la manta. Después mira a Ren.
- Jubei: Tenés los ojos de tu madre.
- Ren: Y a mí me dijeron que tenía los de usted.
- Jubei [plano .7,.45 x1.45]: Natsu quería que te llamaras Ren. Hōshin te dejó ese nombre.
- Jubei: Es lo único que Hōshin no me quitó.
- Ren: Váyanse al Templo. Antes de que el Abad baje.
- Jubei: ¿Y vos?
- Ren: Yo subo. Alguien le tiene que pedir la mano al clan.
- Jubei: Yo ya le pedí la mano a Kage. Me encerró.
- Ren: A usted Kage le dijo que no. Pero el clan me debe una vida a mí.
- Explorador [entra centro sombra]: Por los tejados del valle llegamos en dos horas. Vamos, ronin. Mi hermana está allá.
- Jubei *(saliendo)*: Ren. No bajes solo. Prometémelo.

#### s23 · Las puertas de arriba
Rival: guardia de élite · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *La última escalera.* [lugar pagodaTop · oscuro · plano .12,.5 x1.6]
- [plano .12,.45 x1.9 lento · latido]
- Narración: Detrás de la puerta, una sola respiración. Lenta.
- Ren [entra izq] *(pensando)*: El Abad me mandó a vencer a Kage.
- Ren *(pensando)*: Tao, a preguntarle quién es Daishin. Mi padre, a no bajar solo.
- Ren *(pensando)*: Y mi madre no me pudo decir nada.
- Guardia [entra der sombra]: Nadie entra. Órdenes del Gran Shogun.
- Ren: El Gran Shogun me está esperando.
- Guardia [plano .7,.45 x1.4]: Por eso. Te quiere cansado.

**Después**
- [plano .12,.5 x1.6]
- Narración: La guardia de élite cae. La puerta se abre sola.
- Kage [off] *(desde adentro)*: Pasá, hijo de Natsu.
- Ren [entra izq] *(pensando)*: Hijo de Natsu.
- Ren *(pensando)*: Es la primera vez que alguien me llama así.

#### s24 · JEFE — Gran Shogun Kage
Rival: Kage · IA: maestro (jefe final) · Regla: normal
**Antes**
- *La cima de la pagoda.* [plano .85,.25 x1.4]
- [plano .5,.6 x1.1 lento]
- Narración: Viento. Ninguna luna: esta noche no sale. Y un hombre de armadura negra que no se da vuelta.
- Kage [entra der sombra]: Hōshin te mandó a vencerme.
- Ren [entra izq]: Sí.
- Kage: ¿Y vos a qué viniste?
- Ren: A preguntarle quién es Daishin.
- Narración: Por primera vez, Kage se da vuelta.
- Kage [plano .65,.45 x1.45]: Ese borracho de Tao. Nunca supo callarse a tiempo.
- Ren: Y a pedirle la mano del clan.
- Kage: Tu madre me la pidió en esta sala. Le dije que no.
- Kage: ¿Sabés por qué el clan no le da la mano a nadie, chico?
- Ren: …
- Kage: Porque la última vez que la dio, la perdió. Rodeame y te cuento el resto.

**Después**
- Kage [entra der]: …Ganaste. Como ganaba ella.
- Ren [entra izq]: Daishin.
- [plano .5,.75 x1.3 lento · oscuro]
- Kage: Daishin era un monje. Kagerō, una ninja. Rodearon al Oni juntos, cada uno con una mano.
- Kage: Eso lo cuentan los dos bandos, a medias. Lo que no cuenta nadie es lo que vino después.
- Kage [plano .65,.45 x1.5]: Se casaron. Tuvieron dos hijos.
- Kage: El mayor fundó el Templo. El menor, el clan.
- Ren: …Hermanos.
- Kage: Se pelearon por el Pergamino el día que murió su madre. Cada uno se quedó con media verdad y borró la otra.
- Kage: Trescientos años después, el Templo y el clan son una familia que no se acuerda.
- [plano .3,.45 x1.6 lento]
- Kage: Natsu lo sabía. Y vos sos el primero en trescientos años que nace de los dos lados.
- Ren *(pensando)*: Por eso el Oni llama a Daishin en sueños.
- Narración: Kage se mira la mano. Después se la tiende a Ren.
- Kage: El clan te debe una vida. Y yo le debo una a tu madre.
- [plano .9,.4 x1.5 lento · latido]
- Narración: A lo lejos, sobre el Templo, sube una columna de ceniza.
- Kage: Llegamos tarde.
- Ren: Todavía no.
- **→ Fin de la campaña Shaolin**
- *Tarjeta:* Hay otra mitad de esta historia. Terminá **Sombras sobre el Templo** para descubrir el verdadero final.

---

## 5. Campaña Ninja — «Sombras sobre el Templo» (Aya)

### Acto I · Sobre el muro *(gratis)*

#### n1 · Sobre el muro
Rival: guardia del muro · IA: novato · Regla: normal
**Antes**
- *La pagoda del clan. Noche.* [plano .82,.3 x1.4]
- [plano .6,.5 x1.1 lento]
- Narración: En lo alto de la montaña, las linternas rojas del clan no se apagan nunca.
- Narración: Esta noche, una chica de quince años espera de rodillas frente al Shogun. Es su primera misión.
- Kage [entra der sombra]: El Pergamino de Jade nos pertenece.
- Kage: Los monjes lo robaron hace siglos.
- Aya [entra izq]: ¿Qué dice el Pergamino, mi señor?
- Kage: …
- Kage: Eso no importa. Importa que vuelva a casa.
- Aya *(pensando)*: Siempre la misma respuesta.
- Kage: Esta noche subís al muro por primera vez. Kuro te guía. Tu hermano va con ustedes.
- Kage: No es para robar. Todavía no. Quiero saber cuántos guardias tienen y dónde.
- Kage: Una cosa más.
- Kage: Si ves a un discípulo joven, de pelo corto, que juega al tablero solo… no le hagas daño.
- Aya: ¿Por qué, mi señor?
- Kage: Porque lo digo yo.
- Aya: ¿Quién es?
- Kage: Una deuda vieja. Del clan, no mía.
- [sale Kage sombra · plano .3,.5 x1.2 lento]
- Narración: Aya creció en la pagoda. Su abuela Kiku le enseñó el tablero antes que a caminar.
- Narración: Kiku murió el invierno pasado. Lo último que dijo fue una frase que nadie entendió.
- Aya *(pensando)*: «Cuando la piedra lata, volvé a rodear.»
- Aya *(pensando)*: ¿Qué piedra, abuela?
- *Más tarde. El muro del Templo.* [lugar wall · plano .5,.5 x1.3]
- Explorador [entra centro sombra]: ¿Nerviosa, hermanita?
- Aya [entra izq]: Callate, Sora.
- Explorador: Te tiemblan las rodillas. A mí también me temblaban.
- Aya: A vos todavía te tiemblan.
- Kuro [entra der sombra]: Los dos. Silencio. El guardia del muro.
- [plano .14,.45 x1.6]
- Kuro: Pasalo sin hacer ruido. Si grita, se terminó la misión.
- Aya: Como una sombra.

**Después**
- [plano .75,.5 x1.25 lento]
- Narración: El guardia duerme contra el muro. Ni se enteró de que perdió.
- Aya [entra izq corre]: Adentro.
- Kuro [entra der sombra]: Bien. Primera prueba, pasada.
- Explorador [entra centro sombra]: Yo voy por el ala norte. Tengo algo que hacer.
- Aya: ¿Qué cosa? Kuro no dijo nada de…
- Kuro: Sora.
- Explorador: Cosas de hermano mayor. Vuelvo antes de que canten los gallos.
- [sale Explorador corre]
- Aya: ¿No lo vas a frenar?
- Kuro: Hace tres lunas que tu hermano sale de noche sin permiso. Si lo freno, nunca voy a saber adónde va.
- Kuro: Si lo dejo, algún día me lo va a contar.
- [plano .4,.5 x1.3 lento]
- Aya *(pensando)*: Cada vez que dice «cosas de hermano mayor», miente.
- Aya *(pensando)*: Y lleva carbón en el bolsillo. ¿Para qué quiere carbón un explorador?

#### n2 · Los novicios
Rival: novicios · IA: fácil · Regla: el rival no usa habilidad
**Antes**
- *El patio de novicios.* [plano .2,.5 x1.35]
- [plano .75,.5 x1.2 lento]
- Narración: Un pabellón bajo, lleno de esteras chicas. Alguien dejó una linterna prendida.
- Novicio [entra der corre]: ¡Una sombra! ¡Alarma!
- Aya [entra izq]: Son chicos.
- Aya *(pensando)*: Tienen la edad que yo tenía cuando me pusieron un tantō en la mano.
- Kuro [entra centro sombra]: Que no griten más fuerte. Sin lastimar a nadie.
- Aya *(pensando)*: Kuro dijo eso muy rápido. Como si le importaran los chicos.
- Novicio: ¡Todavía no sabemos la Meditación de Jade, pero no les tenemos miedo!
- Aya: Entonces jugamos sin trucos. Si gano, se vuelven a dormir.
- Novicio: ¿Y si ganamos nosotros?
- Aya: Grito yo la alarma. Por ustedes.

**Después**
- Narración: Los novicios vuelven a las esteras. Uno se duerme abrazado a una ficha de madera.
- Aya [entra izq]: Kuro… ¿por qué rodeamos?
- Aya: Ellos también rodean. Los monjes, los chicos, nosotros. Todos igual.
- Kuro [entra der]: Porque así se gana.
- Aya: Pero ¿por qué **así**? Hay mil maneras de ganar una pelea.
- [plano .7,.45 x1.45 lento]
- Kuro: …
- Kuro: La vez que le pregunté eso a mi maestro, me pegó con una vara.
- Aya: ¿Y vos me vas a pegar?
- Kuro: No. Pero tampoco te voy a contestar.
- Kuro: Preguntás demasiado, Aya. Igual que tu abuela.
- Aya: ¿Conociste a Kiku de joven?
- Kuro: Ella me enseñó a rodear. Y una vez, en medio de una partida, se puso a llorar.
- Aya: ¿Por qué?
- Kuro: Dijo que el tablero estaba incompleto. Que le faltaba una mano.
- Aya *(pensando)*: ¿Una mano?

#### n3 · Golpe por sorpresa
Rival: maestro de guardia · IA: fácil · Regla: el Monje rival empieza con 3 de tus fichas al lado
**Antes**
- *El patio interior.* [plano .45,.6 x1.4]
- [plano .25,.5 x1.2 lento]
- Narración: Un maestro hace la ronda junto al incensario. Tose. No mira hacia arriba.
- [plano .7,.25 x1.45]
- Aya [entra izq] *(pensando)*: Nunca miran hacia arriba.
- Kuro [entra der sombra]: Ese no es un guardia cualquiera. Es un maestro del Templo.
- Kuro: En la próxima vuelta nos ve. Hay que caerle encima, ahora.
- Aya: ¿Y Sora? Ya debería haber vuelto.
- Kuro: Tu hermano sabe cuidarse. Vos ocupate de no caerte del tejado.
- [temblor · destello]
- Narración: Aya cae sobre el maestro de guardia antes de que reaccione. Tres sombras lo rodean.

**Después**
- [arte art_stairs · plano .2,.4 x1.3]
- Narración [plano .55,.6 x1.15 lento]: Desde el tejado, Aya ve algo raro: nadie custodia la biblioteca.
- Narración: Todas las antorchas rodean una **escalera** que baja bajo el Templo. Y la cuida un solo guardia, con un bastón.
- Aya *(pensando)*: El Shogun dijo que el Pergamino está en la biblioteca.
- Aya *(pensando)*: Entonces… ¿qué cuidan ahí abajo, con tanto miedo?
- [lugar courtyard · entra Aya izq ya · entra Kuro der sombra · plano .5,.5 x1.25]
- Kuro: No. Ni lo pienses. La misión es contar guardias, no bajar escaleras.
- Aya: Vos también lo viste. Ponen más guardias en un agujero que en el Pergamino.
- Kuro: …
- Kuro: Diez minutos. Yo cuento los guardias del ala oeste. Si no volvés, te voy a buscar.
- Aya *(pensando)*: Kuro no me dijo que no.

#### n4 · La escalera
Rival: Gon · IA: fácil · Regla: normal
**Antes**
- *La entrada de la cripta.* [plano .5,.65 x1.5]
- [plano .5,.5 x1.1 lento]
- Narración: Una boca de piedra en el suelo. Abajo, las antorchas arden sin temblar. Sube un calor de verano.
- Gon [entra der corre]: ¡Alto! Nadie baja.
- Aya [entra izq]: ¿Qué hay abajo?
- Gon: No lo sé.
- Gon: El Abad me despertó a mí solo y me dijo que nadie baja. Con eso me alcanza.
- Aya: ¿Defendés algo que ni sabés qué es?
- Gon: ¿Y vos? ¿Sabés qué venís a robar?
- Aya: …
- Gon: Ya me parecía.
- Gon: Mi hermana duerme en el pueblo de abajo. Tiene ocho años. Si ustedes pasan, pasan por ella.
- Aya: No vinimos por ningún pueblo.
- Gon: Eso dicen todos los que vienen de noche.
- Aya *(pensando)*: Este monje tiene miedo. No de mí: de lo que hay al fondo de la escalera, a su espalda.
- Aya: Yo también tengo a alguien que cuidar: mi hermano Sora. Y no pienso volver sin saber qué hay abajo.

**Después**
- [plano .5,.65 x1.45 lento]
- Narración: Gon cae sentado en los escalones. No está herido. Está furioso.
- Aya [entra izq]: Perdón.
- Gon [entra der]: ¿Perdón? ¿Me ganás y me pedís perdón?
- Aya: Te torcí el brazo. No quería.
- [vacía · plano .5,.6 x1.3 lento]
- Narración: Aya baja hasta el fondo de la escalera. Hay una puerta de piedra, cerrada con seis cerrojos.
- [plano .5,.72 x1.7 lento · latido]
- Narración: La piedra está **tibia**. Y late, despacio.
- Aya [entra izq]: …Como un corazón.
- Aya *(pensando)*: «Cuando la piedra lata, volvé a rodear.»
- Aya *(pensando)*: Abuela… ¿a esto le rezábamos?
- [onom campana · temblor]
- Narración: Arriba empiezan a sonar las campanas.

#### n5 · Alarma
Rival: monjes de guardia · IA: fácil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Campanas. Todo el Templo despierta.* [plano .82,.55 x1.6]
- [onom campana · temblor]
- Kuro [entra der corre]: ¡Nos vieron! Nos vamos.
- Aya [entra izq corre]: Kuro, abajo hay una puerta de piedra. Está caliente. ¡Late!
- Kuro: Después.
- Aya: ¡Late, Kuro! Como algo vivo.
- Narración: Por un instante, el jonin del humo parece asustado.
- Kuro: Dije después. ¿Dónde está tu hermano?
- Aya: No volvió. ¡No podemos irnos sin Sora!
- Kuro: Sora conoce el camino. Nosotros tenemos que llegar al muro norte antes que los monjes.
- Kuro: ¡Ahora, Aya! Son muchos y nos van a perseguir hasta el alba.

**Después**
- *El bosque, al alba.* [lugar forest · plano .7,.4 x1.3]
- Narración: Escaparon. Esperan entre los bambúes hasta que sale el sol. Sora no aparece.
- Aya [entra izq]: Algo le pasó.
- Kuro [entra der]: …
- Kunoichi [entra centro sombra]: Kuro. Atraparon a Sora. Un monje grandote, con un brazo vendado.
- Aya *(pensando)*: El de la escalera. El que yo dejé así.
- Kunoichi: Sora volvía del ala norte. Tenía las manos negras de carbón.
- Aya: Vamos a volver por él.
- Kuro: …
- Kuro: El Shogun va a decir que no. Un explorador no vale una misión.
- Aya: No es un explorador. Es mi hermano.
- Kuro: Ya sé.
- Kuro: Por eso te lo digo a vos y no al Shogun: el techo de las celdas está flojo.
- Kunoichi: Algunos de los nuestros piensan otra cosa. Un cambio.
- Kuro: ¿Qué cambio?
- Kunoichi: El discípulo del Abad baja solo al pueblo todas las tardes.
- Kuro: **No.** El Shogun fue claro.
- Aya *(pensando)*: El discípulo al que no hay que lastimar…
- Aya *(pensando)*: ¿Quién es ese chico, que hasta el Shogun lo cuida?

#### n6 · JEFE — Maestra Mei
Rival: Mei · IA: fácil (jefe) · Regla: Mei tiene un Tigre de más
**Antes**
- *Noche siguiente. Las celdas.* [plano .2,.5 x1.4]
- [plano .55,.5 x1.2 lento]
- Narración: Dos de los suyos golpean el techo del ala vieja para distraer a los monjes. Aya entra sola, por otro lado.
- Aya [entra izq] *(pensando)*: Mientras pelean arriba, yo bajo. Aguantá, Sora.
- [entra Mei der sombra]
- Narración: En el pasillo de las celdas, alguien la espera sentada en el suelo, con los ojos cerrados.
- Mei: Volviste por tu hermano. Eso dice algo bueno de vos.
- Aya: ¿Cómo sabe que es mi hermano?
- Mei: Habla de vos todo el tiempo. De la hermana que pregunta y pregunta.
- Mei: También habla dormido. Dice «abuela» y dice «piedra».
- Aya: …
- Mei: Anoche bajaste, ¿verdad? Hasta la puerta.
- Aya: ¿Usted sabe qué hay ahí?
- Mei: Sé que no debería saberlo. Y que el único que lo sabe todo, el Abad, no quiere compartirlo.
- Aya: No necesito su permiso. Necesito a mi hermano.
- Mei: No. Necesitás pasar por mí.

**Después**
- Mei [entra der]: …Basta.
- Aya [entra izq]: ¿Se rinde?
- Mei: Me canso. No es lo mismo.
- Mei: Andate. Y llevate a tu hermano, si lo encontrás.
- Aya: ¿Por qué me deja ir?
- Mei: Porque viene algo más grande que esta guerra. Y cuanta menos sangre haya entre nosotros, mejor.
- Mei: Decile a tu Shogun que en el Templo no todos estamos ciegos.
- [sale Mei]
- *La celda.* [lugar cells · plano .6,.5 x1.3]
- Narración: La celda de Sora está cerrada con llave. Y vacía.
- Aya [entra izq]: ¿Sora…?
- Narración: En la paja quedó un plato de arroz a medio comer. Con tierra.
- Aya *(pensando)*: Alguien le trajo de comer. Un monje.
- *La escalera de la cripta.* [lugar cryptStairs · oscuro · niebla · plano .5,.55 x1.3]
- Explorador [entra der sombra]: Aya. Por acá.
- Aya [entra izq]: ¡Sora! ¿Cómo saliste?
- Explorador: No salí. Me sacaron.
- [plano .5,.6 x1.55 lento]
- Zorra Blanca [entra centro humo]: Lo que viniste a buscar no es lo que pensás, nieta de Kiku.
- Aya: ¿Conocías a mi abuela?
- Zorra Blanca: Le llevé mensajes durante cuarenta años. Ahora se los llevo a tu hermano.
- Aya: ¿Sora…?
- Explorador: Te lo iba a contar. La marca en el muro, las salidas de noche… Es la zorra. Ella me pide que avise al Templo.
- Aya: ¿Que avises qué?
- Zorra Blanca: Que la piedra late. Y que nadie quiere escucharla.
- [sale Zorra Blanca humo]
- [latido · temblor]
- Narración: Bajo los pies de Aya, la piedra **late** una vez más. Más fuerte. Del techo cae un polvo gris.
- Aya *(pensando)*: Gris. Como la tos de la abuela.
- **→ Fin del Acto I · desbloqueo**

### Acto II · El jardín de piedra

#### n7 · El informe
Rival: Kuro (entrenamiento) · IA: fácil · Regla: normal
**Antes**
- *La pagoda. Ese mismo día.* [plano .82,.35 x1.4]
- [plano .6,.55 x1.15 lento]
- Narración: En la sala del Shogun, tres ninjas esperan de rodillas desde el alba. Son los que emboscaron al discípulo del Abad sin permiso.
- Kage [entra der sombra]: Desobedecieron. Pusieron en peligro al chico que les ordené no tocar.
- Kunoichi [entra centro sombra]: Mi señor, solo queríamos traer a Sora de vuelta…
- Kage: Sora volvió solo. Ustedes volvieron sin honor.
- Kage: Un mes en el puente del río. Comiendo lo que pesquen.
- [sale Kunoichi]
- Aya [entra izq]: Mi señor. La puerta de la cripta late.
- Aya: Bajé hasta el fondo de la escalera. La piedra está tibia. Late como un corazón.
- Kage: Supersticiones de monjes.
- Aya: La toqué yo. Con esta mano.
- Kage: …
- Narración: Por un instante, el Gran Shogun se mira la propia mano. Como si recordara algo.
- Kage: ¿Y tu hermano? ¿Qué hacía en el ala norte con las manos negras de carbón?
- Aya: …
- Kage: No lo protejas. Ya me lo contó. Mensajes de una zorra. Marcas en los muros del enemigo.
- Kage: Sora se queda encerrado en la torre hasta que yo diga.
- Aya: ¡Él solo quería advertirles!
- Kage: ¿Advertirles qué? ¿Que los espíritus hablan? Las leyendas no se discuten, Aya. Se obedecen.
- Kage: Y la leyenda dice: cuando caiga ceniza, el Pergamino vuelve a casa antes de la luna nueva.
- Kage: Hoy cayó ceniza sobre el Templo.
- Aya *(pensando)*: ¿Cómo sabe eso?
- Kage: Kuro. Entrenala. Está distraída.
- Kuro [entra centro sombra]: Sí, mi señor.
- Narración: Kuro tiene un golpe nuevo en la mejilla. Kuro no pierde nunca.

**Después**
- Kuro [entra der]: Peleás con rabia.
- Aya [entra izq]: Peleo con preguntas.
- Aya: ¿Quién te hizo ese golpe, Kuro?
- Kuro: Un novicio. En el portón del Templo, al alba. Cubrí la huida de ustedes.
- Aya: ¿Un novicio te ganó a vos?
- Kuro: El chico de la manta.
- Aya: El que el Shogun cuida. ¿Quién es, Kuro? ¿Por qué el clan le debe algo?
- [plano .7,.45 x1.45 lento]
- Kuro: …
- Kuro: Tu abuela tenía dos hijas.
- Aya: Una era mi madre. La otra se murió antes de que yo naciera. La tía Natsu.
- Kuro: Eso dice la tumba.
- Aya: ¿Qué querés decir?
- Kuro: Que hace dieciséis años juré no contar lo que vi una noche de lluvia gris. Y ya te dije demasiado.
- Kuro: Las preguntas no ganan batallas, Aya.
- Aya: Todavía.
- [sale Kuro humo]
- Aya *(pensando)*: La tumba de la tía Natsu. Siempre me pareció chica.
- Aya *(pensando)*: Demasiado chica para un cuerpo.

#### n8 · El jardín de piedra
Rival: jardineros del Templo · IA: normal · Regla: el Asedio empieza en la ronda 15
**Antes**
- *La noche siguiente. La torre de la pagoda.* [lugar pagoda · plano .8,.3 x1.4]
- Narración: Sora está encerrado arriba. Aya trepa por afuera, como cuando eran chicos.
- Explorador [entra der sombra]: Si te ve el Shogun, nos encierra a los dos.
- Aya [entra izq]: Entonces hablá rápido. La zorra. ¿Qué te dijo?
- Explorador: Que mires las piedras del jardín. El de abajo del Templo, fuera de los muros.
- Explorador: Dijo que ahí está escrito lo que la abuela no se animó a contarnos.
- Aya: ¿La abuela sabía algo?
- Explorador: Hermanita, la abuela sabía todo. Lo que no sabía era cómo decirlo.
- Explorador: Una vez la vi llorar sobre una tumba vacía. La de la tía Natsu.
- Aya: …¿Vacía?
- Explorador: Yo tenía siete años. Pensé que lo había soñado.
- *El jardín zen, al pie del Templo.* [lugar garden · plano .15,.4 x1.4]
- [plano .55,.6 x1.1 lento]
- Narración: Arena rastrillada en círculos perfectos. Nadie la pisa nunca.
- Aya [entra izq]: Hasta hoy.
- [onom campana]
- Narración: Los monjes jardineros la vieron. Cierran el jardín con rastrillos y bastones.

**Después**
- [plano .5,.6 x1.5 lento]
- Narración: En el centro del jardín, seis piedras forman un hexágono alrededor de una séptima, más chica.
- [plano .52,.65 x1.8 · latido]
- Narración: Una de las seis tiene una grieta. Fresca, del mismo día en que cayó ceniza.
- Aya [entra izq] *(pensando)*: Seis piedras alrededor de una. Como la marca de Sora.
- Aya *(pensando)*: Como el bordado de la abuela.
- [plano .5,.72 x1.9 lento]
- Narración: En la base de la piedra del centro hay dos nombres tallados, muy chiquitos. Uno con letra de monje, otro con letra del clan.
- Aya *(leyendo)*: «Natsu.»
- Aya *(leyendo)*: «Jubei.»
- Aya *(pensando)*: ¿Quién es Jubei?
- Aya *(pensando)*: ¿Y qué hacía el nombre de mi tía en un jardín de monjes?

#### n9 · Los guardianes
Rival: Tigres de mármol · IA: normal · Regla: el rival tiene 3 Tigres
**Antes**
- *El paso del jardín.* [lugar garden · plano .85,.55 x1.4]
- Narración: Por el único paso de salida bajan los Tigres de Mármol, los guardianes del Templo. Empujan todo lo que encuentran.
- [temblor · onom golpe]
- Aya [entra izq]: Grandes, lentos y tercos.
- Aya: Como los monjes.
- Aya *(pensando)*: Si me atrapan acá, nadie en el clan va a saber lo de las piedras. Ni lo de los nombres.

**Después**
- [niebla · plano .5,.6 x1.2 lento]
- Narración: Aya escapa entre los Tigres. Afuera del jardín la espera la niebla. Y en la niebla, algo blanco.
- Zorra Blanca [entra der humo]: Seis piedras, dos manos.
- Zorra Blanca: ¿Recordás la canción, nieta de Kiku?
- Aya [entra izq]: ¿Qué canción?
- Zorra Blanca: La que tu abuela tarareaba mientras rodeaba.
- Aya: …No tenía letra. Era solo una melodía.
- Zorra Blanca: Tenía letra. Tu clan la dejó de cantar el día que dejó de preguntar.
- Zorra Blanca *(cantando)*: «Una mano del monte, una mano de la sombra. Seis piedras alrededor, y el fuego se duerme.»
- Aya: «Y el fuego se duerme…»
- Aya: ¿Natsu la sabía?
- Zorra Blanca: Natsu la cantó entera. Una sola vez. Con la voz equivocada a su lado.
- Aya: ¿Qué voz? ¿La de Jubei?
- Zorra Blanca: Preguntale a él. Mañana baja por el camino de la montaña.
- [sale Zorra Blanca humo]

#### n10 · La leyenda
Rival: Jubei, el ronin · IA: normal · Regla: normal
**Antes**
- *A la mañana. Un camino de montaña.* [plano .85,.4 x1.4]
- [plano .55,.6 x1.15 lento]
- Narración: Un ronin baja por el camino con un cuenco atado al cinto. Tiene una cicatriz en la ceja.
- Jubei [entra der]: Una ninja sentada en mi camino. Mala señal.
- Aya [entra izq]: ¿Cómo te llamás?
- Jubei: Los ronin no tenemos nombre. Por eso somos ronin.
- Aya: ¿Jubei?
- Narración: El ronin se queda quieto. La mano va sola a la empuñadura.
- Jubei: ¿Quién te dijo ese nombre?
- Aya: Una piedra. En el jardín del Templo. Al lado del nombre de mi tía. Natsu.
- Jubei: …
- Jubei: Tenés los ojos de Natsu. Los vi apenas te vi, y no quise creerlo.
- Aya: ¿La conociste?
- Jubei: Fui monje del Templo. Ella era del clan. Eso tendría que alcanzar como respuesta.
- Aya: No alcanza.
- Jubei: No. Nunca alcanzó.
- Jubei: Ganame. Y te cuento lo que el Templo calla y lo que el clan olvidó.

**Después**
- Jubei [entra der]: Rodeás como Natsu. Primero esperás. Después cerrás sin piedad.
- Jubei: Tu clan dice que el Pergamino es suyo. No miente.
- Jubei: El Pergamino es un pacto. Lo firmaron un monje y una ninja hace trescientos años. Daishin y Kagerō.
- Aya [entra izq]: ¿Un pacto para qué?
- Jubei: Eso solo lo sabe quien lo leyó. Y en el Templo, solo lo lee el Abad.
- Jubei: Natsu quería lo mismo que vos: saber. Lo supo. Y le costó todo.
- Aya: ¿Está viva?
- Jubei: Hace dieciséis años que me hago esa pregunta.
- Jubei: El Abad me dijo que había muerto esa noche. Ella y…
- Aya: ¿Y quién?
- Jubei: Nadie. Un error.
- [plano .5,.4 x1.1 lento]
- Narración: Jubei sigue camino hacia el este, hacia el santuario viejo. No se da vuelta.
- Aya *(pensando)*: «Ella y…» ¿Y quién?
- Aya *(pensando)*: Una tumba vacía. Demasiado chica para un cuerpo.

#### n11 · Humo y espejos
Rival: patrulla del Templo · IA: normal · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *Al día siguiente, de noche. El bosque.* [lugar forest · plano .3,.5 x1.4 · niebla]
- Narración: Aya sigue el rastro de Jubei hacia el este. Pero el bosque está lleno de monjes con antorchas.
- Gon [entra der corre]: ¡Abran bien los ojos! ¡Tiene que estar cerca!
- Aya [entra izq] *(pensando)*: El de la escalera. El del brazo vendado. Ya se le está curando.
- Gon: El Abad fue claro: traerlo de vuelta antes de que hable con el ronin.
- Aya *(pensando)*: ¿Traer a quién?
- Gon: Y si encuentran al ronin… no lo dejen acercarse a Ren.
- Aya *(pensando)*: Ren. El chico de la manta se llama Ren.
- Aya *(pensando)*: Y el Abad le tiene más miedo a Jubei que a nosotros.
- [plano .7,.3 x1.5]
- Gon: ¡Ahí! ¡Una sombra!
- [humo · destello]
- Aya [entra izq corre]: Humo y espejos. Que ningún monje sepa dónde estoy.

**Después**
- [entra Aya izq · niebla]
- Narración: Los monjes se pierden en el humo. Gon grita órdenes a nadie.
- [plano .7,.3 x1.5 · latido]
- Zorra Blanca [entra der humo]: Mañana, en el santuario, vas a conocer a alguien que hace tus mismas preguntas.
- Aya: El chico de la manta. Ren.
- Zorra Blanca: Aprendés rápido.
- Aya: ¿Jubei va a estar?
- Zorra Blanca: Jubei fue a buscar a un viejo amigo del Templo. Hace dieciséis años que no se miran a la cara.
- Zorra Blanca: No lastimes al chico. Es el único que puede contestarte.
- Aya: ¿Y si me lastima él?
- Zorra Blanca: Entonces van a aprender rápido. Los dos.
- Aya: Zorra… ¿quién sos?
- [plano .7,.45 x1.45 lento]
- Zorra Blanca: La que recuerda lo que ustedes olvidaron.
- [sale Zorra Blanca humo]
- Aya *(pensando)*: El Shogun lo cuida. El Abad lo esconde. Jubei llora por él sin conocerlo.
- Aya *(pensando)*: ¿Quién sos, Ren?

#### n12 · JEFE — Ren *(duelo cruzado)*
Rival: Ren · IA: normal (jefe) · Regla: normal
**Antes**
- *El santuario, al amanecer.* [plano .2,.45 x1.4]
- [arte art_duel_shrine · plano .5,.45 x1.6]
- Narración [plano .5,.5 ancho .8 lento]: Dos sombras en el mismo claro. Ninguna se mueve primero.
- Aya [lugar shrine · entra izq · plano .35,.5 x1.25]: Un monje. Solo. En mi bosque.
- Ren [entra der]: No es tu bosque. Y no vine solo: me mandó una zorra.
- Aya: …A mí también.
- Ren: Sos la del abanico. La que le ganó a Gon en la escalera y le pidió perdón.
- Aya: Y vos sos el que le llevó arroz a mi hermano.
- Ren: ¿Sora es tu hermano? Me dijo que tenía una hermana que preguntaba demasiado.
- Aya: Y él dijo que el arroz tenía tierra. Y que fue lo más rico que comió en una semana.
- Ren: Busco a un ronin. Jubei. Me citó acá.
- Aya: Yo también lo busco. A mí me citó la zorra.
- Ren: No vino.
- Aya: No.
- Aya: En el clan te dicen el chico de la manta. El Shogun te cuida como a un tesoro y no dice por qué.
- Aya: Mostrame esa manta.
- Ren: Todos quieren algo de mí y nadie me da nada. Primero ganame.
- Aya: Igual te iba a ganar.

**Después**
- Ren [entra der]: Ganaste. Esta vez.
- Aya [entra izq]: La manta. Prometiste.
- Narración: Ren abre la manta sobre la piedra del santuario.
- [plano .5,.6 x1.6 lento]
- Narración: Seis puntos alrededor de uno, en hilo gris.
- Aya: …
- Aya: Ese bordado lo conozco. Puntada por puntada.
- Ren: ¿De dónde?
- Aya: Mi abuela Kiku lo bordaba. En el paño de su tablero. En la capa de mi primera misión.
- Aya: Y solo bordaba para la familia.
- Ren: …
- Aya: Esa puntada torcida en la esquina… Esa no es de ella. Es de alguien que estaba aprendiendo.
- Ren: Una zorra me dijo que la empezó una mano vieja y la terminó una mano joven.
- Ren: ¿Quién es Natsu?
- Narración: Aya da un paso atrás, como si le hubieran pegado.
- Aya: ¿Dónde oíste ese nombre?
- [onom campana · plano .85,.4 x1.4]
- Narración: Entre los árboles suenan cascabeles. Una patrulla del Templo sube por el sendero.
- Aya: Monjes. Tuyos. Vienen a buscarte.
- Ren: ¡Esperá! ¡Contestame!
- Aya: Natsu era la hermana de mi madre. La hija menor de mi abuela Kiku.
- Aya: Murió hace dieciséis años. Eso dice su tumba.
- [sale Aya humo · humo · destello]
- *El bosque, lejos del santuario.* [lugar forest · plano .3,.5 x1.3]
- Aya [entra izq] *(pensando)*: Una tumba vacía. Una manta bordada por la abuela. Un chico que el clan no puede tocar.
- Aya *(pensando)*: Ren tiene dieciséis años.
- Aya *(pensando)*: …Tía Natsu. ¿Qué hiciste?
- *(Las dos versiones del duelo son la misma charla; en el final se revela que ninguno ganó: la Zorra los separó.)*
- **→ Fin del Acto II**

### Acto III · La escalera

#### n13 · Descenso
Rival: guardias de la cripta · IA: normal · Regla: normal
**Antes**
- *La torre de la pagoda. Un día después del duelo.* [lugar pagoda · plano .8,.3 x1.4]
- Narración: Aya trepa otra vez hasta la ventana de Sora. Esta vez no viene a escuchar. Viene a preguntar.
- Aya [entra izq]: La tía Natsu. ¿Dónde murió?
- Explorador [entra der sombra]: Nadie lo dice. Ni el Shogun, ni Kuro. Ni la abuela, en vida.
- Aya: La abuela algo habrá dicho. Siempre decía algo.
- Explorador: Una noche, ya enferma, tosiendo gris… dijo: «Natsu bajó por la escalera de ellos. Y no subió.»
- Aya: La escalera de ellos.
- Explorador: Pensé que deliraba.
- Aya: Yo bajé esa escalera, Sora. La noche que le gané a Gon. La piedra del fondo late.
- Explorador: Aya… no vayas sola.
- Aya: Vos estás encerrado y Kuro le obedece al Shogun. ¿Con quién querés que vaya?
- *Esa noche. El Templo, por dentro.* [lugar courtyard · plano .82,.3 x1.4 · oscuro]
- [plano .4,.55 x1.15 lento]
- Narración: Aya se cuela otra vez. Esta vez no busca la biblioteca. Busca la escalera.
- Aya [entra izq] *(pensando)*: Guardias nuevos. Muchos. Y un candado en la biblioteca.
- [onom golpe · plano .2,.4 x1.4]
- Narración: Del lado de la biblioteca llega un ruido seco. Una puerta forzada.
- Aya *(pensando)*: Alguien más está rompiendo reglas esta noche.
- Aya *(pensando)*: Mejor. Que los guardias miren para allá.

**Después**
- *La escalera de la cripta.* [lugar cryptStairs · oscuro · plano .5,.55 x1.3]
- [plano .5,.75 x1.7 lento]
- Narración: Escalones que bajan, y bajan. A cada paso, el aire se pone más caliente.
- Aya [entra izq]: …
- [plano .3,.6 x1.6 · latido]
- Narración: En la pared hay una mano marcada en la piedra, quemada en negro. Una mano chica, de mujer.
- Narración: Aya apoya la suya encima.
- Aya *(pensando)*: Mismo tamaño.
- Aya *(pensando)*: Alguien bajó por acá tocando la pared, como yo. Y apretó tan fuerte que la piedra se acuerda.

#### n14 · Las seis piedras
Rival: guardianes de la cripta · IA: normal · Regla: el rival no usa habilidad
**Antes**
- *La cripta.* [plano .5,.3 x1.4 · oscuro]
- [arte art_crypt · plano .15,.7 x1.6]
- Narración [plano .55,.55 x1.1 lento]: Una sala enorme. En el piso, seis piedras en hexágono alrededor de una grieta.
- [plano .5,.6 x1.45 · latido]
- Narración: Tres piedras tienen grietas. Por ellas sale ceniza.
- Aya [lugar crypt · entra izq]: Esto es un sello. Como el jardín. Como el bordado.
- Narración: Junto a la grieta del centro hay algo que no es piedra. Un abanico de kunoichi, quemado hasta las varillas.
- [plano .5,.7 x1.7 lento]
- Narración: En la tela que queda hay seis puntos alrededor de uno. Bordados en hilo gris.
- Aya: …La puntada de la abuela.
- Aya: Tía Natsu. No te caíste de ningún lado. No te enfermaste. Moriste acá.
- Narración: Las sombras de la cripta se despegan de las paredes. Guardianes de piedra, que no dejan tocar nada.

**Después**
- [lugar crypt · entra Aya izq ya · plano .5,.6 x1.3 · oscuro]
- [latido · temblor · plano .5,.65 x1.6]
- Narración: Desde la grieta sube una voz, como brasas.
- Oni [off]: …Kagerō…
- Aya: ¿Quién es Kagerō?
- Oni [off]: No. No sos ella. Sos de su sangre. Olés igual que la otra.
- Aya: ¿Qué otra?
- Oni [off]: La que se quedó. La que me tiene la mano hace dieciséis inviernos.
- [plano .5,.7 x1.8 lento · latido]
- Oni [off]: Se le está cansando, pequeña sombra. La siento temblar.
- Oni [off]: Cuando me suelte, subo. Y vos vas a ser la próxima en darme la mano.
- Aya *(pensando)*: Alguien le tiene la mano a esta cosa. Hace dieciséis años.
- Aya *(pensando)*: Tía Natsu… ¿todavía estás acá?

#### n15 · Ceniza
Rival: sombras de ceniza · IA: difícil · Regla: el rival tiene 4 Shinobi
**Antes**
- [plano .5,.6 x1.2 · humo · oscuro]
- Narración: La ceniza toma forma. Fichas grises, sin dueño, se mueven solas.
- [temblor · onom temblor]
- Aya [entra izq]: ¡¿Qué es esto?!
- Oni [off]: Mis dedos. Los que se escapan por las grietas.
- Oni [off]: Rodeame, si podés. Ya me rodearon antes. Nunca alcanza.

**Después**
- [plano .5,.6 x1.4 lento · humo · oscuro]
- Narración: Las fichas de ceniza se deshacen. Pero vuelven a juntarse, más despacio.
- Aya [entra izq] *(pensando)*: No se pueden vencer. Solo frenar.
- [plano .5,.7 x1.6 · latido]
- Narración: Una sola figura de ceniza no ataca. Se queda quieta, al lado del abanico quemado.
- Narración: Tiene forma de mujer. Levanta un dedo gris y dibuja en el polvo seis puntos alrededor de uno.
- Narración: Después señala la escalera. Arriba. Hacia el Templo.
- Aya: …¿Tía?
- [humo · plano .5,.6 x1.5 lento]
- Narración: La figura se deshace sin ruido.
- Aya *(pensando)*: Señaló arriba. ¿Quiere que me vaya?
- Aya *(pensando)*: ¿O me está diciendo dónde está la otra mano?

#### n16 · El monje borracho
Rival: Tao · IA: difícil · Regla: normal
**Antes**
- [plano .2,.5 x1.4 · oscuro]
- Tao [entra der]: Una ninja en mi cripta. *hip*
- Tao: Anoche, un ronin. Hoy, una kunoichi. Mi cripta se puso de moda.
- Aya [entra izq]: ¿Un ronin? ¿Jubei estuvo acá?
- Tao: ¿Lo conocés? Mirá vos. El mundo es chico y la montaña es hueca.
- Aya: ¿Vas a llamar a los guardias?
- Tao [plano .7,.45 x1.45]: No. Peleás con abanico, tirando a la izquierda. Como ella.
- Aya: ¿Como quién?
- Tao: Ganame y te cuento un cuento. Dos cuentos. Uno viejo y uno que me da vergüenza.

**Después**
- [arte art_drunken_tale · plano .3,.75 x1.4]
- Tao [plano .25,.3 x1.4 lento]: Había una vez un monje, Daishin…
- Tao [plano .75,.3 x1.4 lento]: …y una ninja, Kagerō.
- Tao [plano .5,.25 x1.3 lento]: Rodearon a un demonio con seis piedras. Juntos. Las dos manos.
- Aya [plano .65,.75 x1.4]: ¿Un monje y una ninja… juntos?
- Tao [plano .42,.55 ancho .8 lento]: Eso es lo que el Templo borró. Y lo que tu clan olvidó. *hip*
- *El cuento que le da vergüenza.* [lugar crypt · plano .5,.6 x1.3 · oscuro]
- [entra Aya izq · entra Tao der]
- Tao: Hace dieciséis años, una chica del clan y un monje joven quisieron hacer lo mismo. Eran dos manos. Alcanzaba.
- Tao: El Abad me dio una llave y yo encerré al monje. La chica bajó sola.
- Aya: Natsu. Y el monje…
- Aya: Jubei.
- Tao: Mirá qué rápido. La sangre de Kiku pregunta y contesta sola.
- Aya: Dejó un bebé. Envuelto en una manta que bordó mi abuela.
- Tao: Lo crió el Abad como si fuera suyo. Lo crió bien, eso hay que dárselo.
- Aya: Ren.
- [plano .7,.45 x1.5 lento · latido]
- Aya *(pensando)*: El chico de la manta es hijo de mi tía.
- Aya *(pensando)*: Ren es mi primo. Y le pegué con un abanico.

#### n17 · La huida
Rival: monjes de la cripta · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *La cripta, antes del alba.* [lugar crypt · oscuro · plano .3,.55 x1.3]
- [entra Tao der · entra Aya izq]
- Tao: Escondete. Atrás de la piedra rota. Y no respires.
- [onom campana]
- Narración: Pasos en la escalera. Lentos. Una sola persona.
- [plano .6,.5 x1.5 lento]
- Abad [entra der sombra]: …
- Narración: El Abad se arrodilla junto a la piedra más rajada. Apoya las dos manos encima.
- [latido · humo]
- Narración: Las manos le humean. No las saca.
- Abad: Una noche más. Aguantá una noche más, Natsu. Después bajo yo.
- Aya *(pensando)*: El Abad está haciendo lo mismo que hizo la tía Natsu. Solo. Quemándose de a poco.
- [temblor · onom temblor]
- Narración: La piedra cruje. El Abad se levanta de golpe y mira hacia donde está Aya.
- Abad: ¿Quién anda ahí? ¡Guardias!

**Después**
- *Afuera. La primera luz.* [lugar mountainPath · plano .85,.3 x1.3]
- Narración: Aya sale del Templo con la primera luz. Lleva el abanico quemado contra el pecho.
- Aya [entra izq]: …
- [plano .3,.6 x1.6 lento]
- Narración: Le tiemblan las manos. No sabe si de miedo o de calor.
- [plano .7,.3 x1.5]
- Narración: Sobre el muro del Templo bajan cuatro sombras del clan. Van hacia el patio, derecho a los dormitorios.
- Aya *(pensando)*: Son las kunoichi del puente. Las que el Shogun castigó.
- Aya *(pensando)*: Nadie del clan ataca de día sin orden. ¿Quién las mandó?
- Aya *(pensando)*: …Van a buscar a Ren.

#### n18 · JEFE — Kuro
Rival: Kuro · IA: difícil (jefe) · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *La pagoda.* [plano .82,.35 x1.4]
- Aya [entra izq corre]: Mi señor. El Pergamino no es un tesoro. Es un ritual. Un sello, y necesita al Templo y al clan.
- Aya: La tía Natsu no murió de fiebre. Murió en la cripta del Templo, sosteniendo ese sello sola.
- Kage [entra der sombra]: Lo sé.
- Aya: …¿Lo sabe?
- Kage: Hace dieciséis años, Natsu se arrodilló en esta misma sala. Me pidió una mano del clan para bajar con un monje.
- Kage: Le dije que el clan no le da la mano a ladrones.
- Narración: El Gran Shogun se mira la mano otra vez. Esta vez no la esconde.
- Kage: Natsu bajó igual. Y la lluvia gris me la devolvió en ceniza.
- Aya: Entonces ayúdelos ahora. Al Templo, al Abad, a Ren.
- Kage [plano .7,.45 x1.45]: No. Esta vez la mano del clan va a estar. La mía. Pero sin monjes que se equivoquen.
- Kage: Mañana es luna nueva. Kuro irá al Templo esta noche a tomar el Pergamino por la fuerza.
- Aya: ¡Con una sola mano no cierra! ¡Eso mató a mi tía!
- Kage: Y un ronin vino ayer a decirme lo mismo. Está en la torre, con tu hermano.
- Aya: …¿Jubei?
- Kuro [entra centro sombra]: Apartate, Aya. No me hagas pasar por encima tuyo.

**Después**
- Kuro [entra der]: …Me ganaste.
- Aya [entra izq]: Vos estabas esa noche. Lo dijiste.
- Kuro: Yo llevé a Natsu hasta el muro del Templo. Llovía. Ella tenía al bebé en brazos.
- Kuro: Me dijo: «Si no vuelvo, que el clan le deba una vida a este chico.» Y juré callar.
- Kuro: Dieciséis años callado. Ya está bien.
- Kuro: Andá vos al Templo, entonces. Pero no le traigas el Pergamino al Shogun.
- Aya: ¿Entonces a quién?
- Kuro: A quien tenga la otra mano.
- [sale Kuro humo · humo]
- [plano .85,.3 x1.5 lento · oscuro]
- Kage [off] *(desde las sombras)*: Traeme el Pergamino, Aya. O no vuelvas.
- Aya *(pensando)*: Jubei en la torre. Ren en el Templo. El Abad quemándose las manos.
- Aya *(pensando)*: Y mañana, luna nueva.
- **→ Fin del Acto III**

### Acto IV · La biblioteca

#### n19 · Los tejados
Rival: vigías del Templo · IA: difícil · Regla: normal
**Antes**
- *El Templo. La tarde de la luna nueva.* [plano .82,.3 x1.4]
- [plano .4,.55 x1.15 lento]
- Narración: Aya pasó el día entero entre las tejas, sin moverse. Ahora el sol se esconde, y esta noche no sale la luna.
- Aya [entra izq] *(pensando)*: Dicen que el discípulo del Abad se fue anoche. A la pagoda.
- Aya *(pensando)*: Ren y yo. Cada uno en la casa del otro.
- Narración: En el patio, los monjes llevan baldes de agua hacia la escalera de la cripta. Para enfriar algo que quema.
- Aya *(pensando)*: Kuro dijo: a quien tenga la otra mano.
- Aya *(pensando)*: Ren es esa mano, y no está. Entonces el Pergamino lo llevo yo.
- Guardia [entra der]: ¡Ahí arriba! ¡En el tejado!

**Después**
- [plano .2,.4 x1.4 lento]
- Aya [entra izq] *(pensando)*: Los vigías ya no gritan.
- *Las celdas.* [lugar cells · oscuro · plano .5,.55 x1.3]
- Narración: Bajando por el alero, Aya pasa junto a una ventana con rejas. Adentro, tres kunoichi atadas.
- Kunoichi [entra der sombra]: ¿Aya? ¿Te mandó el Shogun?
- Aya [entra izq]: Nadie me mandó. Como a ustedes.
- Kunoichi: Vinimos a sacar al chico de Natsu. Llegamos tarde: ya se había ido.
- Kunoichi: Aya… el Abad baja a la cripta esta noche. Lo oímos decirlo. «Antes de la medianoche.»
- Aya: Entonces tengo hasta la medianoche.

#### n20 · Los Tigres de mármol
Rival: guardianes de la biblioteca · IA: difícil · Regla: el rival tiene 3 Tigres
**Antes**
- *Las puertas de la biblioteca.* [lugar library · plano .5,.6 x1.4 · oscuro]
- Narración: El candado está roto. Alguien forzó la puerta hace dos noches y nadie la volvió a cerrar. Ahora la custodian los Tigres de Mármol.
- [temblor · onom golpe]
- Aya [entra izq]: Otra vez ustedes.
- Guardia [entra der]: El Abad dijo que nadie toque el Pergamino esta noche. Ni siquiera nosotros.
- Aya: ¿Para qué quiere el Abad el Pergamino?
- Guardia: Para llevarlo abajo.

**Después**
- [temblor · onom temblor]
- Narración: El suelo tiembla. Las lámparas se apagan solas.
- [plano .1,.55 x1.5 · oscuro]
- Narración: En la oscuridad, sobre la pared, aparece una mano de ceniza. Chica. Dibuja seis puntos alrededor de uno, y se borra.
- Aya [entra izq] *(pensando)*: Tía.
- Aya *(pensando)*: Se está cansando.

#### n21 · Jubei
Rival: Jubei · IA: difícil · Regla: normal
**Antes**
- *El patio, cerca de la medianoche.* [lugar courtyard · plano .85,.5 x1.4 · oscuro]
- Narración: Dos sombras saltan el muro del Templo. Una cae mal y tose.
- Explorador [entra der corre]: ¡Aya!
- Aya [entra izq]: ¡¿Sora?! ¿Cómo saliste de la torre?
- Explorador: Nos sacó Ren. Está subiendo a buscar al Shogun.
- Explorador: Voy a sacar de las celdas a las kunoichi del puente. Jubei te quiere hablar.
- [sale Explorador corre]
- Jubei [entra der sombra]: Dame el Pergamino, Aya.
- Aya: ¿Para qué?
- Jubei [plano .7,.45 x1.45]: Yo fui monje. Soy una mano del Templo. Bajo con el Abad y lo cerramos los dos.
- Aya: ¿Y la mano del clan?
- Jubei: …
- Aya: Uno solo no alcanza. Lo dice el Pergamino. Lo dice mi tía.
- Jubei: Tu tía bajó sola porque yo no llegué. No va a bajar otra de su sangre mientras yo respire.
- Aya: Eso mismo le dijo el Abad a usted. Y lo encerró.
- Narración: Jubei se queda quieto. Después levanta las manos para pelear.
- Jubei: Entonces vas a tener que pasar por encima mío.

**Después**
- Jubei [entra der]: …
- Aya [entra izq]: La tía Natsu también le hubiera ganado.
- Jubei: Siempre me ganaba. Por eso la quería.
- [plano .55,.5 x1.3 lento]
- Jubei: Dieciséis años odiando a Hōshin por encerrarme, y esta noche iba a hacer lo mismo con vos.
- Jubei: Bajamos juntos. Vos, yo y el Pergamino.
- Aya: Primero hay que sacárselo al Abad.
- Jubei: Andá a la biblioteca. Yo distraigo a los de la puerta.
- [sale Jubei corre]
- Aya *(pensando)*: Un monje que ayuda a una ninja. Como en el cuento de Tao.

#### n22 · Gon
Rival: Gon · IA: difícil · Regla: el rival tiene un Dragón de más
**Antes**
- *El pasillo de la biblioteca.* [lugar library · plano .3,.6 x1.3]
- Gon [entra der corre]: Vos otra vez. Ren no está para defenderte.
- Aya [entra izq]: No vine por él.
- Gon: El Abad dijo que nadie pasa. Esta noche menos que nunca.
- Aya: ¿Sabés qué pasa si el Abad baja solo?
- Gon: Lo arregla. Como siempre.
- Aya: Como hace dieciséis años. Esa noche cayó lluvia gris.
- Aya [plano .6,.45 x1.4]: Tu hermana tose ceniza, Gon. Si el Abad baja solo, va a toser más.
- Gon: ¡No hables de Hana!

**Después**
- Gon [entra der]: ¿Por qué no me rematás?
- Aya [entra izq]: Porque no sos mi enemigo.
- [plano .5,.5 x1.2 lento]
- Aya: Ninguno de ustedes lo es.
- Gon: …
- Gon: Si lo que decís es verdad… ¿Hana se cura?
- Aya: Si lo cerramos bien, sí. Con las dos manos.
- Gon *(apartándose)*: Entonces apurate. El Abad tiene el Pergamino en la mano y una vela que se acaba.

#### n23 · Las puertas de la biblioteca
Rival: monjes de élite · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *La puerta del archivo.* [lugar library · plano .5,.55 x1.4 · oscuro]
- Mei [entra der sombra]: Te dejé ir una vez.
- Aya [entra izq]: Y ahora no.
- Mei: Ahora no puedo. Esta noche el Abad baja, y le juré cuidarle la espalda.
- Aya: ¿Usted sabe lo que dice el Pergamino?
- Mei: Sé lo que decía la página que arranqué. Una mujer que esperó al pie de una escalera.
- Mei [plano .6,.45 x1.45]: Si te dejo pasar y te equivocás, son dos tumbas vacías.

**Después**
- Mei [entra der]: …
- Mei: Peleás como Natsu. Como alguien que no vino a robar.
- Aya [entra izq]: Vine a terminar lo que mi tía empezó.
- Mei [sale Mei · plano .55,.55 x1.4 lento] *(apartándose)*: Que lo lea alguien. Por fin.

#### n24 · JEFE — Abad Hōshin
Rival: el Abad · IA: maestro (jefe final) · Regla: normal
**Antes**
- *La biblioteca. El Pergamino de Jade sobre el altar.* [plano .55,.55 x1.5]
- [plano .5,.5 x1.1 lento]
- Narración: El Abad está sentado frente al altar. Tiene las manos vendadas, y las vendas, grises.
- Abad [entra der sombra]: La sobrina de Natsu.
- Aya [entra izq]: ¿Me conoce?
- Abad: Tenés su manera de entrar sin pedir permiso.
- Aya: Usted la dejó bajar sola.
- Abad: Ella me dejó a su hijo en los brazos. Y no la pude parar.
- Abad [plano .6,.45 x1.45]: Esta noche bajo yo. Nadie más.
- Aya: Usted solo no alcanza. Lo sabe.
- Abad: Alcanza para unos años. Para que el chico crezca lejos.
- Aya: Ren no está lejos. Está en la pagoda, pidiéndole la mano al Shogun.
- Narración: Por primera vez, al Abad le tiemblan las manos vendadas.
- Abad: En cuarenta años nadie me ganó. Si me ganás, leelo.

**Después**
- [arte art_scroll · plano .55,.7 x1.5]
- Narración [plano .55,.5 ancho .85 lento]: Aya desenrolla el Pergamino de Jade.
- Aya [plano .6,.75 x1.6] *(leyendo)*: «Seis piedras alrededor. Una mano del Templo, una mano de la Sombra. Si falta una, el sello se cobra a quien lo cierre.»
- Aya: …No es un arma. Es un ritual. Y necesita a los dos.
- [plano .15,.45 x1.5 lento]
- Abad: Lo sé. Lo supe siempre.
- Abad: Natsu me pidió que la dejara bajar con su monje, y le dije que no. Así la maté.
- Aya: Entonces esta vez dígale que sí a alguien.
- [lugar ashCourtyard · temblor · onom temblor · plano .5,.6 x1.2]
- Narración: El suelo se abre bajo el patio. Una columna de ceniza sube al cielo.
- Narración: Y en la ceniza, por un instante, una mano de mujer que se suelta.
- Aya [entra izq]: Tengo el Pergamino.
- Aya: Pero sola no sirve.
- **→ Fin de la campaña Ninja**
- *Tarjeta:* Hay otra mitad de esta historia. Terminá **El camino del Templo** para descubrir el verdadero final.

---

## 6. El Sello — el verdadero final

*Se abre con las dos campañas terminadas. Prólogo antes de F1:*
- *La misma noche.* [lugar pagodaTop · plano .8,.25 x1.4]
- Narración [plano .5,.55 x1.15 lento]: En la cima de la pagoda, Ren venció a Kage.
- [lugar library · página · plano .55,.55 x1.45]
- Narración [plano .45,.5 x1.1 lento]: En la biblioteca, Aya venció al Abad. A la misma hora.
- [arte art_oni_rises · plano .5,.85 x1.5 · temblor · onom temblor]
- Narración [plano .5,.45 x1.15 lento]: Bajo el Templo, la mano que sostenía la última piedra se suelta.
- Oni [plano .5,.3 x1.5 · latido]: **Por fin. Se cansó.**
- Oni: **Y ustedes, peleándose. Como siempre.**

#### f1 · La vanguardia de ceniza
Ren solo, con fichas Shaolin, contra el Oni · IA: difícil · Regla: el Oni tiene sus fichas propias (Gaki y Ojo del Oni)
**Antes**
- *El patio del Templo, en llamas grises.* [lugar ashCourtyard · plano .5,.3 x1.45 · humo]
- [plano .5,.6 x1.1 lento · niebla]
- Ren [entra izq corre]: ¡Maestro Tao! ¿Llegué tarde?
- Tao [entra der]: Tu madre aguantó todo lo que pudo, chico. Se soltó.
- [plano .5,.25 x1.5 · temblor · onom temblor]
- Oni [entra centro humo · latido]: Un monje. Uno solo. Como siempre.
- Tao [plano .65,.5 x1.3]: Rodealo, chico. ¡Ahora!

**Después**
- [lugar ashCourtyard · plano .5,.35 x1.3 lento · humo]
- Narración [plano .5,.7 x1.4 lento]: El Oni retrocede a la grieta.
- Narración [latido]: Pero no se cierra.
- Ren [entra izq]: …
- Zorra Blanca [entra der humo · plano .7,.45 x1.4]: Rodearlo lo detiene.
- Zorra Blanca [latido]: **No lo sella.**

#### f2 · La garra
Aya sola, con fichas Ninja, contra el Oni · IA: difícil · Regla: igual que f1
**Antes**
- *El jardín de piedra, partido en dos.* [lugar brokenGarden · plano .5,.65 x1.45]
- [plano .5,.5 x1.1 lento · temblor]
- Aya [entra izq corre]: ¡Jubei! ¿Y el Abad?
- Jubei [entra der sombra]: Vivo. Pero no puede ni pararse.
- [plano .5,.25 x1.5 lento · oscuro · onom temblor]
- Aya [plano .3,.45 x1.35]: Entonces lo rodeamos nosotros.

**Después**
- [lugar brokenGarden · plano .5,.35 x1.3 lento · humo]
- Narración: El Oni vuelve a retroceder. Más grande.
- Zorra Blanca [entra der humo]: Una mano sola no alcanza.
- Zorra Blanca [plano .7,.45 x1.4]: Nunca alcanzó.
- *El patio. Ren y Aya, frente a frente.* [lugar ashCourtyard · plano .5,.5 x1.4]
- [plano .5,.55 x1.1 lento]
- Ren [entra izq]: Kage me dijo la mitad.
- Aya [entra der]: El Pergamino dice la otra.
- [arte art_scroll · plano .55,.7 x1.5]
- Aya [off · plano .55,.5 ancho .85 lento]: Una mano del Templo y una de la Sombra.
- [lugar ashCourtyard · página · entra Aya der ya · plano .5,.5 x1.25]
- Aya: Kuro me dijo que se lo diera a quien tuviera la otra mano.
- Ren [entra izq]: Mi madre bajó sola.
- Ren: Nosotros, juntos.
- [plano .5,.45 x1.3 · destello · humo]
- Zorra Blanca [entra centro humo] *(tomando forma humana)*: Como Daishin y Kagerō.
- Zorra Blanca [plano .5,.4 x1.5 lento]: Yo era la promesa que se hicieron.
- Zorra Blanca [latido]: Y me estaba apagando.

#### f3 · El Sello
Ren y Aya juntos: Monje y Shogun en la misma mano, fichas de las dos facciones · IA: maestro · Regla especial:
- Jugás con fichas Shaolin y Ninja a la vez, con los dos líderes: si rodean a cualquiera, perdés.
- Podés usar Meditación de Jade y Kawarimi; usar una recarga las dos.
- El Oni solo queda sellado si lo rodean fichas de **las dos facciones** (al menos una de cada una).

**Antes**
- [lugar ashCourtyard · plano .5,.3 x1.5 · niebla · temblor · onom temblor]
- [plano .5,.6 x1.1 lento · entra Ren izq ya]
- Abad [entra der corre · plano .65,.5 x1.3] *(herido, llegando)*: Ren… perdoname.
- [página · plano .5,.5 x1.25 · entra Aya izq ya]
- Kage [entra der sombra] *(llegando por el muro)*: Aya. Hacé lo que dice el Pergamino.
- Kage: Esta vez el clan no llega tarde.
- [página · plano .5,.35 x1.5 lento · oscuro · latido]
- Zorra Blanca [entra centro humo]: Seis piedras. Dos manos.
- Zorra Blanca [destello · plano .5,.45 x1.4]: Ahora.

**Después — Epílogo**
- [arte art_seal · plano .5,.5 x1.45 · destello]
- Narración [plano .5,.55 ancho .8 lento]: Seis piedras se encienden de verde y de rojo.
- Narración [latido · plano .5,.45 x1.3]: La grieta se cierra.
- Narración [plano .5,.3 x1.05 lento · humo]: El Oni se apaga como una brasa en la lluvia.
- [plano .5,.5 x1.3 lento]
- Narración: Sobre la grieta cerrada queda una figura de ceniza. Una mujer chica, con un abanico.
- Ren [entra izq] *(en voz baja)*: Mamá.
- Jubei [entra der]: Natsu.
- Narración: La figura levanta la mano, como quien saluda desde lejos. Y el viento se la lleva.
- *Una semana después.* [lugar epilogue · plano .5,.4 x1.4]
- [plano .5,.55 x1.1 lento]
- Narración: En el patio de atrás, la piedra sin nombre ya tiene uno. Al lado, un cuenco y un abanico quemado.
- Abad [entra der]: El sello aguantará otros trescientos años.
- Kage [entra izq sombra]: Si no volvemos a olvidarnos.
- [página · plano .5,.5 x1.2]
- Ren [entra izq]: Entonces no lo olvidemos.
- Aya [entra der]: Un duelo por año. Templo contra clan.
- Aya [plano .7,.45 x1.35]: En el tablero.
- [plano .5,.4 x1.05 lento · vacía]
- Narración: Y así empezaron los **duelos de honor**: monjes y ninjas, enfrentados para no olvidar cómo se rodea a un demonio.
- Zorra Blanca [entra centro humo · plano .5,.45 x1.4]: Hasta la próxima grieta.
- [sale Zorra Blanca humo · plano .5,.5 x1.0 lento]
- **→ Fin. Desbloqueo:** mesa Pizarra del río y marco de obsidiana.

---

## 7. Las fichas del Oni (para la Fase 1)

| Ficha | Cant. | Regla (rota a propósito) |
|---|---|---|
| **Oni de Ceniza** (líder) | 1 | Se mueve hasta 2 casillas. En F3 solo se sella si lo rodean fichas de las dos facciones. |
| **Gaki** | 2 | Salta a cualquier casilla libre del borde de la colmena (sin límite) y paraliza a una ficha vecina al llegar. |
| **Ojo del Oni** | 1 | Inmune a Meditación de Jade y Kawarimi. Anula a las fichas enemigas a 2 casillas o menos. |
| Fichas corrompidas | resto | Fichas comunes de ambas facciones, con piedra de ceniza. |

El Oni no tiene habilidad de facción: su poder está en las fichas.

## 8. Cómo se ven las viñetas

La viñeta es un libro de tinta con dos maneras de armar la página (las elige el director, no el guion):

- **Paneo** (recurso, no regla): un solo cuadro grande y una cámara que recorre el escenario. Queda para
  las ilustraciones (`arte`) y para la página que abre la escena con un `plano … lento` antes de que
  nadie hable (la intro de la muralla).
- **Viñetas** (el resto): la página se divide en hasta 3 filas que arrancan en blanco, y cada toque suma
  una viñeta con su entrada: el lugar se descubre con un barrido de tinta, el primer plano llega desde el
  lado de quien habla y el plano de grupo se acerca. Cada momento o narración es una viñeta ancha con su
  cartel; quien habla va en primer plano, salvo la primera línea o cuando cambia quién está (plano con
  todos). Dos líneas cortas seguidas de distinta gente comparten fila. Un `plano` mudo es una viñeta
  del lugar; un efecto mudo sacude la última viñeta.

Cada línea con texto espera un toque, y un sello rojo que late abajo avisa cuándo tocar.
Los **golpes mudos** (solo cámara, entradas o salidas) siguen solos al terminar: sin nada que leer, no se
pide un toque. Si el golpe todavía está entrando, el toque lo completa; mantener apretado lee de corrido.

- **Cámara quieta en los diálogos.** Mientras hablan, el fondo no se mueve solo (marea). El movimiento
  se reserva para abrir momentos, las pausas y la narración; un `plano` en una línea de diálogo es un
  acento puntual, usarlo poco.

- Cada momento (las líneas en *cursiva*) **da vuelta la página**: plano general del lugar, la cámara se
  aleja despacio y lo recorre antes de que nadie hable.
- Quien habla y no está en el cuadro entra por su lado (el protagonista, a la izquierda). Quien no habla
  queda en penumbra. Los globos salen sobre su cabeza, con su nombre en la solapa; quedan los dos últimos.
- La narración va en el cartel de arriba. Las ilustraciones (`art_*`) ocupan la hoja entera y la cámara
  pasa de un foco a otro.
- Lo ya visto se puede releer desde el **Pergamino** en la pantalla de campañas.

### Puesta en escena

Entre corchetes, separada por `·`. Una línea que es solo corchetes es un **golpe mudo**: la cámara se
mueve o alguien entra, y sigue sola al terminar. Junto a un nombre, acompaña esa línea; `entra` sin nombre es
quien habla.

| Indicación | Qué hace |
|---|---|
| `plano X,Y xZOOM lento` | La cámara va a ese punto del fondo (0..1); `lento` es un paneo largo |
| `plano X,Y ancho F` · `plano X,Y entero` | Muestra al menos esa fracción del ancho del arte (o el arte entero), aunque no llene el alto: para que los personajes de una ilustración se vean completos |
| `entra QUIÉN izq\|der\|centro\|0..1 humo\|sombra\|corre\|ya` | Entra a escena (`ya`: sin animación) |
| `sale QUIÉN humo\|corre` · `vacía` | Se va uno · se van todos |
| `temblor` · `destello` · `humo` · `latido` | Efectos de un golpe |
| `oscuro` · `niebla` | Efectos que duran hasta la página siguiente |
| `onom CLAVE` | Onomatopeya grande (texto en `onom.CLAVE`) |
| `arte NOMBRE` · `lugar PLACE` · `página` | Ilustración a página completa · cambio de lugar · página nueva |
| `off` | Quien dice la línea habla fuera de cuadro (no entra) |

Ejemplo (s4, Después):

```
- [arte art_fox_cell · plano .82,.45 x1.2 · latido]
- Narración [plano .38,.5 x1.1 lento]: En la puerta de la celda hay una zorra blanca. Nadie la vio entrar.
- Zorra Blanca [plano .54,.5 ancho .8 lento]: Todavía no es momento de que el chico sepa lo que hay abajo.
```

Para probar una escena suelta: `flutter run --dart-define=STORY=s4.post --dart-define=STORY_AT=12`.
