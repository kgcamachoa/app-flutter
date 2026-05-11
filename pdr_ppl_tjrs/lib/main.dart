import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const RockPaperScissorsApp());
}

class RockPaperScissorsApp extends StatelessWidget {
  const RockPaperScissorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piedra, Papel o Tijera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16B7D1)),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

enum Move {
  rock('Piedra'),
  paper('Papel'),
  scissors('Tijera');

  const Move(this.label);

  final String label;
}

enum RoundResult { player, computer, tie }

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  Move _playerMove = Move.paper;
  Move _computerMove = Move.rock;
  int _playerScore = 0;
  int _computerScore = 0;
  RoundResult _lastResult = RoundResult.tie;

  void _play(Move playerMove) {
    final computerMove = Move.values[_random.nextInt(Move.values.length)];
    final result = _winner(playerMove, computerMove);

    setState(() {
      _playerMove = playerMove;
      _computerMove = computerMove;
      _lastResult = result;
      if (result == RoundResult.player) {
        _playerScore++;
      } else if (result == RoundResult.computer) {
        _computerScore++;
      }
    });
  }

  RoundResult _winner(Move player, Move computer) {
    if (player == computer) {
      return RoundResult.tie;
    }

    final playerWins =
        player == Move.rock && computer == Move.scissors ||
        player == Move.scissors && computer == Move.paper ||
        player == Move.paper && computer == Move.rock;

    return playerWins ? RoundResult.player : RoundResult.computer;
  }

  String get _statusText {
    return switch (_lastResult) {
      RoundResult.player => 'Ganaste la ronda',
      RoundResult.computer => 'Gana la computadora',
      RoundResult.tie => 'Empate',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED0F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 820;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 34,
                    vertical: isCompact ? 20 : 26,
                  ),
                  child: isCompact
                      ? _CompactGameView(
                          playerMove: _playerMove,
                          computerMove: _computerMove,
                          playerScore: _playerScore,
                          computerScore: _computerScore,
                          statusText: _statusText,
                          onPlay: _play,
                        )
                      : _WideGameView(
                          playerMove: _playerMove,
                          computerMove: _computerMove,
                          playerScore: _playerScore,
                          computerScore: _computerScore,
                          statusText: _statusText,
                          onPlay: _play,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WideGameView extends StatelessWidget {
  const _WideGameView({
    required this.playerMove,
    required this.computerMove,
    required this.playerScore,
    required this.computerScore,
    required this.statusText,
    required this.onPlay,
  });

  final Move playerMove;
  final Move computerMove;
  final int playerScore;
  final int computerScore;
  final String statusText;
  final ValueChanged<Move> onPlay;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PlayerSide(selectedMove: playerMove, onPlay: onPlay),
          ),
          const SizedBox(width: 22),
          const SizedBox(width: 22, child: _DottedDivider()),
          const SizedBox(width: 22),
          Expanded(
            child: _ComputerSide(
              selectedMove: computerMove,
              playerScore: playerScore,
              computerScore: computerScore,
              statusText: statusText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactGameView extends StatelessWidget {
  const _CompactGameView({
    required this.playerMove,
    required this.computerMove,
    required this.playerScore,
    required this.computerScore,
    required this.statusText,
    required this.onPlay,
  });

  final Move playerMove;
  final Move computerMove;
  final int playerScore;
  final int computerScore;
  final String statusText;
  final ValueChanged<Move> onPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PlayerSide(selectedMove: playerMove, onPlay: onPlay),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(height: 22, child: _HorizontalDottedDivider()),
        ),
        _ComputerSide(
          selectedMove: computerMove,
          playerScore: playerScore,
          computerScore: computerScore,
          statusText: statusText,
        ),
      ],
    );
  }
}

class _PlayerSide extends StatelessWidget {
  const _PlayerSide({required this.selectedMove, required this.onPlay});

