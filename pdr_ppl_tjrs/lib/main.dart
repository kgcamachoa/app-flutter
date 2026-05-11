import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const StartPage(),
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

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void _openGame(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GamePage()));
  }

  void _closeApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED0F4),
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: 1600,
              height: 900,
              padding: const EdgeInsets.fromLTRB(58, 48, 58, 28),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8E4DFF), width: 5),
              ),
              child: Column(
                children: [
                  const _NeonText('PIEDRA, PAPEL O TIJERA', fontSize: 58),
                  const SizedBox(height: 78),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Move.values.map((move) {
                      return _HomeMoveFrame(move: move);
                    }).toList(),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HomeActionFrame(
                        key: const ValueKey('start-play'),
                        onTap: () => _openGame(context),
                        child: const _PlayLabel(),
                      ),
                      const SizedBox(width: 210),
                      _HomeActionFrame(
                        key: const ValueKey('start-exit'),
                        onTap: _closeApp,
                        child: const _ExitIcon(),
                      ),
                    ],
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
      RoundResult.player => 'GANASTE LA RONDA',
      RoundResult.computer => 'GANA LA COMPUTADORA',
      RoundResult.tie => 'EMPATE',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAED0F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1600,
                  height: 900,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(34, 22, 34, 18),
                    child: _WideGameView(
                      playerMove: _playerMove,
                      computerMove: _computerMove,
                      playerScore: _playerScore,
                      computerScore: _computerScore,
                      statusText: _statusText,
                      onPlay: _play,
                    ),
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
    return Row(
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
        SizedBox(
          width: 520,
          height: 450,
          child: _SelectionStage(move: selectedMove, large: true),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 12,
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
        _NeonText(statusText, fontSize: 40),
        const SizedBox(height: 28),
        SizedBox(
          width: 550,
          height: 500,
          child: _SelectionStage(move: selectedMove, large: true),
        ),
        const SizedBox(height: 18),
        _ScoreBoard(playerScore: playerScore, computerScore: computerScore),
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
          child: _MoveImage(move: move),
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
              width: 220,
              height: 154,
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
                              padding: const EdgeInsets.fromLTRB(14, 9, 8, 7),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _ButtonMovePreview(
                                      move: widget.move,
                                      selected: widget.selected,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
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

class _ButtonMovePreview extends StatelessWidget {
  const _ButtonMovePreview({required this.move, required this.selected});

  final Move move;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelHeight = 22.0;
        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: labelHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _MoveImage(move: move),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: labelHeight,
              child: Center(
                child: Text(
                  move.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF0D52BC)
                        : const Color(0xFF182033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MoveImage extends StatelessWidget {
  const _MoveImage({required this.move});

  final Move move;

  String get assetPath {
    return switch (move) {
      Move.rock => 'assets/images/piedra.png',
      Move.paper => 'assets/images/papel.png',
      Move.scissors => 'assets/images/tijera.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _HomeMoveFrame extends StatelessWidget {
  const _HomeMoveFrame({required this.move});

  final Move move;

  @override
  Widget build(BuildContext context) {
    return _WebWindowFrame(
      width: 420,
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 18, 18, 18),
        child: Row(
          children: [
            Expanded(child: _MoveImage(move: move)),
            const SizedBox(width: 14),
            const _FakeScrollBar(),
          ],
        ),
      ),
    );
  }
}

class _HomeActionFrame extends StatefulWidget {
  const _HomeActionFrame({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HomeActionFrame> createState() => _HomeActionFrameState();
}

class _HomeActionFrameState extends State<_HomeActionFrame> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1,
        duration: const Duration(milliseconds: 140),
        child: GestureDetector(
          onTap: widget.onTap,
          child: _WebWindowFrame(
            width: 300,
            height: 210,
            active: _hovered,
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _PlayLabel extends StatelessWidget {
  const _PlayLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5757),
        border: Border.all(color: const Color(0xFF181235), width: 7),
        borderRadius: BorderRadius.circular(46),
      ),
      child: const Text(
        'PLAY',
        style: TextStyle(
          color: Color(0xFF181235),
          fontSize: 38,
          letterSpacing: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExitIcon extends StatelessWidget {
  const _ExitIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B62),
        border: Border.all(color: const Color(0xFF181235), width: 6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: CustomPaint(painter: _ExitIconPainter()),
    );
  }
}

class _WebWindowFrame extends StatelessWidget {
  const _WebWindowFrame({
    required this.width,
    required this.height,
    required this.child,
    this.active = false,
  });

  final double width;
  final double height;
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -18,
            top: 20,
            right: 18,
            bottom: -18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1D60C6),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FE),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _WindowBar(active: active),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
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
          _WindowIcon(symbol: 'o'),
          SizedBox(width: 4),
          _WindowIcon(symbol: 'x'),
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
  const _ScoreBoard({required this.playerScore, required this.computerScore});

  final int playerScore;
  final int computerScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(-48, 0),
          child: const _DownArrow(size: 60),
        ),
        const SizedBox(height: 4),
        _NeonText('$playerScore  -  $computerScore', fontSize: 42),
        const SizedBox(height: 8),
        const _NeonText('MARCADOR', fontSize: 42),
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
    const letterSpacing = 5.0;
    const textHeight = 0.78;

    TextStyle style({
      Color? color,
      Color? strokeColor,
      double strokeWidth = 0,
    }) {
      return TextStyle(
        color: color,
        fontFamily: 'Arial',
        fontSize: fontSize,
        height: textHeight,
        letterSpacing: letterSpacing,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        foreground: strokeColor == null
            ? null
            : (Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = strokeColor),
      );
    }

    Widget layer(TextStyle textStyle, {Offset offset = Offset.zero}) {
      return Transform.translate(
        offset: offset,
        child: Transform.scale(
          scaleX: 1.14,
          scaleY: 0.70,
          child: Text(text, textAlign: TextAlign.center, style: textStyle),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        layer(
          style(
            strokeColor: const Color.fromARGB(255, 240, 101, 210),
            strokeWidth: 6,
          ),
        ),
        layer(
          style(
            strokeColor: const Color.fromARGB(255, 133, 232, 239),
            strokeWidth: 6,
          ),
          offset: const Offset(3, 3),
        ),
        layer(style(color: const Color.fromARGB(255, 167, 22, 22))),
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
    final paint = Paint()..color = const Color.fromARGB(255, 167, 22, 22);
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

class _ExitIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5E2B2B)
      ..strokeWidth = size.shortestSide * 0.14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.28),
      Offset(size.width * 0.72, size.height * 0.72),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.28, size.height * 0.72),
      paint,
    );
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
