import 'package:flutter/foundation.dart';

/// Partidas por puntos contra otros jugadores. Apagadas hasta que exista el
/// emparejamiento online real: hoy el rival sería la IA presentada como persona.
/// Con esto en false el menú muestra la opción deshabilitada y oculta el rango.
const kOnlineMatches = false;

/// Compra de la historia simulada: "Desbloquear" la abre al instante sin pasar
/// por la tienda. En false se compra de verdad (`hexiege_story` tiene que existir
/// en App Store Connect; en TestFlight se paga con la cuenta de sandbox).
const kSimulatedPurchase = false;

/// "Reiniciar historia" en el menú: solo para probar (debug o compra simulada).
const kStoryResetButton = kSimulatedPurchase || kDebugMode;