  final Move selectedMove;
  final ValueChanged<Move> onPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DownArrow(size: 78),
        const _NeonText('JUGADOR', fontSize: 48),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AspectRatio(
            aspectRatio: 1.06,
            child: _SelectionStage(move: selectedMove, large: true),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 18,
          children: Move.values.map((move) {
            return _MoveButton(
              key: ValueKey('button-${move.name}'),
              move: move,
              selected: selectedMove == move,
              onPressed: () => onPlay(move),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ComputerSide extends StatelessWidget {
  const _ComputerSide({
    required this.selectedMove,
    required this.playerScore,
    required this.computerScore,
    required this.statusText,
  });

  final Move selectedMove;
  final int playerScore;
  final int computerScore;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28),
        const _NeonText('PIEDRA, PAPEL\nO TIJERA', fontSize: 46),
        const SizedBox(height: 34),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AspectRatio(
            aspectRatio: 1.06,
            child: _SelectionStage(move: selectedMove, large: true),
          ),
        ),
        const SizedBox(height: 28),
        _ScoreBoard(
          playerScore: playerScore,
          computerScore: computerScore,
          statusText: statusText,
        ),
      ],
    );
  }
}

class _SelectionStage extends StatelessWidget {
  const _SelectionStage({required this.move, this.large = false});

  final Move move;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WatercolorBackgroundPainter(),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: large ? 0.82 : 0.72,
          heightFactor: large ? 0.82 : 0.72,
          child: CustomPaint(painter: _MovePainter(move)),
        ),
      ),
    );
  }
}

class _MoveButton extends StatefulWidget {
  const _MoveButton({
    super.key,
    required this.move,
    required this.selected,
    required this.onPressed,
  });

  final Move move;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_MoveButton> createState() => _MoveButtonState();
}

