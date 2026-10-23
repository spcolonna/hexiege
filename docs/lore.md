# Hexiege — Biblia de la historia y guion

> Borrador para revisar antes de implementar. Todo en español; se traduce a inglés y chino
> una vez aprobado. Cada batalla tiene una charla **antes** (viñetas que entran de a una) y
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
| **Abad Hōshin** | Templo | *nuevo* | Maestro de Ren. Sabio y orgulloso. Esconde que el sello se rompe. |
| **Gran Shogun Kage** | Clan | *nuevo* | Líder del clan. Duro pero no cruel. Obedece una leyenda que no entiende. |
| **Maestra Mei** | Templo | `abbess` | Segunda del Templo. Sabe parte de la verdad y calla por lealtad. |
| **Tao, el monje borracho** | Templo | `drunken` | Guardián de la cripta. Parece un payaso; es el que más sabe. |
| **Gon** | Templo | `staff` | Compañero de Ren, rival amistoso. |
| **Kuro** | Clan | `jonin` | Jonin, mentor de Aya. Fiel al Shogun hasta el final. |
| **Jubei, el ronin** | Ninguno | `ronin` | Ex monje expulsado por preguntar demasiado. Ayuda a los dos protagonistas. |
| **La Zorra Blanca** | Espíritu | `kitsune` | Aparece en las dos campañas. Habla en acertijos. Es el lazo entre Daishin y Kagerō. |
| **El Oni de Ceniza** | — | *nuevo* | El demonio sellado. Casi no habla: cuando lo hace, en ceniza. |

**Retratos nuevos a generar:** Abad Hōshin, Gran Shogun Kage y el Oni de Ceniza (el avatar `oni` actual es un ninja con máscara, no el demonio).
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
- Narración [plano .45,.5 x1.05 lento]: Una sombra cruza el muro. Nadie la ve entrar.
- *Dentro, el dormitorio de los discípulos.* [lugar dormitory · plano .5,.5 x1.25]
- Abad [entra der sombra]: Ren. Despertate.
- Ren [entra izq]: ¿Maestro? ¿Qué pasa?
- Abad: Alguien entró al Templo. Andá a ver quién se atreve.
- Ren: ¿Solo yo?
- Abad: Si es uno, alcanza con vos.
- [plano .62,.42 x1.45]
- Abad: Si son más… gritá.

**Después**
- *El muro, un instante después.* [lugar wall · plano .35,.5 x1.3]
- Ren [entra izq corre]: ¡Se escapa por el muro!
- [entra Ninja der · plano .62,.4 x1.45]
- [sale Ninja corre · plano .85,.28 x1.3 lento]
- Narración: El ninja salta y la noche se lo traga. No se llevó nada.
- Ren *(pensando)*: Nada robado. Nada roto.
- [plano .5,.5 x1.1 lento]
- Ren *(pensando)*: Entonces… ¿a qué vino?

#### s2 · Patio de entrenamiento
Rival: el explorador capturado · IA: fácil · Regla: el rival no usa habilidad
**Antes**
- *A la mañana. Patio de entrenamiento.* [plano .2,.55 x1.3]
- [plano .75,.5 x1.15 lento]
- Narración: El sol pega sobre los postes de madera. Los discípulos entrenan desde el alba.
- Mei [entra der]: Gon atrapó a un explorador en el bosque.
- Gon [entra centro corre]: Y vos dejaste escapar al tuyo, Ren.
- Ren [entra izq]: Era rápido.
- Gon: Excusas.
- Mei: Basta. Antes de interrogarlo, el Abad quiere ver cómo peleás.
- [sale Gon · entra Explorador centro sombra]
- Mei: Vas a enfrentarte al explorador que trajo Gon. Tiene las manos atadas: no podrá usar el Kawarimi.
- Explorador: Atado y todo, te gano, monjecito.

**Después**
- *El patio, al mediodía.* [lugar yard · plano .5,.55 x1.2]
- Mei [entra der]: Bien. Rodeás con paciencia. Eso es lo importante.
- Ren [entra izq]: Maestra, ¿por qué siempre rodeamos?
- Ren: ¿Por qué no golpeamos y ya?
- [plano .72,.45 x1.45 lento]
- Mei: …
- Mei: Porque así nos enseñaron.
- Ren *(pensando)*: Eso no es una respuesta.

#### s3 · Emboscada en el bosque
Rival: tres ninjas · IA: fácil · Regla: tu Monje empieza con 3 fichas enemigas al lado
**Antes**
- *Esa tarde. El camino al pueblo.* [plano .2,.45 x1.35]
- [plano .6,.5 x1.1 lento]
- Narración: Ren baja al pueblo a buscar arroz. El canasto vacío le golpea la espalda.
- Ren [entra izq]: Qué silencio…
- [plano .22,.3 x1.5]
- Narración: Ni un pájaro. Ni el viento.
- [entra Ninja der sombra · entra Explorador centro sombra · temblor · destello]
- Narración: Tres sombras caen de los árboles.
- Ninja: Es el discípulo del Abad. ¡Rodéenlo!

**Después**
- *El camino, al caer el sol.* [lugar road · plano .55,.5 x1.2]
- [entra Ren izq · entra Ninja der]
- Ren: ¿Por qué me esperaban a mí?
- Ninja: …
- Ninja [sale Ninja corre]: ¡Preguntale al viejo qué guarda abajo!
- [plano .85,.4 x1.3 lento]
- Ren *(pensando)*: ¿Abajo?

