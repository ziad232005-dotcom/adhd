import 'package:flutter/material.dart';

import 'child.dart' show childBackground, childPrimary, childText;
import 'core/chime.dart';
import 'core/widgets/mazid_widgets.dart';

/// A one-minute breathing exercise: the octopus grows while the child
/// breathes in and shrinks while they breathe out. Works without internet.
class CalmScreen extends StatefulWidget {
  const CalmScreen({super.key});

  /// Six rounds of 4 seconds in and 6 seconds out make one minute.
  static const rounds = 6;
  static const inhale = Duration(seconds: 4);
  static const exhale = Duration(seconds: 6);

  @override
  State<CalmScreen> createState() => _CalmScreenState();
}

class _CalmScreenState extends State<CalmScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CalmScreen.inhale,
    reverseDuration: CalmScreen.exhale,
  );

  bool _running = false;
  bool _breathingIn = true;
  int _round = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _running = true;
      _round = 0;
    });

    while (_running && _round < CalmScreen.rounds) {
      setState(() => _breathingIn = true);
      await _controller.forward().orCancel.catchError((_) {});
      if (!_running || !mounted) return;

      setState(() => _breathingIn = false);
      await _controller.reverse().orCancel.catchError((_) {});
      if (!_running || !mounted) return;

      setState(() => _round++);
    }

    if (_running && mounted) Chime.play();
    if (mounted) setState(() => _running = false);
  }

  void _stop() {
    _controller.stop();
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final finished = !_running && _round >= CalmScreen.rounds;

    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(
        title: const Text(
          'Calm minute',
          style: TextStyle(color: childText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: childBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: childPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) => Transform.scale(
                      scale: 0.7 + 0.5 * _controller.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          child!,
                          // The mouth opens while breathing in, closes out.
                          SizedBox(
                            width: _mascotSize,
                            height: _mascotSize,
                            child: CustomPaint(
                              painter: BreathMouthPainter(_controller.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: const MazidMascot(size: _mascotSize),
                  ),
                ),
              ),
              Text(
                finished
                    ? 'Well done. You feel calmer.'
                    : !_running
                        ? 'Breathe with the octopus.'
                        : _breathingIn
                            ? 'Breathe in'
                            : 'Breathe out',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: childText,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _running
                    ? 'Round ${_round + 1} of ${CalmScreen.rounds}'
                    : 'One minute. Slow and gentle.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _running ? _stop : _start,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: childPrimary,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  _running ? 'Stop' : finished ? 'Again' : 'Start',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const double _mascotSize = 190;

/// Draws an animated mouth over the octopus smile.
/// [open] is 0 (closed smile) to 1 (fully open).
class BreathMouthPainter extends CustomPainter {
  const BreathMouthPainter(this.open);

  final double open;

  @override
  void paint(Canvas canvas, Size size) {
    // Smile position inside the octopus image (374 x 364).
    final center = Offset(size.width * 0.548, size.height * 0.515);
    final w = size.width * 0.115;
    final h = size.width * 0.13 * open;
    const dark = Color(0xFF3A1B5C);
    if (h < 1.5) return; // the drawn smile in the image stays visible
    final mouth = Rect.fromCenter(center: center.translate(0, h / 2 - 2), width: w * (0.9 + 0.3 * open), height: h);
    canvas.drawOval(mouth, Paint()..color = dark);
    final tongue = Rect.fromCenter(
      center: mouth.center.translate(0, h * 0.22),
      width: mouth.width * 0.6,
      height: h * 0.45,
    );
    canvas.drawOval(tongue, Paint()..color = const Color(0xFFFF8FB1));
  }

  @override
  bool shouldRepaint(BreathMouthPainter old) => old.open != open;
}