class _MoveButtonState extends State<_MoveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.move.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered || widget.selected ? 1.04 : 1,
          duration: const Duration(milliseconds: 150),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: SizedBox(
              width: 194,
              height: 146,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 14,
                    right: 10,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D60C6),
                        border: Border.all(color: Colors.black, width: 2.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: 10,
                    bottom: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FE),
                        border: Border.all(color: Colors.black, width: 2.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _WindowBar(active: widget.selected),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomPaint(
                                      painter: _MovePainter(widget.move),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const _FakeScrollBar(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowBar extends StatelessWidget {
  const _WindowBar({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF78A9DF) : const Color(0xFF8BB3DF),
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2.5),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          _WindowIcon(symbol: '-'),
          SizedBox(width: 4),
          _WindowIcon(symbol: '□'),
          SizedBox(width: 4),
          _WindowIcon(symbol: '×'),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _WindowIcon extends StatelessWidget {
  const _WindowIcon({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        border: Border.all(color: Colors.black, width: 1.7),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        symbol,
        style: const TextStyle(
          fontSize: 12,
          height: 0.8,
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FakeScrollBar extends StatelessWidget {
  const _FakeScrollBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: CustomPaint(painter: _ScrollBarPainter()),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({
    required this.playerScore,
    required this.computerScore,
    required this.statusText,
  });

  final int playerScore;
  final int computerScore;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DownArrow(size: 60),
        const SizedBox(height: 4),
        _NeonText('$playerScore  -  $computerScore', fontSize: 42),
        const SizedBox(height: 8),
        const _NeonText('MARCADOR', fontSize: 42),
        const SizedBox(height: 10),
        Text(
          statusText,
          key: const ValueKey('round-status'),
          style: const TextStyle(
            color: Color(0xFF13649C),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _NeonText extends StatelessWidget {
  const _NeonText(this.text, {required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            height: 0.95,
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = const Color(0xFFFF00C8),
          ),
        ),
        Transform.translate(
          offset: const Offset(3, 3),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              height: 0.95,
              letterSpacing: 0,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = const Color(0xFF00C9D8),
            ),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF92D7FF),
            fontSize: fontSize,
            height: 0.95,
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DownArrow extends StatelessWidget {
  const _DownArrow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ArrowPainter()),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DottedDividerPainter(vertical: true));
  }
}

class _HorizontalDottedDivider extends StatelessWidget {
  const _HorizontalDottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DottedDividerPainter(vertical: false));
  }
}

class _WatercolorBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFB7D9F7),
    );

    final circles = [
      (const Offset(0.03, 0.10), 0.24, const Color(0x6680C7C4)),
      (const Offset(0.28, 0.03), 0.18, const Color(0x554BA3B8)),
      (const Offset(0.88, 0.08), 0.22, const Color(0x664A95A8)),
      (const Offset(0.12, 0.84), 0.18, const Color(0x5580BCA9)),
      (const Offset(0.76, 0.92), 0.16, const Color(0x557DBBA9)),
    ];

    for (final circle in circles) {
      canvas.drawCircle(
        Offset(size.width * circle.$1.dx, size.height * circle.$1.dy),
        size.shortestSide * circle.$2,
        Paint()
          ..color = circle.$3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MovePainter extends CustomPainter {
  const _MovePainter(this.move);

  final Move move;

  @override
  void paint(Canvas canvas, Size size) {
    switch (move) {
      case Move.rock:
        _paintRock(canvas, size);
      case Move.paper:
        _paintPaper(canvas, size);
      case Move.scissors:
        _paintScissors(canvas, size);
    }
  }

  void _paintRock(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.58)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.28,
        size.width * 0.36,
        size.height * 0.12,
        size.width * 0.58,
        size.height * 0.16,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.18,
        size.width * 0.92,
        size.height * 0.42,
        size.width * 0.86,
        size.height * 0.67,
      )
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.88,
        size.width * 0.35,
        size.height * 0.90,
        size.width * 0.17,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFBBA980));
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBD9AE), Color(0xFF6E6959)],
        ).createShader(Offset.zero & size),
    );

    final stroke = Paint()
      ..color = const Color(0x8A4C4638)
      ..strokeWidth = size.shortestSide * 0.028
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lines = [
      [
        const Offset(0.22, 0.56),
        const Offset(0.46, 0.28),
        const Offset(0.70, 0.34),
      ],
      [
        const Offset(0.30, 0.75),
        const Offset(0.55, 0.47),
        const Offset(0.82, 0.55),
      ],
      [
        const Offset(0.44, 0.20),
        const Offset(0.38, 0.58),
        const Offset(0.55, 0.86),
      ],
      [
        const Offset(0.62, 0.23),
        const Offset(0.70, 0.50),
        const Offset(0.65, 0.78),
      ],
    ];

    for (final line in lines) {
      final linePath = Path()
        ..moveTo(size.width * line[0].dx, size.height * line[0].dy)
        ..quadraticBezierTo(
          size.width * line[1].dx,
          size.height * line[1].dy,
          size.width * line[2].dx,
          size.height * line[2].dy,
        );
      canvas.drawPath(linePath, stroke);
    }
  }

  void _paintPaper(Canvas canvas, Size size) {
    final paper = Path()
      ..moveTo(size.width * 0.20, size.height * 0.06)
      ..lineTo(size.width * 0.86, size.height * 0.08)
      ..lineTo(size.width * 0.88, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.90,
        size.width * 0.48,
        size.height * 0.87,
      )
      ..lineTo(size.width * 0.22, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.48,
        size.width * 0.20,
        size.height * 0.06,
      )
      ..close();

    canvas.drawPath(paper, Paint()..color = const Color(0xF5FFFFFF));

    final grid = Paint()
      ..color = const Color(0x8895BECC)
      ..strokeWidth = max(1.0, size.shortestSide * 0.008);

    for (double x = 0.28; x < 0.82; x += 0.09) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.12),
        Offset(size.width * (x - 0.02), size.height * 0.82),
        grid,
      );
    }
    for (double y = 0.18; y < 0.78; y += 0.09) {
      canvas.drawLine(
        Offset(size.width * 0.22, size.height * y),
        Offset(size.width * 0.83, size.height * (y + 0.02)),
        grid,
      );
    }

    final holePaint = Paint()..color = const Color(0x88B7BAB9);
    for (double y = 0.18; y < 0.62; y += 0.12) {
      canvas.drawCircle(
        Offset(size.width * 0.23, size.height * y),
        size.shortestSide * 0.035,
        holePaint,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.20, size.height * y),
          radius: size.shortestSide * 0.055,
        ),
        -pi / 2,
        pi,
        false,
        Paint()
          ..color = const Color(0x887C8384)
          ..strokeWidth = size.shortestSide * 0.015
          ..style = PaintingStyle.stroke,
      );
    }

    canvas.drawPath(
      paper,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.045,
    );
  }

  void _paintScissors(Canvas canvas, Size size) {
    final bladePaint = Paint()..color = const Color(0xFFB8BDCB);
    final darkBlade = Paint()..color = const Color(0xFF9EA4B3);
    final handle = Paint()
      ..color = const Color(0xFF252631)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.09
      ..strokeCap = StrokeCap.round;

    final bladeOne = Path()
      ..moveTo(size.width * 0.50, size.height * 0.50)
      ..lineTo(size.width * 0.86, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.44,
        size.width * 0.50,
        size.height * 0.55,
      )
      ..close();
    final bladeTwo = Path()
      ..moveTo(size.width * 0.50, size.height * 0.54)
      ..lineTo(size.width * 0.94, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.64,
        size.width * 0.50,
        size.height * 0.58,
      )
      ..close();

    canvas.drawPath(bladeOne, bladePaint);
    canvas.drawPath(bladeTwo, darkBlade);
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.55),
      size.shortestSide * 0.055,
      Paint()..color = const Color(0xFFAEB2BD),
    );
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.55),
      size.shortestSide * 0.020,
      Paint()..color = const Color(0xFF858994),
    );

    final upperHandle = Path()
      ..moveTo(size.width * 0.48, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.52,
        size.width * 0.28,
        size.height * 0.45,
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.22, size.height * 0.44),
          width: size.width * 0.24,
          height: size.height * 0.16,
        ),
      );
    final lowerHandle = Path()
      ..moveTo(size.width * 0.48, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.70,
        size.width * 0.32,
        size.height * 0.78,
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.34, size.height * 0.82),
          width: size.width * 0.22,
          height: size.height * 0.17,
        ),
      );

    canvas.drawPath(upperHandle, handle);
    canvas.drawPath(lowerHandle, handle);
  }

  @override
  bool shouldRepaint(covariant _MovePainter oldDelegate) =>
      oldDelegate.move != move;
}

