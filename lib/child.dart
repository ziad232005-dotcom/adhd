import 'dart:async';
import 'package:flutter/material.dart';

const Color childPrimary = Color(0xFF7566D9);
const Color childBackground = Color(0xFFF8F7FF);
const Color childText = Color(0xFF25213D);

class ChildTask {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int points;
  const ChildTask(this.id, this.title, this.subtitle, this.icon, this.points);
}

/// Shared demo data. It resets when the app process is closed; no backend yet.
class ChildAppState {
  ChildAppState._();
  static final ChildAppState instance = ChildAppState._();

  int points = 0;
  final Set<int> completed = {};
  String? mood;

  final List<ChildTask> tasks = const [
    ChildTask(1, 'Brush your teeth', 'A fresh start!', Icons.cleaning_services_rounded, 10),
    ChildTask(2, 'Pack your school bag', 'Get ready for tomorrow.', Icons.backpack_rounded, 15),
    ChildTask(3, 'Read for 10 minutes', 'One page at a time.', Icons.menu_book_rounded, 20),
    ChildTask(4, 'Tidy up your toys', 'Make your space shine.', Icons.toys_rounded, 15),
  ];

  int get completedCount => completed.length;

  bool completeTask(ChildTask task) {
    if (!completed.add(task.id)) return false;
    points += task.points;
    return true;
  }
}

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});
  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final pinController = TextEditingController();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void login() {
    if (pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your 4-digit PIN')),
      );
      return;
    }
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const ChildDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: childBackground,
        appBar: AppBar(
          backgroundColor: childBackground,
          elevation: 0,
          title: const Text('MAZID',
              style: TextStyle(color: childText, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(children: [
                  _circleIcon(Icons.child_care_rounded, 112),
                  const SizedBox(height: 24),
                  const Text('Hello, Super Star!',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: childText)),
                  const SizedBox(height: 10),
                  const Text('Enter your 4-digit PIN to continue',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 12),
                    decoration: InputDecoration(
                      hintText: '••••',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: childPrimary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _primaryButton('Let’s Go!', Icons.rocket_launch_rounded, login),
                  const SizedBox(height: 12),
                  const Text('Demo: any 4 digits will work.',
                      style: TextStyle(fontSize: 12, color: Colors.black45)),
                ]),
              ),
            ),
          ),
        ),
      );
}

class ChildDashboardScreen extends StatefulWidget {
  const ChildDashboardScreen({super.key});
  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  final data = ChildAppState.instance;

  Future<void> open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = data.completedCount / data.tasks.length;
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(
        title: const Text('MAZID', style: TextStyle(color: childText, fontWeight: FontWeight.bold)),
        backgroundColor: childBackground,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'My rewards',
            onPressed: () => open(const ChildRewardsScreen()),
            icon: const Icon(Icons.card_giftcard_rounded, color: childPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [childPrimary, Color(0xFF9B8FF0)]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hi, Super Star! ✨', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Small steps make big progress.', style: TextStyle(color: Colors.white, height: 1.4)),
              ])),
              Icon(Icons.emoji_events_rounded, size: 58, color: Colors.white),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard(Icons.stars_rounded, '${data.points}', 'My points', const Color(0xFFFFB547))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.check_circle_rounded, '${data.completedCount}/${data.tasks.length}', 'Tasks done', const Color(0xFF43B89C))),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Today’s progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: childText)),
            Text('${(progress * 100).round()}%', style: const TextStyle(color: childPrimary, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 10, color: childPrimary, backgroundColor: Colors.white)),
          const SizedBox(height: 24),
          const Text('What would you like to do?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: childText)),
          const SizedBox(height: 12),
          _navCard('My Tasks', 'Finish little tasks and earn points.', Icons.checklist_rounded, const Color(0xFF43B89C), () => open(const ChildTasksScreen())),
          _navCard('Focus Time', 'Take one task at a time.', Icons.timer_rounded, childPrimary, () => open(const FocusTimerScreen())),
          _navCard('How Do I Feel?', data.mood == null ? 'Choose the feeling that fits you.' : 'Today I feel ${data.mood}.', Icons.mood_rounded, const Color(0xFFFFA45B), () => open(const ChildCheckInScreen())),
          _navCard('My Progress', 'See what you have achieved.', Icons.insights_rounded, const Color(0xFF5C9FE8), () => open(const ChildProgressScreen())),
          _navCard('My Rewards', 'Your points are worth celebrating!', Icons.card_giftcard_rounded, const Color(0xFFE88EB3), () => open(const ChildRewardsScreen())),
        ],
      ),
    );
  }
}

