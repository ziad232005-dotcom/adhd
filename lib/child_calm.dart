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
                      child: child,
                    ),
                    child: const MazidMascot(size: 190),
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