#### s4 · La celda
Rival: rescatistas ninja · IA: fácil · Regla: normal
**Antes**
- *Noche. Las celdas del Templo.* [plano .15,.45 x1.5]
- [plano .7,.5 x1.25 lento]
- Narración: Bajo el ala vieja del Templo arde una sola antorcha. Detrás de los barrotes, alguien no duerme.
- [entra Explorador der sombra · plano .72,.55 x1.4]
- Ren [entra izq]: Tus amigos me emboscaron en el camino. ¿Qué buscan?
- Explorador: …
- Explorador: No te voy a decir nada, monje.
- Ren: Entonces esperamos. Tengo toda la noche.
- [plano .5,.15 x1.4 · onom golpe · temblor]
- Narración: Un golpe seco en el techo. Después, otro.
- [humo · destello]
- Gon [entra centro corre]: ¡Ren! ¡Vinieron a sacarlo!

**Después**
- *El humo se disipa. Las celdas.* [plano .25,.5 x1.45]
- [plano .68,.5 x1.25 lento]
- Narración: Los rescatistas huyeron. Al explorador lo dejaron atrás.
- [entra Explorador der sombra]
- Ren [entra izq]: Tus amigos te abandonaron.
- Explorador: No me abandonaron. Me dejaron para que hable con vos.
- Explorador: Escuchame, chico. No venimos a robar.
- Explorador [plano .7,.45 x1.6]: **Venimos a advertir.**
- Ren: ¿Advertir qué?
- Explorador: Lo que tu Abad guarda abajo…
- [niebla · plano .5,.5 x1.1 lento]
- Narración: La antorcha se apaga sola. Por debajo de la puerta entra una niebla fría.
- [arte art_fox_cell · plano .82,.45 x1.2 · latido]
- Narración [plano .2,.5 x1.1 lento]: En la puerta de la celda hay una zorra blanca. Nadie la vio entrar.
- Zorra Blanca: Todavía no es momento de que lo sepa.
- [lugar cells · entra Ren izq ya · entra Explorador der ya · entra Zorra Blanca centro humo · niebla · plano .55,.5 x1.2]
- Explorador: …Sí, señora.
- Ren: ¿Señora? ¿Quién…?
- [sale Zorra Blanca humo · sale Explorador humo · destello · niebla]
- Narración: La zorra y el explorador desaparecen en la niebla.
- [plano .72,.5 x1.55 lento]
- Ren *(pensando)*: La celda sigue cerrada. Con llave. Desde afuera.

#### s5 · El muro norte
Rival: el clan cubre la huida · IA: fácil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Minutos después. El muro norte.* [plano .6,.45 x1.4 · humo]
- Gon [entra der corre]: ¡Están por todo el muro! Quieren cubrir la huida.
- Ren [entra izq corre]: Gon, ¿vos viste a la zorra?
- Gon: ¿Qué zorra?
- [plano .2,.4 x1.3]
- Gon: ¡Ren! ¡Concentrate!

**Después**
- [plano .5,.5 x1.1 lento]
- Narración: Los ninjas se retiran al bosque. El muro queda en silencio.
- Gon [entra der]: ¡Corren como conejos!
- Ren [entra izq]: …
- Ren *(pensando)*: «Venimos a advertir.»
- [plano .9,.3 x1.5 lento]
- Ren *(pensando)*: ¿A advertir de qué?

#### s6 · JEFE — Kuro, el jonin del humo
Rival: Kuro · IA: fácil (jefe) · Regla: Kuro tiene un Shinobi de más
**Antes**
- *Amanecer. El portón principal.* [plano .3,.55 x1.3]
- [plano .55,.5 x1.15 lento]
- Narración: La niebla del alba cubre los escalones. Alguien espera en la puerta, solo.
- [entra Kuro der sombra · humo]
- Kuro: El discípulo del Abad.
- Ren [entra izq]: ¿Quién sos?
- Kuro: Me contaron que rodeás bien.
- Kuro [plano .62,.45 x1.45]: Soy alguien que se va a llevar lo que es nuestro. Hoy, o la próxima.

**Después**
- Kuro [entra der]: Bien peleado.
- Kuro: Pero no entendés nada de lo que defendés.
- [sale Kuro humo · humo]
- Ren [entra izq]: ¡Esperá!
- *Más tarde. La sala del Abad.* [lugar abbotHall · plano .7,.5 x1.3]
- Ren [entra izq]: Maestro, el ninja dijo que venían a advertir.
- Abad [entra der]: …
- Ren: Habló de algo que guardamos abajo.
- Abad: Nadie habló con nadie, Ren.
- Ren: Pero…
- Abad [plano .6,.4 x1.5 · temblor]: **Olvidalo.** Es una orden.
- [temblor · onom temblor]
- Narración: El suelo tiembla, apenas.
- [arte art_ash_ceiling · plano .3,.65 x1.25]
- Narración [plano .55,.25 x1.15 lento]: Del techo cae un polvo gris.
- Ren: ¿Maestro…?
- Narración: No es polvo. Es **ceniza**.
- Abad *(pensando)*: Ya empezó.
- **→ Fin del Acto I · desbloqueo**

### Acto II · El bosque de los susurros

