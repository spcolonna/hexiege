import 'dart:math';

import '../engine/board.dart';
import '../engine/game_state.dart';
import '../engine/hex.dart';
import '../engine/moves.dart';
import '../engine/pieces.dart';

/// Posición de ejemplo del códice: la ficha [subject] (siempre del jugador 0,
/// de su propia facción) rodeada de otras para que se vea cómo se mueve.
class CodexScene {
  final PieceType type;
  final GameState game;
  final Hex subject;

  /// Casillas a las que puede ir con su movimiento normal.
  final Set<Hex> targets;

  /// Shinobis con los que puede intercambiarse (solo el Shogun).
  final Set<Hex> swapTargets;

  /// Fichas enemigas que empuja el Tigre según adónde vaya: destino → (desde, hasta).
  final Map<Hex, ({Hex target, Hex dest})> pushes;

  CodexScene._(this.type, this.game, this.subject, this.targets, this.swapTargets, this.pushes);

  /// La misma posición sin la ficha que se mueve (para dibujarla aparte, animada).
  GameState get lifted {
    final g = game.copy();
    g.board.pop(subject);
    return g;
  }

  /// Fondo estático: sin la ficha estudiada ni las que pueden ser empujadas.
  GameState get backdrop {
    final g = lifted;
    for (final p in pushes.values) {
      if (g.board.isOccupied(p.target)) g.board.pop(p.target);
    }
    return g;
  }

  /// Destinos en orden de recorrido (en sentido horario alrededor del centro).
  List<Hex> get tour {
    final list = targets.toList();
    double angle(Hex h) => atan2((h.r - subject.r) * 0.866, (h.q + h.r / 2) - (subject.q + subject.r / 2));
    list.sort((a, b) => angle(a).compareTo(angle(b)));
    return list;
  }

  static CodexScene of(PieceType type) {
    final (subject, pieces, extra) = _layout(type);
    final f = type.faction;
    final game = GameState(f, f == Faction.shaolin ? Faction.ninja : Faction.shaolin);
    for (final (owner, t, at) in pieces) {
      game.hands[owner][t] = (game.hands[owner][t] ?? 0) + 1; // los ejemplos no gastan la mano
      game.setupPut(owner, t, at);
    }
    extra?.call(game);
    // Los destinos salen de las reglas reales de la partida (One-Hive incluida),
    // así el códice nunca muestra un movimiento que en juego no se puede hacer.
    final oni = type.faction == Faction.oni;
    final targets = oni
        ? destinationsFor(type, Board.copy(game.board)..pop(subject), subject, game.rules)
        : game.moveTargets(subject);
    final swaps = type == PieceType.shogun
        ? subject.neighbors.where((n) => game.board.top(n)?.type == PieceType.shinobi).toSet()
        : <Hex>{};
    final pushes = <Hex, ({Hex target, Hex dest})>{};
    if (type == PieceType.tiger) {
      for (final to in targets) {
        final push = game.tigerPushPreview(subject, to);
        if (push != null) pushes[to] = push;
      }
    }
    return CodexScene._(type, game, subject, targets, swaps, pushes);
  }

