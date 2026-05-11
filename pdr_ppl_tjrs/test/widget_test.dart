import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdr_ppl_tjrs/main.dart';

void main() {
  testWidgets('el juego muestra opciones y actualiza la ronda', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const RockPaperScissorsApp());

    expect(find.text('PIEDRA, PAPEL O TIJERA'), findsWidgets);
    expect(find.byKey(const ValueKey('start-play')), findsOneWidget);
    expect(find.byKey(const ValueKey('start-exit')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('start-play')));
    await tester.pumpAndSettle();

    expect(find.text('JUGADOR'), findsWidgets);
    expect(find.text('EMPATE'), findsWidgets);
    expect(find.text('0  -  0'), findsWidgets);
    expect(find.byKey(const ValueKey('button-rock')), findsOneWidget);
    expect(find.byKey(const ValueKey('button-paper')), findsOneWidget);
    expect(find.byKey(const ValueKey('button-scissors')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('button-rock')));
    await tester.pumpAndSettle();

    expect(find.textContaining('PIEDRA, PAPEL'), findsNothing);
    expect(find.textContaining('MARCADOR'), findsWidgets);
  });

  testWidgets('la pantalla de ganador regresa al inicio', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: WinnerPage(playerWon: true, playerScore: 10, computerScore: 3),
      ),
    );

    expect(find.text('!FELICITACIONES!'), findsWidgets);
    expect(find.text('10  -  3'), findsWidgets);
    expect(find.byKey(const ValueKey('winner-home')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('winner-home')));
    await tester.pumpAndSettle();

    expect(find.text('PIEDRA, PAPEL O TIJERA'), findsWidgets);
    expect(find.byKey(const ValueKey('start-play')), findsOneWidget);
  });
}