#### s7 · Huellas
Rival: exploradores · IA: fácil · Regla: normal
**Antes**
- *Días después. Fuera del Templo, sin permiso.*
- Ren *(pensando)*: Si el Abad no me lo dice, lo voy a averiguar.
- Tao: ¿Saliendo a escondidas, chico? *hip*
- Ren: ¡Maestro Tao! No le diga a nadie.
- Tao: ¿Yo? Yo no vi nada. Nunca veo nada. *hip*. Te acompaño.

**Después**
- Tao: Las huellas van al este. Al viejo santuario.
- Ren: ¿Usted sabe algo?
- Tao: Sé tomar. Lo demás lo olvidé. *hip*

#### s8 · El puente de piedra
Rival: guardia del puente · IA: normal · Regla: el Asedio empieza en la ronda 15
**Antes**
- *El único puente sobre el río.*
- Narración: Los ninjas bloquean el puente. La batalla será larga y sin retirada.
- Tao: Yo te espero de este lado. Tengo… cosas que hacer. *hip*

**Después**
- Ren: ¡Pasé!
- Tao: Nunca dudé. Bueno, un poco.

#### s9 · Las tallas
Rival: Jubei, el ronin · IA: normal · Regla: normal
**Antes**
- *El santuario abandonado.*
- Narración: En las piedras hay tallas. Seis piedras en hexágono, alrededor de una figura con cuernos.
- Ren: Ese es el símbolo del Templo… y ese es el del clan. ¿Juntos?
- Jubei: Nadie mira esas piedras hace siglos. ¿Qué hace un monje acá?
- Ren: ¿Y vos quién sos?
- Jubei: Uno que preguntó lo mismo que vos. Mostrame cómo peleás y te contesto.

**Después**
- Jubei: Fui monje. Me echaron por preguntar qué dice el Pergamino de Jade.
- Ren: El Pergamino es sagrado. Solo el Abad lo lee.
- Jubei: Exacto. ¿Y nunca te preguntaste por qué?

#### s10 · Cuatro sombras
Rival: refuerzos del clan · IA: normal · Regla: el rival tiene 4 Shinobi
**Antes**
- *El bosque, de noche.*
- Jubei: Te siguieron desde el santuario. Son muchos.
- Ren: Los Shinobi se meten por cualquier rendija.
- Jubei: Entonces no dejes rendijas.

**Después**
- Narración: Un shinobi caído deja caer un pergamino pequeño: una orden del Shogun.
- Ren *(leyendo)*: "Traigan el Pergamino de Jade antes de la luna nueva."

#### s11 · Niebla en el valle
Rival: patrulla en la niebla · IA: normal · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *El valle. Niebla espesa.*
- Narración: En la niebla nada se queda quieto.
- Zorra Blanca: Seguime, pequeño monje.
- Ren: ¡Vos! ¿Qué sos?
- Zorra Blanca: La que recuerda. Seguime y no te pierdas.

**Después**
- Zorra Blanca: Mañana vas a conocer a alguien que hace tus mismas preguntas.
- Ren: ¿Quién?
- Zorra Blanca: Alguien del otro lado.

#### s12 · JEFE — Aya *(duelo cruzado)*
Rival: Aya · IA: normal (jefe) · Regla: normal
**Antes**
- *El santuario, al amanecer.*
- Aya: Un monje. Solo. En mi bosque.
- Ren: No es tu bosque.
- Aya: …¿Vos también la ves? A la zorra blanca.
- Ren: *(sorprendido)* Sí.
- Aya: Entonces sabés que algo anda mal. Igual te voy a ganar.

**Después**
- Aya: Ganaste. Esta vez.
- Ren: El tuyo dijo que venían a advertir. ¿De qué?
- Aya: No sé. Mi Shogun tampoco. Pero preguntale a tu Abad **qué hay debajo del Templo**.
- Narración: Una bomba de humo. Aya ya no está.
- **→ Fin del Acto II**

### Acto III · La biblioteca cerrada

#### s13 · El regreso
Rival: Gon (entrenamiento) · IA: normal · Regla: normal
**Antes**
- *El Templo. Ren vuelve después de una semana.*
- Gon: ¡Ren! El Abad estuvo furioso. Cerró la biblioteca con llave.
- Ren: ¿Cerró la biblioteca?
- Gon: Y puso guardias en la cripta. Algo pasa. Peleemos, como antes. Te extrañé.

**Después**
- Gon: Peleás distinto. Más… como ellos.
- Ren: Gon, ¿vos sabés qué hay en la cripta?
- Gon: Nadie baja ahí. Solo Tao.

#### s14 · Los novicios que sueñan
Rival: novicios inquietos · IA: normal · Regla: el rival no usa habilidad
**Antes**
- *El dormitorio de novicios.*
- Novicio: Hermano Ren… soñamos con fuego. Todos, el mismo sueño.
- Novicio: Una cosa con cuernos debajo de nuestros pies.
- Ren: Son solo sueños. Vamos, a entrenar.

**Después**
- Ren *(pensando)*: Una figura con cuernos. Como en las tallas.

#### s15 · La biblioteca
Rival: Maestra Mei · IA: normal · Regla: normal
**Antes**
- *Medianoche. La biblioteca.*
- Narración: Ren fuerza la puerta. Adentro, la Maestra Mei lo espera.
- Mei: Sabía que vendrías.
- Ren: Quiero leer el Pergamino.
- Mei: No está acá. Y si estuviera, primero tendrías que pasar por mí.