  /// (ficha estudiada, todas las fichas incluida ella, ajustes extra).
  static (Hex, List<(int, PieceType, Hex)>, void Function(GameState)?) _layout(PieceType type) {
    const s = Hex(-1, 0);
    switch (type) {
      // Las fichas del Oni no están en el códice; escena mínima por completitud.
      case PieceType.oni || PieceType.gaki || PieceType.oniEye:
        return (const Hex(0, 0), [(0, type, const Hex(0, 0)), (1, PieceType.shogun, const Hex(1, 0))], null);
      case PieceType.monk:
        return (
          const Hex(0, 0),
          const [
            (0, PieceType.monk, Hex(0, 0)),
            (1, PieceType.shogun, Hex(1, 0)),
            (1, PieceType.kitsune, Hex(1, -1)),
            (0, PieceType.serpent, Hex(-1, 1)),
            // La Grulla une los dos lados: sin ella el Monje sería el único puente.
            (0, PieceType.crane, Hex(0, 1)),
          ],
          null,
        );
      case PieceType.dragon:
        return (
          const Hex(-2, 0),
          const [
            (0, PieceType.dragon, Hex(-2, 0)),
            (0, PieceType.monk, Hex(-1, 0)),
            (1, PieceType.shinobi, Hex(0, 0)),
            (1, PieceType.shogun, Hex(1, 0)),
            (0, PieceType.serpent, Hex(-2, 1)),
          ],
          null,
        );
      case PieceType.wukong:
        return (
          const Hex(0, 0),
          const [
            (0, PieceType.wukong, Hex(0, 0)),
            (0, PieceType.dragon, Hex(1, 0)),
            (1, PieceType.shinobi, Hex(2, 0)),
            (0, PieceType.monk, Hex(-1, 0)),
            (1, PieceType.shogun, Hex(0, 1)),
            (0, PieceType.serpent, Hex(-1, 1)),
          ],
          null,
        );
      case PieceType.tiger:
        return (
          s,
          const [
            // Al cargar hasta (1,0) queda mirando a la Kitsune y la empuja.
            (0, PieceType.tiger, s),
            (0, PieceType.monk, Hex(-1, 1)),
            (0, PieceType.crane, Hex(0, 1)),
            (0, PieceType.serpent, Hex(1, 1)),
            (1, PieceType.kitsune, Hex(2, 0)),
            (1, PieceType.shogun, Hex(2, 1)),
          ],
          null,
        );
      case PieceType.crane:
        return (
          s,
          const [
            (0, PieceType.crane, s),
            (0, PieceType.monk, Hex(0, 0)),
            (1, PieceType.shogun, Hex(1, 0)),
            (0, PieceType.serpent, Hex(-1, 1)),
          ],
          null,
        );
      case PieceType.serpent:
        return (
          s,
          const [
            (0, PieceType.serpent, s),
            (0, PieceType.monk, Hex(0, 0)),
            (1, PieceType.kunoichi, Hex(0, -1)),
            (1, PieceType.shogun, Hex(1, 0)),
          ],
          null,
        );
      case PieceType.shogun:
        return (
          const Hex(0, 0),
          const [
            (0, PieceType.shogun, Hex(0, 0)),
            (0, PieceType.shinobi, Hex(1, 0)),
            (1, PieceType.tiger, Hex(2, -1)),
            (1, PieceType.monk, Hex(-1, 1)),
            (0, PieceType.kitsune, Hex(0, 1)),
          ],
          null,
        );
      case PieceType.shinobi:
        // Un hueco cerrado por una "puerta" (1,0): solo el Shinobi se cuela.
        return (
          const Hex(2, 1),
          const [
            (0, PieceType.shinobi, Hex(2, 1)),
            (0, PieceType.shogun, Hex(0, 0)),
            (1, PieceType.monk, Hex(1, -1)),
            (1, PieceType.tiger, Hex(2, -1)),
            (1, PieceType.serpent, Hex(0, 1)),
            (0, PieceType.kitsune, Hex(1, 1)),
          ],
          null,
        );
      case PieceType.kunoichi:
        return (
          s,
          const [
            (0, PieceType.kunoichi, s),
            (0, PieceType.shogun, Hex(0, 0)),
            (1, PieceType.monk, Hex(1, 0)),
            (1, PieceType.dragon, Hex(0, 1)),
          ],
          (g) {
            // Muestra el efecto: la ficha enemiga de al lado queda paralizada.
            final p = g.board.top(const Hex(0, 1))!;
            g.paralyzedUntil[p.id] = 1 << 20;
          },
        );
      case PieceType.tengu:
        return (
          const Hex(-2, 1),
          const [
            (0, PieceType.tengu, Hex(-2, 1)),
            (0, PieceType.shogun, Hex(0, 0)),
            (1, PieceType.monk, Hex(1, 0)),
            (1, PieceType.dragon, Hex(1, -1)),
            (0, PieceType.kitsune, Hex(-1, 0)),
            (1, PieceType.serpent, Hex(0, 1)),
            (1, PieceType.crane, Hex(2, -1)),
          ],
          null,
        );
      case PieceType.kitsune:
        return (
          s,
          const [
            (0, PieceType.kitsune, s),
            (0, PieceType.shogun, Hex(0, 0)),
            (1, PieceType.monk, Hex(1, 0)),
            (1, PieceType.serpent, Hex(0, 1)),
          ],
          null,
        );
      case PieceType.shadow:
        return (
          s,
          const [(0, PieceType.shadow, s), (0, PieceType.shogun, Hex(0, 0)), (1, PieceType.monk, Hex(1, 0))],
          (g) => g.seals[const Hex(0, 1)] = 0,
        );
    }
  }
}
