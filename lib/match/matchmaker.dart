import 'dart:async';
import 'dart:math';

import '../codex/avatars.dart';
import '../engine/ai.dart';
import '../engine/pieces.dart';
import 'ladder.dart';

/// Rival encontrado. [bot] es el nivel de IA que lo controla; null = humano
/// real (cuando exista el online).
class Opponent {
  final String nickname;
  final String avatar;
  final Faction faction;
  final int rating;
  final AiLevel? bot;

  const Opponent({required this.nickname, required this.avatar, required this.faction, required this.rating, this.bot});
}

class MatchFound {
  final Opponent opponent;
  final Faction yourFaction;

  /// Quién mueve primero (fichas claras).
  final bool youFirst;

  const MatchFound({required this.opponent, required this.yourFaction, required this.youFirst});
}

class MatchRequest {
  final String nickname;
  final Faction faction;
  final LadderRecord record;
  const MatchRequest({required this.nickname, required this.faction, required this.record});
}

/// Estado de la búsqueda que la pantalla va mostrando.
sealed class MatchmakingEvent {
  const MatchmakingEvent();
}

class Searching extends MatchmakingEvent {
  /// Rango de puntos que se está aceptando (se amplía con la espera).
  final int range;
  const Searching(this.range);
}

class Found extends MatchmakingEvent {
  final MatchFound match;
  const Found(this.match);
}

/// Contrato del emparejamiento. Hoy lo cumple [BotMatchmaker]; mañana un
/// servicio online que empareje personas reales, sin tocar la UI. Cancelar la
/// suscripción al stream cancela la búsqueda.
abstract class Matchmaker {
  Stream<MatchmakingEvent> search(MatchRequest request);
}

/// Simula una búsqueda online y devuelve un rival controlado por la IA, con
/// el nivel que corresponde al rendimiento del jugador.
class BotMatchmaker implements Matchmaker {
  final Random _rng;

  /// Escala de los tiempos de espera (0 en tests).
  final double waitScale;

  BotMatchmaker({int? seed, this.waitScale = 1}) : _rng = Random(seed);

  @override
  Stream<MatchmakingEvent> search(MatchRequest request) async* {
    // Espera total de 2,5 a 7 s, en pasos de 1 s; después de 2,5 s se acepta
    // un rango de puntos cada vez más amplio, como haría un servidor real.
    final seconds = 2.5 + _rng.nextDouble() * 4.5;
    var range = 50;
    yield Searching(range);
    for (var t = 1.0; t < seconds; t++) {
      await Future<void>.delayed(Duration(milliseconds: (1000 * waitScale).round()));
      if (t >= 2.5) range = min(range + 50, 250);
      yield Searching(range);
    }
    await Future<void>.delayed(Duration(milliseconds: (1000 * (seconds % 1) * waitScale).round()));
    yield Found(pickMatch(request));
  }

  /// Arma el rival: nivel según la racha/puntos (con un poco de variación,
  /// como en un emparejamiento real), puntos cercanos a los del jugador.
  MatchFound pickMatch(MatchRequest request) {
    final record = request.record;
    var levelIdx = record.targetLevel.index;
    final roll = _rng.nextDouble();
    if (roll < 0.1) levelIdx--;
    if (roll > 0.9) levelIdx++;
    final level = AiLevel.values[levelIdx.clamp(0, AiLevel.values.length - 1)];

    // Puntos del rival: cerca de los tuyos, pero dentro de la franja de su nivel.
    final band = Rank.values[level.index];
    final bandMax = level.index + 1 < Rank.values.length ? Rank.values[level.index + 1].minRating - 1 : 1600;
    final bandMin = max(band.minRating, LadderRecord.minRating);
    final rating = (record.rating + _rng.nextInt(81) - 40).clamp(bandMin, bandMax);

    final faction = playableFactions[_rng.nextInt(playableFactions.length)];
    final avatars = Avatars.of(faction);
    return MatchFound(
      opponent: Opponent(
        nickname: botName(_rng),
        avatar: avatars[_rng.nextInt(avatars.length)].id,
        faction: faction,
        rating: rating,
        bot: level,
      ),
      yourFaction: request.faction,
      youFirst: _rng.nextBool(),
    );
  }
}

const _first = [
  'Kenji',
  'Sakura',
  'Lobo',
  'Hiro',
  'Yuki',
  'Nube',
  'Tora',
  'Rin',
  'Kaze',
  'Luna',
  'Ryu',
  'Sombra', //
  'Akira',
  'Mei',
  'Jade',
  'Taro',
  'Zen',
  'Koi',
  'Bruma',
  'Hana',
  'Daichi',
  'Saya',
  'Fénix',
  'Kumo',
];
const _second = [
  'Azul',
  'Veloz',
  'Rojo',
  'Sabio',
  'Feroz',
  'Gris',
  'Dorado',
  'Oscuro',
  'Calmo',
  'Silente', //
  'Nocturno', 'Errante', 'Valiente', 'Lunar', 'Sereno',
];
const _single = [
  'monje_ninja',
  'hexmaster',
  'rodeador',
  'colmena_zen',
  'el_shogun',
  'tigre_tranqui',
  'grulla99', //
  'kunoichi_ar', 'dojo_sur', 'shinobi_uy', 'pandakid', 'mate_y_hex',
];

/// Nick con pinta de jugador real: combinaciones, apodos y algún número.
String botName(Random rng) {
  final roll = rng.nextDouble();
  if (roll < 0.25) return _single[rng.nextInt(_single.length)];
  final base = '${_first[rng.nextInt(_first.length)]}${_second[rng.nextInt(_second.length)]}';
  if (roll < 0.6) return base;
  return '$base${rng.nextInt(99) + 1}';
}