**Después**
- Mei: …Hay un sello, Ren. Abajo del Templo. Se está rompiendo.
- Ren: ¿Y el Abad?
- Mei: Dice que puede renovarlo solo. Que nadie más tiene que saberlo.
- Ren: ¿Usted le cree?
- Mei: *(silencio)*

#### s16 · Ceniza en el patio
Rival: incursión ninja · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Amanecer. El patio cubierto de ceniza.*
- Narración: El temblor de la noche abrió una grieta en el patio. De ella sale humo gris.
- Gon: ¡Ninjas en el muro! ¡Aprovechan el caos!
- Ren: ¡No es su culpa! ¡Viene de abajo!

**Después**
- Narración: Entre la ceniza, por un momento, Ren ve dos ojos rojos.
- Ren: …¿Lo vieron?
- Gon: ¿Ver qué?

#### s17 · La orden del Abad
Rival: guardias del clan · IA: difícil · Regla: el rival tiene 3 Kunoichi
**Antes**
- *La sala del Abad.*
- Abad: El temblor es culpa del clan. Kage quiere el Pergamino para liberar algo que no entiende.
- Ren: Maestro, Mei dijo que…
- Abad: Mei habla de más. Ren, vas a ir a la pagoda del clan. Vas a vencer a Kage. Es la única forma de proteger el Templo.
- Ren: ¿Yo?
- Abad: Sos el mejor que tengo.

**Después**
- Mei *(en voz baja)*: Ren. No vayas.
- Ren: Es una orden del Abad.
- Mei: Las órdenes también se equivocan.

#### s18 · JEFE — Tao, el monje borracho
Rival: Tao · IA: difícil (jefe) · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *El portón, de noche. Tao bloquea el camino.*
- Tao: ¿A la pagoda, chico? *hip*
- Ren: Déjeme pasar, maestro.
- Tao: El viejo te está usando. Si peleás con Kage, nadie va a quedar para lo que viene.
- Ren: ¿Qué viene?
- Tao: Ganame y te dejo ir. Perdé y te quedás.

**Después**
- Tao: Bah. Sos terco como Daishin.
- Ren: ¿Quién es Daishin?
- Tao: Preguntáselo a Kage. Si te deja hablar. *hip*
- **→ Fin del Acto III**

### Acto IV · La pagoda

#### s19 · El primer piso
Rival: guardia de la pagoda · IA: difícil · Regla: normal
**Antes**
- *La pagoda del clan. Cinco pisos.*
- Narración: Ren llega solo. La puerta está abierta, como si lo esperaran.
- Guardia: El Shogun dijo que vendría el chico del Abad. Que subiera si podía.

**Después**
- Ren: Faltan cuatro pisos.

#### s20 · El piso de los abanicos
Rival: kunoichi del clan · IA: difícil · Regla: el rival tiene 3 Kunoichi
**Antes**
- Kunoichi: Aya habló de vos. Dijo que preguntás mucho.
- Ren: ¿Está acá?
- Kunoichi: Se fue. Al Templo. Mientras vos subís, ella baja.

**Después**
- Ren *(pensando)*: Aya en el Templo… ¿y el Abad solo?

#### s21 · El piso de los Tengu
Rival: guardianes Tengu · IA: difícil · Regla: el rival tiene 3 Tengu
**Antes**
- Narración: Los Tengu saltan de viga en viga.
- Zorra Blanca: Dos caminos, una misma noche. Apurate, pequeño monje.

**Después**
- Ren: ¡Esperá! ¿Qué pasa en el Templo?
- Zorra Blanca: Lo que tenía que pasar.

#### s22 · Kuro, otra vez
Rival: Kuro · IA: difícil · Regla: Kuro tiene un Shinobi de más
**Antes**
- Kuro: Te dije que nos íbamos a ver.
- Ren: No vengo a robar nada. Vengo a hablar con tu Shogun.
- Kuro: Nadie habla con el Shogun sin pasar por mí.

**Después**
- Kuro: Subí. Pero cuando te diga la verdad, no vas a querer haberla escuchado.

#### s23 · Las puertas de arriba
Rival: guardia de élite · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- Narración: La última puerta. Detrás, una sola respiración, lenta.
- Ren *(pensando)*: El Abad dijo que lo venza. Tao dijo que lo escuche.

**Después**
- Kage *(desde adentro)*: Pasá, discípulo de Hōshin.

#### s24 · JEFE — Gran Shogun Kage
Rival: Kage · IA: maestro (jefe final) · Regla: normal
**Antes**
- *La cima de la pagoda.*
- Kage: Hōshin te mandó a matarme.
- Ren: A vencerte.
- Kage: Es lo mismo para él. Bien. Rodeame si podés.