class ChildTasksScreen extends StatefulWidget {
  const ChildTasksScreen({super.key});
  @override
  State<ChildTasksScreen> createState() => _ChildTasksScreenState();
}

class _ChildTasksScreenState extends State<ChildTasksScreen> {
  final data = ChildAppState.instance;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: childBackground,
        appBar: AppBar(title: const Text('My Tasks'), backgroundColor: childBackground, elevation: 0),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _whitePanel(Row(children: [
              const Icon(Icons.flag_rounded, color: childPrimary, size: 34),
              const SizedBox(width: 12),
              Expanded(child: Text('${data.completedCount} of ${data.tasks.length} tasks completed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ])),
            const SizedBox(height: 14),
            ...data.tasks.map((task) {
              final done = data.completed.contains(task.id);
              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: childPrimary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(task.icon, color: childPrimary),
                  ),
                  title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: done ? TextDecoration.lineThrough : null)),
                  subtitle: Text(done ? 'Great job! +${task.points} points earned.' : '${task.subtitle}\n+${task.points} points'),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: done ? null : () {
                      setState(() => data.completeTask(task));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Awesome! +${task.points} points 🎉')));
                    },
                    icon: Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined, size: 30, color: done ? const Color(0xFF43B89C) : childPrimary),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusTimerScreen())),
              icon: const Icon(Icons.timer_rounded),
              label: const Text('Start Focus Time'),
              style: OutlinedButton.styleFrom(foregroundColor: childPrimary, padding: const EdgeInsets.all(14), side: const BorderSide(color: childPrimary)),
            ),
          ],
        ),
      );
}

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});
  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const initialSeconds = 5 * 60;
  int remainingSeconds = initialSeconds;
  Timer? timer;
  bool isRunning = false;
  bool isFinished = false;

  void toggleTimer() {
    if (isFinished) { resetTimer(); return; }
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
      return;
    }
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (remainingSeconds <= 1) {
        t.cancel();
        setState(() { remainingSeconds = 0; isRunning = false; isFinished = true; });
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() { remainingSeconds = initialSeconds; isRunning = false; isFinished = false; });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(title: const Text('Focus Time'), backgroundColor: childBackground, elevation: 0),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _circleIcon(Icons.stars_rounded, 116),
        const SizedBox(height: 22),
        Text(isFinished ? 'Amazing Job!' : 'You Can Do It!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: childText)),
        const SizedBox(height: 10),
        Text(isFinished ? 'You finished your focus session!' : 'Focus on one little thing at a time.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 28),
        Text('$m:$s', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: childPrimary)),
        const SizedBox(height: 24),
        _primaryButton(isFinished ? 'Start Again' : isRunning ? 'Pause' : 'Start Focus', isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, toggleTimer),
        TextButton(onPressed: resetTimer, child: const Text('Reset Timer', style: TextStyle(color: childPrimary))),
        if (isFinished) const Text('Take a little break. You did great! 🌟', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: childText)),
      ]))),
    );
  }
}

class ChildCheckInScreen extends StatefulWidget {
  const ChildCheckInScreen({super.key});
  @override
  State<ChildCheckInScreen> createState() => _ChildCheckInScreenState();
}

class _ChildCheckInScreenState extends State<ChildCheckInScreen> {
  final data = ChildAppState.instance;
  String? selectedMood;
  final moods = const [
    ('Happy', '😊', 'Something made me smile.'),
    ('Calm', '😌', 'I feel peaceful.'),
    ('Sad', '😢', 'I feel a little down.'),
    ('Angry', '😠', 'I feel upset.'),
    ('Worried', '😟', 'Something is on my mind.'),
  ];

