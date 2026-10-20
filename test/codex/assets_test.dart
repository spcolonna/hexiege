import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/codex/avatars.dart';
import 'package:hexiege/codex/cosmetics.dart';
import 'package:hexiege/engine/pieces.dart';
import 'package:hexiege/ui/widgets/emotes.dart';

void main() {
  void exists(String path) => expect(File(path).existsSync(), isTrue, reason: path);

  test('cada avatar del catálogo tiene su retrato', () {
    for (final a in Avatars.all) {
      exists(a.asset);
    }
  });

  test('cada emote tiene su dibujo para las dos facciones', () {
    for (final f in playableFactions) {
      for (final e in Emote.values) {
        exists(EmoteGlyph.asset(e, f));
      }
    }
  });

  test('marcos, piedras y tapetes tienen su imagen', () {
    for (final f in Cosmetics.frames) {
      exists(f.asset);
    }
    for (final s in Cosmetics.stones) {
      exists(s.asset);
    }
    for (final t in Cosmetics.tables) {
      exists(t.asset);
    }
  });
}