**Después**
- Kage: …Ganaste. Ahora escuchá, porque nadie te lo va a decir.
- Kage: Bajo tu Templo duerme el Oni de Ceniza. Lo sellaron hace trescientos años.
- Kage: Tu Abad sabe que el sello se rompe. Lo sabe hace años.
- Ren: Entonces lo va a renovar.
- Kage: No puede. **No solo.** El clan siempre lo supo: el Pergamino es la mitad de nuestro pacto.
- Ren: ¿Qué pacto?
- Kage: Eso no lo sé. Por eso lo quería.
- Ren *(pensando)*: El maestro… me mintió.
- Narración: A lo lejos, sobre el Templo, sube una columna de ceniza.
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
- Kage [entra der sombra]: El Pergamino de Jade nos pertenece.
- Kage: Los monjes lo robaron hace siglos.
- Aya [entra izq]: ¿Qué dice el Pergamino, mi señor?
- Kage: …
- Kage [plano .7,.4 x1.4]: Eso no importa. Importa que vuelva a casa.
- Aya *(pensando)*: Siempre la misma respuesta.
- *Más tarde. El muro del Templo.* [lugar wall · plano .5,.5 x1.3]
- Kuro [entra der sombra]: El guardia del muro.
- [plano .14,.45 x1.6]
- Kuro: Pasalo sin hacer ruido.
- Aya [entra izq]: Como una sombra.

**Después**
- [plano .75,.5 x1.25 lento]
- Narración: El guardia duerme contra el muro. Ni se enteró.
- Aya [entra izq corre]: Adentro.
- Kuro [entra der sombra]: Bien. Ahora, lo difícil.

#### n2 · Los novicios
Rival: novicios · IA: fácil · Regla: el rival no usa habilidad
**Antes**
- *El patio de novicios.* [plano .2,.5 x1.35]
- [plano .75,.5 x1.2 lento]
- Novicio [entra der corre]: ¡Una sombra! ¡Alarma!
- Aya [entra izq]: Son chicos.
- Aya: Todavía no aprendieron la Meditación de Jade.
- Kuro [entra centro sombra]: Que no griten más fuerte.

**Después**
- Aya [entra izq]: Kuro… ¿por qué rodeamos?
- Aya: En el clan también nos enseñan a rodear.
- Kuro [entra der]: Porque así se gana.
- Aya: Pero ¿por qué **así**?
- [plano .7,.45 x1.45 lento]
- Kuro: …
- Kuro: Preguntás demasiado.

#### n3 · Golpe por sorpresa
Rival: maestro de guardia · IA: fácil · Regla: el Monje rival empieza con 3 de tus fichas al lado
**Antes**
- *El patio interior.* [plano .45,.6 x1.4]
- [plano .25,.5 x1.2 lento]
- Narración: Un maestro hace la ronda junto al incensario. No mira hacia arriba.
- [plano .7,.25 x1.45]
- Aya *(pensando)*: Nunca miran hacia arriba.
- [temblor · destello]
- Narración: Aya cae sobre el maestro de guardia antes de que reaccione.

**Después**
- [arte art_stairs · plano .2,.4 x1.3]
- Narración [plano .55,.6 x1.15 lento]: Desde el tejado, Aya ve algo raro: los monjes no custodian la biblioteca.
- Narración: Custodian una **escalera** que baja bajo el Templo.
- Aya *(pensando)*: ¿Qué guardan ahí abajo?

#### n4 · La escalera
Rival: Gon · IA: fácil · Regla: normal
**Antes**
- *La entrada de la cripta.* [plano .5,.65 x1.5]
- [plano .5,.5 x1.1 lento]
- Narración: Una boca de piedra en el suelo. Abajo, las antorchas arden sin temblar.
- Gon [entra der corre]: ¡Alto! Nadie baja.
- Aya [entra izq]: ¿Qué hay abajo?
- Gon: No lo sé.
- Gon: Y no lo vas a saber vos tampoco.

**Después**
- [plano .5,.65 x1.45 lento]
- Narración: Gon queda tendido en los escalones. Aya baja hasta la puerta de piedra.
- Aya [entra izq]: …
- [plano .5,.72 x1.7 lento · latido]
- Narración: La piedra está **tibia**. Y late, despacio.
- Aya: …Como un corazón.

#### n5 · Alarma
Rival: monjes de guardia · IA: fácil · Regla: el Asedio empieza en la ronda 15
**Antes**
- *Campanas. Todo el Templo despierta.* [plano .82,.55 x1.6]
- [onom campana · temblor]
- Kuro [entra der corre]: ¡Nos vieron! Nos vamos.
- Aya [entra izq]: Pero la escalera…
- [plano .3,.5 x1.25]
- Kuro: ¡Ahora, Aya!

**Después**
- *El muro norte.* [lugar wall · plano .7,.4 x1.3]
- Narración: Escapan por el muro norte. Uno de los suyos no llegó.
- Aya [entra izq]: ¿Dónde está el explorador?
- Kuro [entra der]: En las celdas. Lo atraparon.
- Aya: Vamos a volver por él.
- Kuro: …

#### n6 · JEFE — Maestra Mei
Rival: Mei · IA: fácil (jefe) · Regla: Mei tiene un Tigre de más
**Antes**
- *Noche siguiente. Las celdas.* [plano .2,.5 x1.4]
- [plano .55,.5 x1.2 lento]
- Narración: Aya vuelve sola a rescatar al explorador.
- [entra Mei der sombra]
- Narración: Mei la está esperando.
- Mei: Volviste por tu compañero. Eso dice algo bueno de vos.
- Aya [entra izq]: No necesito su aprobación.
- Mei [plano .7,.45 x1.45]: No. Necesitás pasar por mí.