class _DottedDividerPainter extends CustomPainter {
  const _DottedDividerPainter({required this.vertical});

  final bool vertical;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final dotRadius = vertical ? size.width * 0.34 : size.height * 0.34;
    final length = vertical ? size.height : size.width;
    final step = dotRadius * 4.6;

    for (double p = dotRadius; p < length; p += step) {
      canvas.drawCircle(
        vertical ? Offset(size.width / 2, p) : Offset(p, size.height / 2),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD92828);
    final shaft = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.41,
        0,
        size.width * 0.18,
        size.height * 0.56,
      ),
      Radius.circular(size.width * 0.02),
    );
    final head = Path()
      ..moveTo(size.width * 0.20, size.height * 0.56)
      ..lineTo(size.width * 0.80, size.height * 0.56)
      ..lineTo(size.width * 0.50, size.height * 0.92)
      ..close();

    canvas.drawRRect(shaft, paint);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScrollBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final blue = Paint()..color = const Color(0xFF2B74DA);

    final top = Path()
      ..moveTo(size.width / 2, 2)
      ..lineTo(size.width - 2, size.width * 0.75)
      ..lineTo(2, size.width * 0.75)
      ..close();
    final bottom = Path()
      ..moveTo(size.width / 2, size.height - 2)
      ..lineTo(size.width - 2, size.height - size.width * 0.75)
      ..lineTo(2, size.height - size.width * 0.75)
      ..close();

    canvas.drawPath(top, line);
    canvas.drawPath(bottom, line);
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.28,
        size.width,
        size.width * 0.44,
        size.height - size.width * 2,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(track, line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.30,
          size.height * 0.20,
          size.width * 0.40,
          size.height * 0.32,
        ),
        const Radius.circular(8),
      ),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
