import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// A mobile-friendly TOVA-style attention activity.
///
/// IMPORTANT: This is an educational/prototype implementation, not the licensed
/// TOVA product and not a clinically validated diagnostic assessment. Flutter
/// timers, display refresh, and touch response latency are not equivalent to a
/// controlled clinical testing setup.

enum TovaMode { training1, training2, training3, practice, full }

extension TovaModeInfo on TovaMode {
  String get title => switch (this) {
        TovaMode.training1 => 'Training Level 1',
        TovaMode.training2 => 'Training Level 2',
        TovaMode.training3 => 'Training Level 3',
        TovaMode.practice => 'Standard Practice',
        TovaMode.full => 'Full Attention Activity',
      };

  String get subtitle => switch (this) {
        TovaMode.training1 => '15 trials · Easy / slow',
        TovaMode.training2 => '20 trials · Medium',
        TovaMode.training3 => '25 trials · Advanced',
        TovaMode.practice => '40 trials · Practice session',
        TovaMode.full => '648 trials · Long session',
      };

  int get totalTrials => switch (this) {
        TovaMode.training1 => 15,
        TovaMode.training2 => 20,
        TovaMode.training3 => 25,
        TovaMode.practice => 40,
        TovaMode.full => 648,
      };

  int get targetCount => switch (this) {
        TovaMode.training1 => 8,
        TovaMode.training2 => 10,
        TovaMode.training3 => 12,
        TovaMode.practice => 20,
        TovaMode.full => 324,
      };

  int get trialMs => switch (this) {
        TovaMode.training1 => 3500,
        TovaMode.training2 => 3000,
        TovaMode.training3 => 2500,
        TovaMode.practice || TovaMode.full => 2000,
      };

  int get stimulusMs => switch (this) {
        TovaMode.training1 => 200,
        TovaMode.training2 => 150,
        TovaMode.training3 => 120,
        TovaMode.practice || TovaMode.full => 100,
      };

  bool get isTrainingOrPractice => this != TovaMode.full;
}

// MAZID app palette: soft lavender background, purple primary, and dark-plum text.
const Color _tovaBg = Color(0xFFFAF8FF);
const Color _tovaElev = Color(0xFFF3F0FF);
const Color _tovaCard = Color(0xFFFFFFFF);
const Color _tovaInk = Color(0xFF30285E);
const Color _tovaStrong = Color(0xFF30285E);
const Color _tovaMuted = Color(0xFF756E91);
const Color _tovaMutedSoft = Color(0xFF9891AE);
const Color _tovaLine = Color(0xFFE6E1F3);
const Color _tovaBrand = Color(0xFF7566D9);
const Color _tovaOk = Color(0xFF278658);
const Color _tovaWarn = Color(0xFF9B670B);
const Color _tovaBad = Color(0xFFD64F62);

ThemeData _tovaThemeData(BuildContext context) {
  final base = Theme.of(context);
  final textTheme = base.textTheme.apply(
    fontFamily: 'cairo',
    bodyColor: _tovaInk,
    displayColor: _tovaStrong,
  );
  return base.copyWith(
    scaffoldBackgroundColor: _tovaBg,
    colorScheme: base.colorScheme.copyWith(
      primary: _tovaBrand,
      secondary: _tovaBrand,
      surface: _tovaCard,
      onSurface: _tovaInk,
      onPrimary: Colors.white,
      error: _tovaBad,
    ),
    textTheme: textTheme,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: _tovaBg,
      foregroundColor: _tovaStrong,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: _tovaStrong,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: _tovaStrong),
    ),
  );
}

Widget _withTovaTheme(BuildContext context, Widget child) =>
    Theme(data: _tovaThemeData(context), child: child);

/// Add this route from the child's area with:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const TovaWelcomeScreen()));
class TovaWelcomeScreen extends StatefulWidget {
  const TovaWelcomeScreen({super.key});