**Después**
- Mei [entra der]: …Andate.
- Mei: Llevalo con vos.
- Aya [entra izq]: ¿Nos deja ir?
- Mei: Algo más grande que esta guerra viene.
- Mei: Cuanto menos sangre, mejor.
- *La escalera de la cripta.* [lugar cryptStairs · oscuro · niebla · plano .5,.55 x1.3]
- [plano .5,.6 x1.55 lento]
- Zorra Blanca [entra der humo]: Lo que viniste a buscar no es lo que pensás.
- Aya [entra izq]: ¿Quién sos?
- [sale Zorra Blanca humo]
- [latido · temblor]
- Narración: Bajo los pies de Aya, la piedra **late** una vez más. Más fuerte.
- **→ Fin del Acto I · desbloqueo**

### Acto II · El jardín de piedra

#### n7 · El informe
Rival: Kuro (entrenamiento) · IA: fácil · Regla: normal
**Antes**
- *La pagoda.*
- Aya: Mi señor, la puerta de la cripta late. Hay algo vivo debajo del Templo.
- Kage: Supersticiones de monjes.
- Aya: La toqué yo.
- Kage: Kuro. Entrenala. Está distraída.

**Después**
- Kuro: Peleás con rabia.
- Aya: Peleo con preguntas.

#### n8 · El jardín de piedra
Rival: jardineros del Templo · IA: normal · Regla: el Asedio empieza en la ronda 15
**Antes**
- *El jardín zen del Templo.*
- Narración: Los monjes cerraron el jardín. Hay que abrirse paso antes de que lleguen más.

**Después**
- Narración: En el centro del jardín, seis piedras forman un hexágono. Una tiene una grieta.
- Aya *(pensando)*: Seis piedras… como el tablero.

#### n9 · Los guardianes
Rival: Tigres de mármol · IA: normal · Regla: el rival tiene 3 Tigres
**Antes**
- Narración: Los Tigres de Mármol custodian el paso. Empujan todo lo que encuentran.

**Después**
- Zorra Blanca: Seis piedras, dos manos. ¿Recordás la canción, kunoichi?
- Aya: ¿Qué canción?
- Zorra Blanca: La que tu clan dejó de cantar.

#### n10 · La leyenda
Rival: Jubei, el ronin · IA: normal · Regla: normal
**Antes**
- *Un camino de montaña.*
- Jubei: Una ninja que mira piedras viejas. Raro.
- Aya: ¿Las conocés?
- Jubei: Fui monje. Sé lo que el Templo calla. Ganame y te cuento lo que el clan olvidó.

**Después**
- Jubei: Tu clan dice que el Pergamino es suyo. No miente.
- Jubei: Pero tampoco recuerda **por qué**. Preguntale a tu Shogun qué dice el Pergamino.
- Aya: Ya le pregunté. No sabe.
- Jubei: Entonces nadie en esta guerra sabe por qué pelea.

#### n11 · Humo y espejos
Rival: patrulla del Templo · IA: normal · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- Narración: Bombas de humo por todas partes. Que ningún monje sepa dónde estás.
- Zorra Blanca: Mañana vas a conocer a alguien que hace tus mismas preguntas.

**Después**
- Aya: Zorra… ¿quién sos?
- Zorra Blanca: La que recuerda lo que ustedes olvidaron.

#### n12 · JEFE — Ren *(duelo cruzado)*
Rival: Ren · IA: normal (jefe) · Regla: normal
**Antes**
- *El santuario, al amanecer.*
- Aya: Un monje. Solo. En mi bosque.
- Ren: No es tu bosque.
- Aya: …¿Vos también la ves? A la zorra blanca.
- Ren: *(sorprendido)* Sí.
- Aya: Entonces sabés que algo anda mal. Igual te voy a ganar.

**Después**
- Ren: Ganaste. Esta vez.
- Ren: Tu compañero dijo que venían a advertir. ¿De qué?
- Aya: No sé. Mi Shogun tampoco. Pero preguntale a tu Abad **qué hay debajo del Templo**.
- Ren: Mi maestro nunca miente.
- Aya: Entonces no te va a costar preguntarle.
- *(Las dos versiones del duelo son la misma charla; en el final se revela que ninguno ganó: la Zorra los separó.)*
- **→ Fin del Acto II**

### Acto III · La escalera

#### n13 · Descenso
Rival: guardias de la cripta · IA: normal · Regla: normal
**Antes**
- *Noche. El Templo, por dentro.*
- Narración: Aya se cuela otra vez. Esta vez no busca la biblioteca: busca la escalera.

**Después**
- Narración: Escalones que bajan, y bajan. El aire se pone caliente.

#### n14 · Las seis piedras
Rival: guardianes de la cripta · IA: normal · Regla: el rival no usa habilidad
**Antes**
- *La cripta.*
- Narración: Una sala enorme. En el piso, seis piedras en hexágono alrededor de una grieta.
- Narración: Tres piedras tienen grietas. Por ellas sale ceniza.
- Aya: Esto es un sello.

**Después**
- Narración: Desde la grieta, una voz, como brasas.
- Oni: …Kagerō…
- Aya: ¿Quién es Kagerō?

#### n15 · Ceniza
Rival: sombras de ceniza · IA: difícil · Regla: el rival tiene 4 Shinobi
**Antes**
- Narración: La ceniza toma forma. Fichas grises, sin dueño, se mueven solas.
- Aya: ¡¿Qué es esto?!

