import '../i18n/i18n.dart';
import 'hex.dart';
import 'pieces.dart';

/// Algo que pasó en el tablero durante una acción. Solo se generan si
/// [GameState.recordEvents] está activo (la IA no los necesita).
sealed class GameEvent {
  /// Jugador que hizo la acción.
  final int player;
  const GameEvent(this.player);

  /// Casillas involucradas (para resaltar la jugada).
  Set<Hex> get cells;

  /// Descripción corta desde el punto de vista de quien jugó.
  String get text;

  /// Efecto que conviene avisar aparte (no es una simple colocación o movimiento).
  bool get notable => true;
}

String _whose(Piece p, int player) => tr(p.owner == player ? 'event.own' : 'event.rival');

/// Efecto especial que una Serpiente anuló.
enum CancelledEffect { push, paralyze, seal }

class PiecePlaced extends GameEvent {
  final Piece piece;
  final Hex at;
  const PiecePlaced(super.player, this.piece, this.at);
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => tr('event.placed', {'piece': piece.type.displayName});
  @override
  bool get notable => false;
}

class Moved extends GameEvent {
  final Piece piece;
  final Hex from, to;

  /// Terminó encima de otra ficha (Rey Mono).
  final bool climbed;
  const Moved(super.player, this.piece, this.from, this.to, {this.climbed = false});
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => tr(climbed ? 'event.climbed' : 'event.moved', {'piece': piece.type.displayName});
  @override
  bool get notable => climbed;
}

class Pushed extends GameEvent {
  final Piece piece;
  final Hex from, to;
  const Pushed(super.player, this.piece, this.from, this.to);
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => tr('event.pushed', {'piece': piece.type.displayName});
}

class Paralyzed extends GameEvent {
  final Piece piece;
  final Hex at;

  /// Pisó un Sello de Sombra (si no, fue la Kunoichi).
  final bool bySeal;
  const Paralyzed(super.player, this.piece, this.at, {this.bySeal = false});
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => tr(bySeal ? 'event.paralyzedSeal' : 'event.paralyzed', {'piece': piece.type.displayName});
}

class SealPlaced extends GameEvent {
  final Hex at;
  const SealPlaced(super.player, this.at);
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => tr('event.sealPlaced');
}

class Cancelled extends GameEvent {
  final Piece piece;
  final Hex at;
  final CancelledEffect effect;
  const Cancelled(super.player, this.piece, this.at, this.effect);
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => switch (effect) {
    CancelledEffect.push => tr('event.cancelPush'),
    CancelledEffect.paralyze => tr('event.cancelParalyze'),
    CancelledEffect.seal => tr('event.cancelSeal'),
  };
}

class ShogunSwapped extends GameEvent {
  final Hex from, to;
  const ShogunSwapped(super.player, this.from, this.to);
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => tr('event.shogunSwap');
}

class JadeRelocated extends GameEvent {
  final Piece piece;
  final Hex from, to;
  const JadeRelocated(super.player, this.piece, this.from, this.to);
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => tr('event.jadeRelocated', {'piece': piece.type.displayName, 'whose': _whose(piece, player)});
}

class JadeSwapped extends GameEvent {
  final Piece a, b;
  final Hex at, bt;
  const JadeSwapped(super.player, this.a, this.b, this.at, this.bt);
  @override
  Set<Hex> get cells => {at, bt};
  @override
  String get text => tr('event.jadeSwapped', {'a': a.type.displayName, 'b': b.type.displayName});
}

class Returned extends GameEvent {
  final Piece piece;
  final Hex from;
  const Returned(super.player, this.piece, this.from);
  @override
  Set<Hex> get cells => {from};
  @override
  String get text => tr('event.returned', {'piece': piece.type.displayName, 'whose': _whose(piece, player)});
}

class Passed extends GameEvent {
  const Passed(super.player);
  @override
  Set<Hex> get cells => const {};
  @override
  String get text => tr('event.passed');
}
