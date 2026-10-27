import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexiege/i18n/i18n.dart';
import 'package:hexiege/story/credits_screen.dart';

void main() {
  testWidgets('créditos: un toque salta al gancho y otro, al final, cierra', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(onPressed: () => showCredits(context), child: const Text('go')),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(tr('credits.sealed')), findsOneWidget);

    await tester.tapAt(const Offset(200, 300));
    for (var i = 0; i < 9; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text(tr('credits.tbc')), findsOneWidget);
    expect(find.text(tr('credits.next')), findsOneWidget);

    await tester.tapAt(const Offset(200, 300));
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
    expect(find.byType(CreditsScreen), findsNothing);
  });
}