**Después**
- Narración: Las fichas de ceniza se deshacen. Pero vuelven a juntarse, más despacio.

#### n16 · El monje borracho
Rival: Tao · IA: difícil · Regla: normal
**Antes**
- Tao: Una ninja en mi cripta. Hace trescientos años que no pasaba. *hip*
- Aya: ¿Vas a llamar a los guardias?
- Tao: No. Vamos a jugar. Si me ganás, te cuento un cuento.

**Después**
- Tao: Había una vez un monje, Daishin, y una ninja, Kagerō.
- Tao: Rodearon a un demonio con seis piedras. Juntos. Las dos manos.
- Aya: ¿Un monje y una ninja… juntos?
- Tao: Eso es lo que el Templo borró. Y lo que tu clan olvidó. *hip*

#### n17 · La huida
Rival: monjes de la cripta · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- Tao: Y ahora corré, que el Abad baja todas las noches a mirar las grietas.

**Después**
- Narración: Aya sale del Templo con la primera luz. Le tiemblan las manos.

#### n18 · JEFE — Kuro
Rival: Kuro · IA: difícil (jefe) · Regla: habilidades con 5 usos y 1 turno de recarga
**Antes**
- *La pagoda.*
- Aya: Mi señor, el Pergamino no es un tesoro. Es un ritual. Un sello. Necesita al Templo y al clan.
- Kage: Cuentos de un monje borracho.
- Kage: Kuro irá al Templo esta noche a tomar el Pergamino por la fuerza.
- Aya: Si lo hacen, rompen el sello.
- Kuro: Entonces apartate, Aya.

**Después**
- Kuro: …Me ganaste. Andá vos, entonces. Pero traelo.
- Kage *(desde las sombras)*: Traeme el Pergamino, Aya. O no vuelvas.
- **→ Fin del Acto III**

### Acto IV · La biblioteca

#### n19 · Los tejados
Rival: vigías del Templo · IA: difícil · Regla: normal
**Antes**
- *La última noche antes de la luna nueva.*
- Narración: El Templo está más vacío que nunca. Dicen que el discípulo del Abad fue a la pagoda.
- Aya *(pensando)*: Ren y yo, cada uno en la casa del otro.

**Después**
- Aya: La biblioteca está a la vista.

#### n20 · Los Tigres de mármol
Rival: guardianes de la biblioteca · IA: difícil · Regla: el rival tiene 3 Tigres
**Antes**
- Narración: Los Tigres de Mármol custodian la biblioteca. Empujan todo lo que encuentran.

**Después**
- Narración: El suelo tiembla. Las lámparas se apagan solas.

#### n21 · Jubei
Rival: Jubei · IA: difícil · Regla: normal
**Antes**
- Jubei: Vine a pedirte una cosa.
- Aya: ¿Vas a pelear conmigo otra vez?
- Jubei: Sí. Para saber si estás lista. Si lo leés, ya no hay vuelta atrás.

**Después**
- Jubei: Estás lista. Yo distraigo a los de la puerta.

#### n22 · Gon
Rival: Gon · IA: difícil · Regla: el rival tiene un Dragón de más
**Antes**
- Gon: Vos otra vez. Ren no está para defenderte.
- Aya: No vine por él.
- Gon: Peor para vos.

**Después**
- Gon: ¿Por qué no me rematás?
- Aya: Porque no sos mi enemigo. Ninguno de ustedes lo es.

#### n23 · Las puertas de la biblioteca
Rival: monjes de élite · IA: difícil · Regla: el Asedio empieza en la ronda 15
**Antes**
- Mei: Te dejé ir una vez.
- Aya: Y ahora no.
- Mei: Ahora no puedo. El Abad está adentro.

**Después**
- Mei *(apartándose)*: …Que lo lea alguien. Por fin.

#### n24 · JEFE — Abad Hōshin
Rival: el Abad · IA: maestro (jefe final) · Regla: normal
**Antes**
- *La biblioteca. El Pergamino de Jade sobre el altar.*
- Abad: En cuarenta años nadie me ganó.
- Aya: Siempre hay una primera vez.
- Abad: Si me ganás, leelo. Y vas a entender por qué callé.

**Después**
- Narración: Aya desenrolla el Pergamino de Jade.
- Aya *(leyendo)*: "Seis piedras alrededor. Una mano del Templo, una mano de la Sombra. Si falta una, el sello no cierra."
- Aya: …No es un arma. Es un ritual. Y necesita a los dos.
- Abad: Lo sé. Por eso nunca lo dije. Prefería romperme solo que pedirle ayuda al clan.
- Narración: El suelo se abre bajo el patio. Una columna de ceniza sube al cielo.
- Aya: Tengo el Pergamino. Pero sola no sirve.
- **→ Fin de la campaña Ninja**
- *Tarjeta:* Hay otra mitad de esta historia. Terminá **El camino del Templo** para descubrir el verdadero final.

---

## 6. El Sello — el verdadero final

*Se abre con las dos campañas terminadas. Prólogo antes de F1:*
- *La misma noche. La pagoda y la biblioteca.*
- Narración: Ren venció a Kage. Aya venció al Abad. A la misma hora.
- Narración: Bajo el Templo, la última piedra se parte.
- Oni: **Por fin. Peleándose, como siempre.**

