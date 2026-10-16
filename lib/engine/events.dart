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

String _whose(Piece p, int player) => p.owner == player ? '(propia)' : '(rival)';

/// Efecto especial que una Serpiente anuló.
enum CancelledEffect { push, paralyze, seal }

class PiecePlaced extends GameEvent {
  final Piece piece;
  final Hex at;
  const PiecePlaced(super.player, this.piece, this.at);
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => 'Colocó ${piece.type.displayName}';
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
  String get text =>
      climbed ? '${piece.type.displayName} se subió a una ficha y la bloquea' : 'Movió ${piece.type.displayName}';
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
  String get text => 'El Tigre empujó a ${piece.type.displayName}';
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
  String get text => bySeal
      ? '${piece.type.displayName} pisó un Sello de Sombra: paralizada 1 turno'
      : 'La Kunoichi paralizó a ${piece.type.displayName} por 1 turno';
}

class SealPlaced extends GameEvent {
  final Hex at;
  const SealPlaced(super.player, this.at);
  @override
  Set<Hex> get cells => {at};
  @override
  String get text => 'La Sombra Errante dejó un Sello de Sombra';
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
    CancelledEffect.push => 'La Serpiente de Jade anuló el empuje del Tigre',
    CancelledEffect.paralyze => 'La Serpiente de Jade anuló la parálisis de la Kunoichi',
    CancelledEffect.seal => 'La Serpiente de Jade impidió el Sello de Sombra',
  };
}

class ShogunSwapped extends GameEvent {
  final Hex from, to;
  const ShogunSwapped(super.player, this.from, this.to);
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => 'El Gran Shogun cambió de lugar con un Shinobi (1 vez por partida)';
}

class JadeRelocated extends GameEvent {
  final Piece piece;
  final Hex from, to;
  const JadeRelocated(super.player, this.piece, this.from, this.to);
  @override
  Set<Hex> get cells => {from, to};
  @override
  String get text => 'Meditación de Jade: reubicó ${piece.type.displayName} ${_whose(piece, player)}';
}

class JadeSwapped extends GameEvent {
  final Piece a, b;
  final Hex at, bt;
  const JadeSwapped(super.player, this.a, this.b, this.at, this.bt);
  @override
  Set<Hex> get cells => {at, bt};
  @override
  String get text => 'Meditación de Jade: intercambió ${a.type.displayName} y ${b.type.displayName}';
}

class Returned extends GameEvent {
  final Piece piece;
  final Hex from;
  const Returned(super.player, this.piece, this.from);
  @override
  Set<Hex> get cells => {from};
  @override
  String get text => 'Kawarimi: ${piece.type.displayName} ${_whose(piece, player)} vuelve a la mano de su dueño';
}

class Passed extends GameEvent {
  const Passed(super.player);
  @override
  Set<Hex> get cells => const {};
  @override
  String get text => 'Sin jugadas posibles: pasó el turno';
}
