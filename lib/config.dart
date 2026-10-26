/// Partidas por puntos contra otros jugadores. Apagadas hasta que exista el
/// emparejamiento online real: hoy el rival sería la IA presentada como persona.
/// Con esto en false el menú muestra la opción deshabilitada y oculta el rango.
const kOnlineMatches = false;

/// Compra de la historia simulada: "Desbloquear" la abre al instante sin pasar
/// por la tienda. En false se compra de verdad (`hexiege_story` tiene que existir
/// en App Store Connect; en TestFlight se paga con la cuenta de sandbox).
const kSimulatedPurchase = false;

/// "Reiniciar historia" en el menú. Visible mientras se prueba la historia;
/// apagar antes de publicar.
const kStoryResetButton = true;

/// Política de privacidad publicada (la misma que figura en las tiendas).
const kPrivacyUrl = 'https://spcolonna.github.io/hexiege/privacidad.html';

/// Reporte de errores (Sentry). Vacío = apagado. El DSN no es secreto: viaja
/// dentro de la app. Se copia de sentry.io → Project Settings → Client Keys.
const kSentryDsn = '';

/// Play Juegos en Android. Apagado hasta crear el juego en Play Console y poner
/// su id en android/app/src/main/res/values/games.xml (sin eso, el inicio de
/// sesión falla). En iOS Game Center va siempre.
const kPlayGames = false;

/// Enlace que acompaña el resultado compartido del desafío. Vacío = sin enlace
/// (completar con la página de la App Store cuando esté publicada).
const kShareUrl = '';