#### f1 · La vanguardia de ceniza
Ren solo, con fichas Shaolin, contra el Oni · IA: difícil · Regla: el Oni tiene sus fichas propias (Gaki y Ojo del Oni)
**Antes**
- *El patio del Templo, en llamas grises.*
- Ren: ¡Maestro Tao! ¿Qué es eso?
- Tao: Lo que tu Abad no quiso contarte. Rodealo, chico. ¡Ahora!

**Después**
- Narración: El Oni retrocede a la grieta. Pero no se cierra.
- Zorra Blanca: Rodearlo lo detiene. **No lo sella.**

#### f2 · La garra
Aya sola, con fichas Ninja, contra el Oni · IA: difícil · Regla: igual que f1
**Antes**
- *El jardín de piedra, partido en dos.*
- Aya: ¡Kuro! ¡Ayudame!
- Kuro: ¡Esa cosa vino de abajo del Templo!
- Aya: Lo sé. Rodeemoslo.

**Después**
- Narración: El Oni vuelve a retroceder. Más grande.
- Zorra Blanca: Una mano sola no alcanza. Nunca alcanzó.
- *El patio. Ren y Aya, frente a frente.*
- Ren: Kage me dijo la mitad.
- Aya: El Pergamino dice la otra. Una mano del Templo y una de la Sombra.
- Ren: Entonces… juntos.
- Zorra Blanca *(tomando forma humana)*: Como Daishin y Kagerō. Yo era la promesa que se hicieron. Y me estaba apagando.

#### f3 · El Sello
Ren y Aya juntos: Monje y Shogun en la misma mano, fichas de las dos facciones · IA: maestro · Regla especial:
- Jugás con fichas Shaolin y Ninja a la vez, con los dos líderes: si rodean a cualquiera, perdés.
- Podés usar Meditación de Jade y Kawarimi; usar una recarga las dos.
- El Oni solo queda sellado si lo rodean fichas de **las dos facciones** (al menos una de cada una).

**Antes**
- Abad *(herido, llegando)*: Ren… perdoname.
- Kage *(llegando por el muro)*: Aya. Hacé lo que dice el Pergamino.
- Zorra Blanca: Seis piedras. Dos manos. Ahora.

**Después — Epílogo**
- Narración: Seis piedras se encienden de verde y de rojo. La grieta se cierra.
- Narración: El Oni se apaga como una brasa en la lluvia.
- *Una semana después.*
- Abad: El sello aguantará otros trescientos años.
- Kage: Si no volvemos a olvidarnos.
- Ren: Entonces no lo olvidemos.
- Aya: Un duelo por año. Templo contra clan. En el tablero.
- Narración: Y así empezaron los **duelos de honor**: monjes y ninjas, enfrentados para no olvidar cómo se rodea a un demonio.
- Zorra Blanca: Hasta la próxima grieta.
- **→ Fin. Desbloqueo:** marco y avatar especial del Oni.

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

La viñeta es un libro de tinta: una hoja alta con un solo cuadro grande, el escenario detrás y una cámara
que lo recorre. **Nada avanza solo**: cada toque es un golpe, y un sello rojo que late abajo avisa cuándo
tocar. Si el golpe todavía está entrando, el toque lo completa; mantener apretado lee de corrido.

- Cada momento (las líneas en *cursiva*) **da vuelta la página**: plano general del lugar, la cámara se
  aleja despacio y lo recorre antes de que nadie hable.
- Quien habla y no está en el cuadro entra por su lado (el protagonista, a la izquierda). Quien no habla
  queda en penumbra. Los globos salen sobre su cabeza, con su nombre en la solapa; quedan los dos últimos.
- La narración va en el cartel de arriba. Las ilustraciones (`art_*`) ocupan la hoja entera y la cámara
  pasa de un foco a otro.
- Lo ya visto se puede releer desde el **Pergamino** en la pantalla de campañas.

### Puesta en escena

Entre corchetes, separada por `·`. Una línea que es solo corchetes es un **golpe mudo**: la cámara se
mueve o alguien entra, y espera un toque. Junto a un nombre, acompaña esa línea; `entra` sin nombre es
quien habla.

| Indicación | Qué hace |
|---|---|
| `plano X,Y xZOOM lento` | La cámara va a ese punto del fondo (0..1); `lento` es un paneo largo |
| `entra QUIÉN izq\|der\|centro\|0..1 humo\|sombra\|corre\|ya` | Entra a escena (`ya`: sin animación) |
| `sale QUIÉN humo\|corre` · `vacía` | Se va uno · se van todos |
| `temblor` · `destello` · `humo` · `latido` | Efectos de un golpe |
| `oscuro` · `niebla` | Efectos que duran hasta la página siguiente |
| `onom CLAVE` | Onomatopeya grande (texto en `onom.CLAVE`) |
| `arte NOMBRE` · `lugar PLACE` · `página` | Ilustración a página completa · cambio de lugar · página nueva |

Ejemplo (s4, Después):

```
- [arte art_fox_cell · plano .82,.45 x1.2 · latido]
- Narración [plano .2,.5 x1.1 lento]: En la puerta de la celda hay una zorra blanca. Nadie la vio entrar.
- Zorra Blanca: Todavía no es momento de que lo sepa.
```

Para probar una escena suelta: `flutter run --dart-define=STORY=s4.post --dart-define=STORY_AT=12`.