  @override
  State<TovaWelcomeScreen> createState() => _TovaWelcomeScreenState();
}

class _TovaWelcomeScreenState extends State<TovaWelcomeScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  TovaMode _mode = TovaMode.practice;
  bool _acknowledged = false;

  bool get _canStart {
    final age = int.tryParse(_ageController.text.trim());
    return _nameController.text.trim().isNotEmpty &&
        age != null &&
        age >= 4 &&
        age <= 18 &&
        _acknowledged;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _withTovaTheme(context, Scaffold(
      backgroundColor: _tovaBg,
      appBar: AppBar(
        backgroundColor: _tovaBg,
        foregroundColor: _tovaStrong,
        elevation: 0,
        title: const Text('Attention Activity'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _tovaCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _tovaLine),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.center_focus_strong_rounded,
                            color: _tovaBrand, size: 38),
                        SizedBox(height: 16),
                        Text(
                          'Focus on the shape',
                          style: TextStyle(
                            color: _tovaStrong,
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'A target has a small black square near the top of the white shape. Tap RESPOND only when you see that target. Do not respond to the lower-position square.',
                          style: TextStyle(
                            color: _tovaMuted,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TovaSectionCard(
                    title: 'Child details',
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: _tovaInk),
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration('Child name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ageController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: _tovaInk),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _inputDecoration('Age (4–18 years)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TovaSectionCard(
                    title: 'Choose an activity',
                    child: Column(
                      children: TovaMode.values.map((mode) {
                        final selected = mode == _mode;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _mode = mode),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? _tovaBrand.withValues(alpha: 0.10)
                                    : _tovaElev,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? _tovaBrand : _tovaLine,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected ? _tovaBrand : _tovaMuted,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(mode.title,
                                            style: const TextStyle(
                                                color: _tovaInk,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(mode.subtitle,
                                            style: const TextStyle(
                                                color: _tovaMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _tovaWarn.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _tovaWarn.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Important: this is a TOVA-style educational activity, not the licensed TOVA assessment. Its scores are approximate and must not be used to diagnose ADHD or replace a qualified clinician.',
                      style: TextStyle(color: _tovaInk, height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: _acknowledged,
                    onChanged: (value) =>
                        setState(() => _acknowledged = value ?? false),
                    activeColor: _tovaBrand,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text(
                      'A parent or guardian has reviewed this information and will supervise the activity.',
                      style: TextStyle(color: _tovaInk, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _canStart
                        ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => TovaTestScreen(
                                mode: _mode,
                                childName: _nameController.text.trim(),
                                childAge: int.parse(_ageController.text.trim()),
                              ),
                            ));
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _tovaBrand,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _tovaCard,
                      disabledForegroundColor: _tovaMutedSoft,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Continue to instructions',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class TovaTestScreen extends StatefulWidget {
  const TovaTestScreen({
    super.key,
    required this.mode,
    required this.childName,
    required this.childAge,
  });

  final TovaMode mode;
  final String childName;
  final int childAge;

  @override
  State<TovaTestScreen> createState() => _TovaTestScreenState();
}

class _TovaTestScreenState extends State<TovaTestScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Stopwatch _watch = Stopwatch();
  final FocusNode _focusNode = FocusNode(debugLabel: 'TOVA activity keyboard focus');
  Timer? _countdownTimer;
  Timer? _feedbackTimer;

  late List<_TrialSpec> _sequence;
  late List<TovaTrialResult> _results;
  _RunPhase _phase = _RunPhase.instructions;
  int _countdown = 3;
  int _currentIndex = -1;
  int _baseOnsetMs = 1500;
  int? _stimulusVisibleUntil;
  bool _stimulusVisible = false;
  String _feedback = '';
  Color _feedbackColor = _tovaMuted;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _sequence = _TovaSequenceBuilder.build(widget.mode, Random().nextInt(0x7fffffff));
_results = _sequence.map(TovaTrialResult._fromSpec).toList();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    _ticker.dispose();
    _watch.stop();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _phase = _RunPhase.countdown;
      _countdown = 3;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown <= 1) {
        timer.cancel();
        _countdownTimer = null;
        _startRun();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _startRun() {
    _watch
      ..reset()
      ..start();
    _currentIndex = -1;
    _baseOnsetMs = 1500;
    _stimulusVisible = false;
    _stimulusVisibleUntil = null;
    _phase = _RunPhase.running;
    _ticker.start();
    if (mounted) setState(() {});
  }

  void _tick(Duration _) {
    if (_phase != _RunPhase.running || !_watch.isRunning || _disposed) return;
    final now = _watch.elapsedMilliseconds;

    if (_stimulusVisible &&
        _stimulusVisibleUntil != null &&
        now >= _stimulusVisibleUntil!) {
      _stimulusVisible = false;
    }

    final nextOnset = _baseOnsetMs + (_currentIndex + 1) * widget.mode.trialMs;
    if (now >= nextOnset) {
      if (_currentIndex >= 0) _finalizeTrial(_currentIndex);
      _currentIndex++;
      if (_currentIndex >= _sequence.length) {
        _finishRun(completed: true);
        return;
      }
      final result = _results[_currentIndex];
      result.onsetMs = now;
      _stimulusVisible = true;
      _stimulusVisibleUntil = now + widget.mode.stimulusMs;
    }

    if (mounted) setState(() {});
  }

void _respond() {
  if (_phase != _RunPhase.running ||
      _currentIndex < 0 ||
      _currentIndex >= _results.length) {
    return;
  }

  final result = _results[_currentIndex];
    if (result.finalized) return;
    final onset = result.onsetMs;
    if (onset == null) return;
    final now = _watch.elapsedMilliseconds;
    if (result.responded) {
      result.extra++;
      return;
    }
    result.responded = true;
    result.rtMs = max(0, now - onset).toInt();

    if (widget.mode.isTrainingOrPractice) {
      if (result.rtMs! < 150) {
        _feedback = 'Too fast!';
        _feedbackColor = _tovaWarn;
      } else if (result.target) {
        _feedback = 'Correct!';
        _feedbackColor = _tovaOk;
      } else {
        _feedback = 'Wrong press!';
        _feedbackColor = _tovaBad;
      }
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _feedback = '');
      });
    }
    if (mounted) setState(() {});
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      _respond();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyP &&
        _phase == _RunPhase.running) {
      _pauseRun();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _finalizeTrial(int index) {
    if (index < 0 || index >= _results.length) return;
    final result = _results[index];
    if (result.finalized) return;
    result.finalized = true;
    result.outcome = _classify(result.target, result.responded, result.rtMs);
  }

  void _pauseRun() {
    if (_phase != _RunPhase.running) return;
    _ticker.stop();
    _watch.stop();
    if (_currentIndex >= 0 && _currentIndex < _results.length) {
      final current = _results[_currentIndex];
      if (!current.finalized) {
        current.interrupted = true;
        current.outcome = 'interrupted';
        current.finalized = true;
      }
    }
    _stimulusVisible = false;
    setState(() => _phase = _RunPhase.paused);
  }

  void _resumeRun() {
    if (_phase != _RunPhase.paused) return;
    final nextIndex = _currentIndex + 1;
    final now = _watch.elapsedMilliseconds;
    _baseOnsetMs = now + 3000 - nextIndex * widget.mode.trialMs;
    _stimulusVisible = false;
    _stimulusVisibleUntil = null;
    _watch.start();
    setState(() => _phase = _RunPhase.running);
    _ticker.start();
    _focusNode.requestFocus();
  }

  void _finishRun({required bool completed, bool partial = false}) {
    _countdownTimer?.cancel();
    _ticker.stop();
    _watch.stop();
    if (_currentIndex >= 0 &&
        _currentIndex < _results.length &&
        !_results[_currentIndex].finalized) {
      _finalizeTrial(_currentIndex);
    }
    _stimulusVisible = false;
    final shownResults = _results
        .where((r) => r.onsetMs != null && r.finalized && !r.interrupted)
        .toList(growable: false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => TovaResultsScreen(
        mode: widget.mode,
        childName: widget.childName,
        childAge: widget.childAge,
        results: shownResults,
        completed: completed,
        partial: partial,
      ),
    ));
  }

  void _abortRun() {
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    _ticker.stop();
    _watch.stop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _withTovaTheme(context, Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 16,
                right: 16,
                top: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.mode.title.toUpperCase()} · TRIAL ${max(0, _currentIndex + 1)}/${_sequence.length}',
                            style: const TextStyle(
                              color: Color(0xFFB8B2D5),
                              fontSize: 11,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        if (_phase == _RunPhase.running)
                          IconButton(
                            onPressed: _pauseRun,
                            tooltip: 'Pause (P)',
                            icon: const Icon(Icons.pause_rounded,
                                color: Colors.white),
                          ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: _sequence.isEmpty
                            ? 0
                            : max(0, _currentIndex + 1) / _sequence.length,
                        backgroundColor: const Color(0xFF1E222A),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_tovaBrand),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    _phase == _RunPhase.countdown
                        ? '$_countdown'
                        : _phase == _RunPhase.instructions
                            ? ''
                            : '+',
                    style: TextStyle(
                      color: _phase == _RunPhase.running
                          ? const Color(0xFF2F3540)
                          : Colors.white,
                      fontSize: _phase == _RunPhase.countdown ? 66 : 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (_stimulusVisible && _phase == _RunPhase.running)
                Center(
                  child: _TovaStimulus(
                    target: _results[_currentIndex].target,
                  ),
                ),
              if (_phase == _RunPhase.instructions)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _tovaCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _tovaLine),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.center_focus_strong_rounded,
                              color: _tovaBrand, size: 40),
                          const SizedBox(height: 14),
                          Text(widget.mode.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: _tovaStrong,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap RESPOND only when the small black square is near the top of the white square. Do not respond when it is near the bottom. You can use the Space key on a keyboard.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _tovaMuted, height: 1.6),
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: _startCountdown,
                            style: FilledButton.styleFrom(
                              backgroundColor: _tovaBrand,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Start activity'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _abortRun,
                            child: const Text('Go back',
                                style: TextStyle(color: _tovaMuted)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Column(
                  children: [
                    if (_feedback.isNotEmpty && _phase == _RunPhase.running)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _feedback,
                          style: TextStyle(
                            color: _feedbackColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_phase == _RunPhase.running)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: 280,
                          height: 56,
                          child: FilledButton(
                            onPressed: _respond,
                            style: FilledButton.styleFrom(
                              backgroundColor: _tovaBrand,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: const Text('RESPOND',
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    if (_phase == _RunPhase.running)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Or press SPACE on a keyboard · P to pause',
                            style: TextStyle(color: _tovaMutedSoft, fontSize: 11)),
                      ),
                  ],
                ),
              ),
              if (_phase == _RunPhase.paused)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xD90F1116),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(22),
                    child: Container(
                      width: 440,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _tovaCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _tovaLine),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_outline,
                              size: 44, color: _tovaBrand),
                          const SizedBox(height: 12),
                          const Text('Activity paused',
                              style: TextStyle(
                                  color: _tovaStrong,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text(
                            'The current trial was marked interrupted. You can resume with the next trial or finish with a partial report.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _tovaMuted, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _resumeRun,
                              style: FilledButton.styleFrom(
                                  backgroundColor: _tovaBrand,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Resume activity'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _finishRun(completed: false, partial: true),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: _tovaInk,
                                  side: const BorderSide(color: _tovaLine),
                                  padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Finish and view partial report'),
                            ),
                          ),
                          TextButton(
                            onPressed: _abortRun,
                            child: const Text('Discard activity',
                                style: TextStyle(color: _tovaBad)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
  }
}

enum _RunPhase { instructions, countdown, running, paused }

class _TovaStimulus extends StatelessWidget {
  const _TovaStimulus({required this.target});
  final bool target;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: target ? 14 : 66,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: ColoredBox(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class TovaTrialResult {
  TovaTrialResult({
    required this.trial,
    required this.half,
    required this.quarter,
    required this.target,
  });

factory TovaTrialResult._fromSpec(_TrialSpec spec) =>
    TovaTrialResult(
      trial: spec.trial,
      half: spec.half,
      quarter: spec.quarter,
      target: spec.target,
    );

  final int trial;
  final int half;
  final int quarter;
  final bool target;
  int? onsetMs;
  bool responded = false;
  int? rtMs;
  int extra = 0;
  String? outcome;
  bool finalized = false;
  bool interrupted = false;
}

class TovaResultsScreen extends StatelessWidget {
  const TovaResultsScreen({
    super.key,
    required this.mode,
    required this.childName,
    required this.childAge,
    required this.results,
    required this.completed,
    required this.partial,
  });

  final TovaMode mode;
  final String childName;
  final int childAge;
  final List<TovaTrialResult> results;
  final bool completed;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    final summary = _TovaSummary.fromResults(results);
    return _withTovaTheme(context, Scaffold(
      backgroundColor: _tovaBg,
      appBar: AppBar(
        backgroundColor: _tovaBg,
        foregroundColor: _tovaStrong,
        elevation: 0,
        title: const Text('Activity report'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TovaSectionCard(
                    title: mode.title,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Child: $childName · Age: $childAge',
                            style: const TextStyle(color: _tovaInk)),
                        const SizedBox(height: 6),
                        Text(
                          completed
                              ? 'Session completed'
                              : partial
                                  ? 'Partial session report'
                                  : 'Session ended',
                          style: TextStyle(
                            color: completed ? _tovaOk : _tovaWarn,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${results.length} trials included in this report',
                            style: const TextStyle(color: _tovaMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Response summary',
                      style: TextStyle(
                          color: _tovaStrong,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: MediaQuery.sizeOf(context).width < 520 ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.45,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _StatCard(label: 'Target hits', value: '${summary.hits}', color: _tovaOk),
                      _StatCard(label: 'Omissions', value: '${summary.omissions}', color: _tovaWarn),
                      _StatCard(label: 'Wrong presses', value: '${summary.commissions}', color: _tovaBad),
                      _StatCard(label: 'Correct rejections', value: '${summary.correctRejections}', color: _tovaBrand),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _TovaSectionCard(
                    title: 'Timing and accuracy',
                    child: Column(
                      children: [
                        _ReportRow(label: 'Mean target response time', value: summary.meanRtMs == null ? 'N/A' : '${summary.meanRtMs!.round()} ms'),
                        _ReportRow(label: 'Response-time variability (SD)', value: summary.sdRtMs == null ? 'N/A' : '${summary.sdRtMs!.round()} ms'),
                        _ReportRow(label: 'Omission percentage', value: '${summary.omissionPct.toStringAsFixed(1)}%'),
                        _ReportRow(label: 'Commission percentage', value: '${summary.commissionPct.toStringAsFixed(1)}%'),
                        _ReportRow(label: 'Anticipatory responses (<150 ms)', value: '${summary.anticipatory}'),
                        _ReportRow(label: 'Overall classified accuracy', value: '${summary.accuracyPct.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _tovaWarn.withValues(alpha: 0.07),
                      border: Border.all(color: _tovaWarn.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Interpretation caution: these are descriptive results from this prototype only. They are not normative TOVA scores, do not establish ADHD, and should not be used to make clinical, educational, or medication decisions.',
                      style: TextStyle(color: _tovaInk, height: 1.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: _tovaBrand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to activity menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class _TovaSummary {
  _TovaSummary({
    required this.hits,
    required this.omissions,
    required this.commissions,
    required this.correctRejections,
    required this.anticipatory,
    required this.meanRtMs,
    required this.sdRtMs,
    required this.omissionPct,
    required this.commissionPct,
    required this.accuracyPct,
  });

  final int hits;
  final int omissions;
  final int commissions;
  final int correctRejections;
  final int anticipatory;
  final double? meanRtMs;
  final double? sdRtMs;
  final double omissionPct;
  final double commissionPct;
  final double accuracyPct;

  factory _TovaSummary.fromResults(List<TovaTrialResult> results) {
    final hits = results.where((r) => r.outcome == 'hit').length;
    final omissions = results.where((r) => r.outcome == 'omission').length;
    final commissions = results.where((r) => r.outcome == 'commission').length;
    final correct = results.where((r) => r.outcome == 'correct_rejection').length;
    final anticipatory = results.where((r) => r.outcome == 'anticipatory').length;
    // Match the source controller's denominators: every presented target or
    // non-target trial contributes, including anticipatory responses.
    final targetCount = results.where((r) => r.target).length;
    final nonTargetCount = results.where((r) => !r.target).length;
    final targetRts = results
        .where((r) => r.outcome == 'hit' && r.rtMs != null && r.rtMs! >= 150)
        .map((r) => r.rtMs!.toDouble())
        .toList();
    double? mean;
    double? sd;
    if (targetRts.isNotEmpty) {
      mean = targetRts.reduce((a, b) => a + b) / targetRts.length;
      if (targetRts.length >= 2) {
        final variance = targetRts
                .map((value) => pow(value - mean!, 2).toDouble())
                .reduce((a, b) => a + b) /
            (targetRts.length - 1);
        sd = sqrt(variance);
      } else {
        sd = 0;
      }
    }
    final classified = hits + omissions + commissions + correct;
    return _TovaSummary(
      hits: hits,
      omissions: omissions,
      commissions: commissions,
      correctRejections: correct,
      anticipatory: anticipatory,
      meanRtMs: mean,
      sdRtMs: sd,
      omissionPct: targetCount == 0 ? 0 : omissions * 100 / targetCount,
      commissionPct: nonTargetCount == 0 ? 0 : commissions * 100 / nonTargetCount,
      accuracyPct: classified == 0 ? 0 : (hits + correct) * 100 / classified,
    );
  }
}

class _TovaSequenceBuilder {
  static List<_TrialSpec> build(TovaMode mode, int seed) {
    final random = Random(seed);
    List<bool> sequence;
    if (mode == TovaMode.full) {
      final firstHalf = _constrainedSegment(
        targets: 72,
        nonTargets: 252,
        maxTargetRun: 2,
        maxNonTargetRun: 8,
        random: random,
      );
      final secondHalf = _constrainedSegment(
        targets: 252,
        nonTargets: 72,
        maxTargetRun: 8,
        maxNonTargetRun: 2,
        random: random,
      );
      sequence = [...firstHalf, ...secondHalf];
    } else {
      sequence = _constrainedSegment(
        targets: mode.targetCount,
        nonTargets: mode.totalTrials - mode.targetCount,
        maxTargetRun: 2,
        maxNonTargetRun: 2,
        random: random,
      );
    }
    return List.generate(sequence.length, (index) {
      final trialNumber = index + 1;
      return _TrialSpec(
        trial: trialNumber,
        half: mode == TovaMode.full ? (trialNumber <= 324 ? 1 : 2) : 1,
        quarter: mode == TovaMode.full ? ((trialNumber - 1) ~/ 162) + 1 : 1,
        target: sequence[index],
      );
    });
  }

  static List<bool> _constrainedSegment({
    required int targets,
    required int nonTargets,
    required int maxTargetRun,
    required int maxNonTargetRun,
    required Random random,
  }) {
    var remainingTargets = targets;
    var remainingNonTargets = nonTargets;
    bool? lastType;
    var run = 0;
    final result = <bool>[];

    while (remainingTargets + remainingNonTargets > 0) {
      final candidates = <bool>[];
      for (final candidate in [true, false]) {
        if (candidate && remainingTargets == 0) continue;
        if (!candidate && remainingNonTargets == 0) continue;
        final nextRun = lastType == candidate ? run + 1 : 1;
        final runLimit = candidate ? maxTargetRun : maxNonTargetRun;
        if (nextRun > runLimit) continue;

        final nextTargets = remainingTargets - (candidate ? 1 : 0);
        final nextNonTargets = remainingNonTargets - (candidate ? 0 : 1);
        if (_canFinish(
          remainingTargets: nextTargets,
          remainingNonTargets: nextNonTargets,
          lastType: candidate,
          run: nextRun,
          maxTargetRun: maxTargetRun,
          maxNonTargetRun: maxNonTargetRun,
        )) {
          candidates.add(candidate);
        }
      }
      if (candidates.isEmpty) {
        // Defensive fallback; the supplied designs should remain feasible.
        if (remainingTargets > 0 &&
            (lastType != true || run < maxTargetRun)) {
          candidates.add(true);
        }
        if (remainingNonTargets > 0 &&
            (lastType != false || run < maxNonTargetRun)) {
          candidates.add(false);
        }
      }
      if (candidates.isEmpty) break;
      bool selected;
      if (candidates.length == 1) {
        selected = candidates.single;
      } else {
        // Count-weighted choice helps preserve the intended target ratio.
        final total = remainingTargets + remainingNonTargets;
        selected = random.nextDouble() < remainingTargets / total;
        if (!candidates.contains(selected)) selected = candidates.first;
      }
      result.add(selected);
      if (selected) {
        remainingTargets--;
      } else {
        remainingNonTargets--;
      }
      run = lastType == selected ? run + 1 : 1;
      lastType = selected;
    }
    return result;
  }

  static bool _canFinish({
    required int remainingTargets,
    required int remainingNonTargets,
    required bool lastType,
    required int run,
    required int maxTargetRun,
    required int maxNonTargetRun,
  }) {
    final targetCapacity = maxTargetRun * (remainingNonTargets + 1) -
        (lastType ? run : 0);
    final nonTargetCapacity = maxNonTargetRun * (remainingTargets + 1) -
        (!lastType ? run : 0);
    return remainingTargets >= 0 &&
        remainingNonTargets >= 0 &&
        remainingTargets <= targetCapacity &&
        remainingNonTargets <= nonTargetCapacity;
  }
}

class _TrialSpec {
  const _TrialSpec({
    required this.trial,
    required this.half,
    required this.quarter,
    required this.target,
  });
  final int trial;
  final int half;
  final int quarter;
  final bool target;
}

String _classify(bool target, bool responded, int? rtMs) {
  if (!responded || rtMs == null) {
    return target ? 'omission' : 'correct_rejection';
  }
  if (rtMs < 150) return 'anticipatory';
  return target ? 'hit' : 'commission';
}

InputDecoration _inputDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _tovaMuted),
      filled: true,
      fillColor: const Color(0xFFF7F5FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _tovaLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _tovaLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _tovaBrand, width: 1.5),
      ),
    );

class _TovaSectionCard extends StatelessWidget {
  const _TovaSectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _tovaCard,
        border: Border.all(color: _tovaLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _tovaBrand,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _tovaCard,
        border: Border.all(color: _tovaLine),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: _tovaMuted, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: _tovaMuted))),
          const SizedBox(width: 12),
          Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  color: _tovaInk, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