  @override
  void initState() { super.initState(); selectedMood = data.mood; }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: childBackground,
        appBar: AppBar(title: const Text('How Do I Feel?'), backgroundColor: childBackground, elevation: 0),
        body: SafeArea(child: Column(children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('How are you feeling today?', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: childText)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('There are no wrong answers. Choose what feels right.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(20),
            children: moods.map((mood) {
              final chosen = selectedMood == mood.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => selectedMood = mood.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: chosen ? childPrimary.withValues(alpha: .13) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: chosen ? childPrimary : Colors.transparent, width: 2),
                    ),
                    child: Row(children: [
                      Text(mood.$2, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(mood.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: childText)),
                        const SizedBox(height: 4),
                        Text(mood.$3, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ])),
                      Icon(chosen ? Icons.check_circle_rounded : Icons.circle_outlined, color: chosen ? childPrimary : Colors.black26),
                    ]),
                  ),
                ),
              );
            }).toList(),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _primaryButton('Save My Mood', Icons.favorite_rounded, selectedMood == null ? null : () {
              data.mood = selectedMood;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks for sharing. You feel ${selectedMood!.toLowerCase()} today 💜')));
              Navigator.pop(context);
            }),
          ),
        ])),
      );
}

class ChildRewardsScreen extends StatelessWidget {
  const ChildRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;
    final rewards = const [
      ('Shining Star', 'Complete your first task', 10, Icons.star_rounded),
      ('Focus Champion', 'Collect 30 points', 30, Icons.bolt_rounded),
      ('Super Achiever', 'Collect 60 points', 60, Icons.emoji_events_rounded),
    ];
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(title: const Text('My Rewards'), backgroundColor: childBackground, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: childPrimary, borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            const Icon(Icons.stars_rounded, color: Colors.white, size: 44),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your points', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('${data.points}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ])),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('Achievement badges', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: childText)),
        const SizedBox(height: 12),
        ...rewards.map((r) {
          final unlocked = data.points >= r.$3;
          return Card(
            elevation: 0, color: Colors.white, margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: (unlocked ? const Color(0xFFFFB547) : Colors.grey).withValues(alpha: .16), borderRadius: BorderRadius.circular(15)), child: Icon(r.$4, color: unlocked ? const Color(0xFFFFB547) : Colors.grey, size: 30)),
              title: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(r.$2),
              trailing: Icon(unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: unlocked ? const Color(0xFF43B89C) : Colors.grey),
            ),
          );
        }),
        const SizedBox(height: 8),
        const Text('Keep trying. Every small step counts! 💜', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
      ]),
    );
  }
}

class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;
    final progress = data.completedCount / data.tasks.length;
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(title: const Text('My Progress'), backgroundColor: childBackground, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _whitePanel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Look how far you’ve come!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: childText)),
          const SizedBox(height: 8),
          Text('${data.completedCount} of ${data.tasks.length} tasks completed', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 12, color: childPrimary, backgroundColor: childBackground)),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}% complete', style: const TextStyle(color: childPrimary, fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 14),
        _infoCard(Icons.stars_rounded, 'Points collected', '${data.points}', const Color(0xFFFFB547)),
        _infoCard(Icons.check_circle_rounded, 'Tasks completed', '${data.completedCount}', const Color(0xFF43B89C)),
        _infoCard(Icons.mood_rounded, 'Latest mood', data.mood ?? 'Not shared yet', childPrimary),
        const SizedBox(height: 12),
        const Text('Progress is about trying, not being perfect. 🌱', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.5)),
      ]),
    );
  }
}

Widget _circleIcon(IconData icon, double size) => Container(
  width: size, height: size,
  decoration: BoxDecoration(color: childPrimary.withValues(alpha: .12), shape: BoxShape.circle),
  child: Icon(icon, size: size * .62, color: childPrimary),
);

Widget _primaryButton(String label, IconData icon, VoidCallback? onPressed) =>
    SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: childPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: childPrimary.withValues(alpha: .35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );

Widget _statCard(IconData icon, String value, String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
  child: Row(children: [
    Icon(icon, size: 29, color: color),
    const SizedBox(width: 9),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: childText)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ])),
  ]),
);

Widget _navCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) => Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 0,
  color: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: childText)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 26),
      ]),
    ),
  ),
);

Widget _whitePanel(Widget child) => Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
  child: child,
);

Widget _infoCard(IconData icon, String title, String value, Color color) => Card(
  color: Colors.white,
  elevation: 0,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  child: ListTile(
    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)),
    title: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
    subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: childText)),
  ),
);
