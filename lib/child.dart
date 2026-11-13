import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tova/tova_screens.dart';

const Color childPrimary = Color(0xFF7566D9);
const Color childBackground = Color(0xFFF8F7FF);
const Color childText = Color(0xFF25213D);

class ChildTask {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int points;

  const ChildTask(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
    this.points,
  );
}

class TaskCompletion {
  final int taskId;
  final String taskTitle;
  final DateTime completedAt;
  final int pointsEarned;

  const TaskCompletion({
    required this.taskId,
    required this.taskTitle,
    required this.completedAt,
    required this.pointsEarned,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'completedAt': completedAt.toIso8601String(),
        'pointsEarned': pointsEarned,
      };

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      taskId: json['taskId'] as int,
      taskTitle: json['taskTitle'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      pointsEarned: json['pointsEarned'] as int,
    );
  }
}
class ChildObservation {
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  const ChildObservation({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
      };

  factory ChildObservation.fromJson(Map<String, dynamic> json) {
    return ChildObservation(
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );
  }
}

class FocusSession {
  final int durationMinutes;
  final DateTime completedAt;

  const FocusSession({
    required this.durationMinutes,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'durationMinutes': durationMinutes,
        'completedAt': completedAt.toIso8601String(),
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      durationMinutes: json['durationMinutes'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
class MoodEntry {
  final String mood;
  final DateTime recordedAt;

  const MoodEntry({
    required this.mood,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: json['mood'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}
class ChildReward {
  final int id;
  final String title;
  final String description;
  final int targetPoints;
  final DateTime? achievedAt;

  const ChildReward({
    required this.id,
    required this.title,
    required this.description,
    required this.targetPoints,
    this.achievedAt,
  });

  bool isAchieved(int currentPoints) {
    return achievedAt != null || currentPoints >= targetPoints;
  }

  ChildReward copyWith({
    int? id,
    String? title,
    String? description,
    int? targetPoints,
    DateTime? achievedAt,
    bool clearAchievedAt = false,
  }) {
    return ChildReward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetPoints: targetPoints ?? this.targetPoints,
      achievedAt: clearAchievedAt
          ? null
          : achievedAt ?? this.achievedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetPoints': targetPoints,
        'achievedAt': achievedAt?.toIso8601String(),
      };

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return ChildReward(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      targetPoints: json['targetPoints'] as int,
      achievedAt: json['achievedAt'] == null
          ? null
          : DateTime.parse(json['achievedAt'] as String),
    );
  }
}

class ChildAppState extends ChangeNotifier {
  ChildAppState._() {
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshExpiredTasks(),
    );
  }

  static final ChildAppState instance = ChildAppState._();

  static const _storageKey = 'mazid_child_task_state_v1';

int _nextRewardId = 1;

final List<ChildReward> rewards = [];

final Set<int> _achievedRewardIds = {};

Set<int> get achievedRewardIds =>
    Set<int>.unmodifiable(_achievedRewardIds);

  int _nextTaskId = 5;
  int points = 0;
  String? _mood;
final List<MoodEntry> moodHistory = [];
  String? get mood => _mood;

set mood(String? value) {
  _mood = value;
  _saveData();
  notifyListeners();
}

// Add this method directly after the mood setter.
void addMoodEntry(String moodValue) {
  _mood = moodValue;

  moodHistory.insert(
    0,
    MoodEntry(
      mood: moodValue,
      recordedAt: DateTime.now(),
    ),
  );

  // Keep the latest 100 mood entries.
  if (moodHistory.length > 100) {
    moodHistory.removeRange(100, moodHistory.length);
  }

  _saveData();
  notifyListeners();
}


  Timer? _expiryTimer;

  final Map<int, DateTime> _lastCompletedAt = {};
  final List<TaskCompletion> completionHistory = [];
  int get totalTasksCompleted => completionHistory.length;
final List<ChildObservation> observations = [];
final List<FocusSession> focusSessions = [];
void addObservation({
  required String title,
  required String description,
  required String type,
}) {
  observations.insert(
    0,
    ChildObservation(
      title: title,
      description: description,
      timestamp: DateTime.now(),
      type: type,
    ),
  );

  // الاحتفاظ بأحدث 100 ملاحظة
  if (observations.length > 100) {
    observations.removeRange(100, observations.length);
  }

  _saveData();
  notifyListeners();
}
  final List<ChildTask> tasks = [
    const ChildTask(
      1, 'Brush your teeth', 'A fresh start!',
      Icons.cleaning_services_rounded, 10,
    ),
    const ChildTask(
      2, 'Pack your school bag', 'Get ready for tomorrow.',
      Icons.backpack_rounded, 15,
    ),
    const ChildTask(
      3, 'Read for 10 minutes', 'One page at a time.',
      Icons.menu_book_rounded, 20,
    ),
    const ChildTask(
      4, 'Tidy up your toys', 'Make your space shine.',
      Icons.toys_rounded, 15,
    ),
  ];

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) return;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      points = json['points'] as int? ?? 0;
      _nextRewardId = json['nextRewardId'] as int? ?? 1;

rewards
  ..clear()
  ..addAll(
    (json['rewards'] as List<dynamic>? ?? []).map(
      (item) => ChildReward.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    ),
  );

_achievedRewardIds
  ..clear()
  ..addAll(
    (json['achievedRewardIds'] as List<dynamic>? ?? [])
        .map((id) => id as int),
  );

// استرجاع أي أهداف تحققت قبل حفظ آخر حالة.
_updateAchievedRewards();

      _nextTaskId = json['nextTaskId'] as int? ?? 5;
      _mood = json['mood'] as String?;
      moodHistory
  ..clear()
  ..addAll(
    (json['moodHistory'] as List<dynamic>? ?? []).map(
      (item) => MoodEntry.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    ),
  );

      final savedTasks = json['tasks'] as List<dynamic>?;

      if (savedTasks != null) {
        tasks
          ..clear()
          ..addAll(savedTasks.map((item) {
            final map = item as Map<String, dynamic>;
            return ChildTask(
              map['id'] as int,
              map['title'] as String,
              map['subtitle'] as String,
              Icons.task_alt_rounded,
              map['points'] as int,
            );
          }));
      }

      _lastCompletedAt
        ..clear()
        ..addAll(
          (json['lastCompletedAt'] as Map<String, dynamic>? ?? {})
              .map((key, value) => MapEntry(
                    int.parse(key),
                    DateTime.parse(value as String),
                  )),
        );

     completionHistory
  ..clear()
  ..addAll(
    (json['completionHistory'] as List<dynamic>? ?? [])
        .map(
          (item) => TaskCompletion.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
  );

// Load saved Recent Observations
observations
  ..clear()
  ..addAll(
    (json['observations'] as List<dynamic>? ?? []).map(
      (item) => ChildObservation.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    ),
  );
  focusSessions
  ..clear()
  ..addAll(
    (json['focusSessions'] as List<dynamic>? ?? []).map(
      (item) => FocusSession.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    ),
  );

notifyListeners();
    } catch (e) {
      debugPrint('Could not load saved task data: $e');
    }
  }
  

Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();

  final json = {
    'points': points,
    'nextTaskId': _nextTaskId,
    'mood': _mood,
'moodHistory': moodHistory.map((entry) => entry.toJson()).toList(),
    'tasks': tasks.map((task) => {
          'id': task.id,
          'title': task.title,
          'subtitle': task.subtitle,
          'points': task.points,
        }).toList(),

    'lastCompletedAt': _lastCompletedAt.map(
      (key, value) => MapEntry(key.toString(), value.toIso8601String()),
    ),

    'completionHistory':
        completionHistory.map((record) => record.toJson()).toList(),

    // Save Recent Observations
    'observations': 
    observations.map((o) => o.toJson()).toList(),

    'focusSessions':
    focusSessions.map((session) => session.toJson()).toList(),
 
 'nextRewardId': _nextRewardId,

'rewards': rewards
    .map((reward) => reward.toJson())
    .toList(),

'achievedRewardIds': _achievedRewardIds.toList(),

 };

  await prefs.setString(_storageKey, jsonEncode(json));
}

void addFocusSession(int durationMinutes) {
  focusSessions.insert(
    0,
    FocusSession(
      durationMinutes: durationMinutes,
      completedAt: DateTime.now(),
    ),
  );

  // Keep the latest 100 focus sessions.
  if (focusSessions.length > 100) {
    focusSessions.removeRange(100, focusSessions.length);
  }

  _saveData();
  notifyListeners();
}

int get totalFocusMinutes {
  return focusSessions.fold(
    0,
    (total, session) => total + session.durationMinutes,
  );
}

int get completedFocusSessions => focusSessions.length;
  bool isCompleted(ChildTask task) {
    final completedAt = _lastCompletedAt[task.id];

    if (completedAt == null) return false;

    return DateTime.now().difference(completedAt) <
        const Duration(hours: 24);
  }

  DateTime? nextAvailableAt(ChildTask task) {
    final completedAt = _lastCompletedAt[task.id];

    if (completedAt == null) return null;

    final availableAt = completedAt.add(const Duration(hours: 24));

    return DateTime.now().isBefore(availableAt) ? availableAt : null;
  }
  Duration? remainingLockTime(ChildTask task) {
  final availableAt = nextAvailableAt(task);

  if (availableAt == null) return null;

  return availableAt.difference(DateTime.now());
}

  int get completedCount => tasks.where(isCompleted).length;

  int get totalPointsPossible =>
      tasks.fold(0, (sum, task) => sum + task.points);


bool completeTask(ChildTask task) {
  if (!tasks.any((item) => item.id == task.id)) return false;

  // منع إكمال المهمة مرة أخرى قبل مرور 24 ساعة.
  if (isCompleted(task)) return false;

  // يبدأ العد من لحظة ضغط الطفل على Done.
  final now = DateTime.now();
  _lastCompletedAt[task.id] = now;

  completionHistory.add(
    TaskCompletion(
      taskId: task.id,
      taskTitle: task.title,
      completedAt: now,
      pointsEarned: task.points,
    ),
  );

  // إضافة النقاط مرة واحدة عند إكمال المهمة.
points += task.points;
_updateAchievedRewards();
  observations.insert(
    0,
    ChildObservation(
      title: 'Task completed',
      description: 'Your child completed "${task.title}".',
      timestamp: now,
      type: 'task',
    ),
  );

  // الاحتفاظ بأحدث 100 ملاحظة.
  if (observations.length > 100) {
    observations.removeRange(100, observations.length);
  }

  // حفظ وقت الإكمال والحالة والنقاط.
  _saveData();
  notifyListeners();

  return true;
}

  void addTask({
    required String title,
    required String subtitle,
    required int points,
  }) {
    tasks.add(
      ChildTask(
        _nextTaskId++,
        title,
        subtitle,
        Icons.task_alt_rounded,
        points,
      ),
    );

    _saveData();
    notifyListeners();
  }

  void deleteTask(ChildTask task) {
    if (isCompleted(task)) return;

    tasks.removeWhere((item) => item.id == task.id);
    _lastCompletedAt.remove(task.id);

    _saveData();
    notifyListeners();
  }

  List<TaskCompletion> get weeklyCompletions {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    return completionHistory.where((record) {
      return !record.completedAt.isBefore(start) &&
          !record.completedAt.isAfter(now);
    }).toList();
  }

  int get weeklyCompletedCount => weeklyCompletions.length;

  int get weeklyPoints => weeklyCompletions.fold(
        0,
        (sum, record) => sum + record.pointsEarned,
      );

  int weeklyCompletionsForTask(int taskId) {
    return weeklyCompletions
        .where((record) => record.taskId == taskId)
        .length;
  }

  void _refreshExpiredTasks() {
    // isCompleted checks the actual time, so notify screens to refresh
    // when a task's 24-hour lock has expired.
    notifyListeners();
  }

// إضافة مكافأة جديدة بواسطة ولي الأمر.
void addReward({
  required String title,
  required String description,
  required int targetPoints,
}) {
  final cleanTitle = title.trim();
  final cleanDescription = description.trim();

  if (cleanTitle.isEmpty ||
      targetPoints <= 0 ||
      cleanDescription.isEmpty) {
    return;
  }

  rewards.add(
    ChildReward(
      id: _nextRewardId++,
      title: cleanTitle,
      description: cleanDescription,
      targetPoints: targetPoints,
    ),
  );

  _updateAchievedRewards();
  _saveData();
  notifyListeners();
}

// تعديل مكافأة موجودة.
void updateReward({
  required int id,
  required String title,
  required String description,
  required int targetPoints,
}) {
  final index = rewards.indexWhere((reward) => reward.id == id);

  if (index == -1 ||
      title.trim().isEmpty ||
      description.trim().isEmpty ||
      targetPoints <= 0) {
    return;
  }

  final oldReward = rewards[index];

  rewards[index] = ChildReward(
    id: oldReward.id,
    title: title.trim(),
    description: description.trim(),
    targetPoints: targetPoints,
    achievedAt: oldReward.achievedAt,
  );

  _updateAchievedRewards();
  _saveData();
  notifyListeners();
}

// حذف مكافأة.
void deleteReward(int id) {
  rewards.removeWhere((reward) => reward.id == id);
  _achievedRewardIds.remove(id);

  _saveData();
  notifyListeners();
}

// تحديث سجل المكافآت التي وصل الطفل إلى أهدافها.
  // تحديث المكافآت التي وصل الطفل إلى نقاطها المطلوبة
  void _updateAchievedRewards() {
    for (final reward in rewards) {
      if (points >= reward.targetPoints) {
        _achievedRewardIds.add(reward.id);
      }
    }
  }

  // هل حقق الطفل هذه المكافأة؟
  bool hasAchievedReward(ChildReward reward) {
    return _achievedRewardIds.contains(reward.id) ||
        points >= reward.targetPoints;
  }

  // تصفير النقاط فقط، دون حذف سجل المهام أو جلسات التركيز.
  Future<void> resetPoints() async {
    points = 0;
    await _saveData();
    notifyListeners();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
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
    final progress = data.tasks.isEmpty
    ? 0.0
    : data.completedCount / data.tasks.length;
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
            Expanded(child: _statCard(Icons.stars_rounded,
             '${data.points}', 'My points', const Color(0xFFFFB547),
             ),
             ),
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
         _navCard(
  'Focus Time',
  'Take one task at a time.',
  Icons.timer_rounded,
  childPrimary,
  () => open(const FocusTimerScreen()),
),

_navCard(
  'TOVA Attention Assessment',
  'Explore a supervised attention activity.',
  Icons.center_focus_strong_rounded,
  const Color(0xFF5C9FE8),
  () => open(const TovaWelcomeScreen()),
),
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
  final ChildAppState data = ChildAppState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: data,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: childBackground,
          appBar: AppBar(
            title: const Text('My Tasks'),
            backgroundColor: childBackground,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _whitePanel(
                Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: childPrimary,
                      size: 34,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${data.completedCount} of ${data.tasks.length} tasks completed',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              ...data.tasks.map((task) {
                final done = data.isCompleted(task);

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: childPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        task.icon,
                        color: childPrimary,
                      ),
                    ),
                   title: Text(
  task.title,
  style: TextStyle(
    decoration: done
        ? TextDecoration.lineThrough
        : TextDecoration.none,
    decorationThickness: 1.0,
    color: done ? Colors.grey : null,
  ),
),
                    subtitle: Text(
  done
      ? '🔒 Completed! Available again in 24 hours.'
      : '${task.subtitle}\n+${task.points} points',
),
                    isThreeLine: true,
                    trailing: IconButton(
                      onPressed: done
                          ? null
                          : () {
                              final success = data.completeTask(task);

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Awesome! +${task.points} points 🎉',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 30,
                        color: done
                            ? const Color(0xFF43B89C)
                            : childPrimary,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FocusTimerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.timer_rounded),
                label: const Text('Start Focus Time'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: childPrimary,
                  padding: const EdgeInsets.all(14),
                  side: const BorderSide(color: childPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() =>
      _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  static const List<int> presetMinutes = [5, 10, 15, 20, 25];

  final TextEditingController _customMinutesController =
      TextEditingController();

  int selectedMinutes = 10;
  int remainingSeconds = 10 * 60;

  Timer? timer;

  bool isRunning = false;
  bool isFinished = false;
  bool isCustomSelected = false;
  bool sessionSaved = false;

  final ChildAppState data = ChildAppState.instance;

  @override
  void dispose() {
    timer?.cancel();
    _customMinutesController.dispose();
    super.dispose();
  }

  void selectDuration(int minutes) {
    if (isRunning) return;

    if (minutes < 1 || minutes > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a duration between 1 and 180 minutes.'),
        ),
      );
      return;
    }

    timer?.cancel();

    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
      isRunning = false;
      isFinished = false;
      isCustomSelected = !presetMinutes.contains(minutes);
      sessionSaved = false;
    });
  }

  void chooseCustomDuration() {
    final minutes = int.tryParse(
      _customMinutesController.text.trim(),
    );

    if (minutes == null || minutes < 1 || minutes > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a whole number between 1 and 180 minutes.',
          ),
        ),
      );
      return;
    }

    selectDuration(minutes);
  }

  void startTimer() {
    if (isRunning) return;

    if (isFinished) {
      resetTimer();
      return;
    }

    if (remainingSeconds <= 0) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted) {
          t.cancel();
          return;
        }

        if (remainingSeconds <= 1) {
          t.cancel();

          setState(() {
            remainingSeconds = 0;
            isRunning = false;
            isFinished = true;
          });

          saveCompletedSession();
        } else {
          setState(() {
            remainingSeconds--;
          });
        }
      },
    );
  }

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      remainingSeconds = selectedMinutes * 60;
      isRunning = false;
      isFinished = false;
      sessionSaved = false;
    });
  }

  void saveCompletedSession() {
    if (sessionSaved) return;

    sessionSaved = true;

    data.addFocusSession(selectedMinutes);

    data.addObservation(
      title: 'Focus session completed',
      description:
          'Your child completed a $selectedMinutes-minute focus session.',
      type: 'focus',
    );
  }

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (remainingSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  double get progress {
    final totalSeconds = selectedMinutes * 60;

    if (totalSeconds <= 0) return 0;

    return 1 - (remainingSeconds / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(
        title: const Text(
          'Focus Time',
          style: TextStyle(
            color: childText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: childBackground,
        foregroundColor: childText,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    childPrimary,
                    Color(0xFF9B8FF0),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Focus Time ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose your time and take one small step.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              'How long would you like to focus?',
              style: TextStyle(
                color: childText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: presetMinutes.map((minutes) {
                final selected =
                    selectedMinutes == minutes &&
                    !isCustomSelected;

                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: selected,
                  onSelected: isRunning
                      ? null
                      : (_) => selectDuration(minutes),
                  selectedColor: childPrimary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : childText,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: selected
                        ? childPrimary
                        : const Color(0xFFE8E2F8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCustomSelected
                      ? childPrimary
                      : const Color(0xFFE8E2F8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose your own time',
                    style: TextStyle(
                      color: childText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customMinutesController,
                          keyboardType: TextInputType.number,
                          enabled: !isRunning,
                          decoration: InputDecoration(
                            hintText: 'Minutes (1–180)',
                            filled: true,
                            fillColor: childBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            isRunning ? null : chooseCustomDuration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: childPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Set'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Icon(
                    isFinished
                        ? Icons.emoji_events_rounded
                        : Icons.self_improvement_rounded,
                    color: isFinished
                        ? const Color(0xFFFFB547)
                        : childPrimary,
                    size: 56,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    isFinished
                        ? 'Amazing Job! '
                        : isRunning
                            ? 'You Can Do It!'
                            : 'Ready When You Are',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: childText,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isFinished
                        ? 'You completed your focus session!'
                        : 'Your goal: $selectedMinutes minutes',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                      color: childPrimary,
                      fontFeatures: [],
                    ),
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      color: childPrimary,
                      backgroundColor: childBackground,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isFinished
                                ? resetTimer
                                : isRunning
                                    ? pauseTimer
                                    : startTimer,
                            icon: Icon(
                              isFinished
                                  ? Icons.replay_rounded
                                  : isRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              isFinished
                                  ? 'Again'
                                  : isRunning
                                      ? 'Pause'
                                      : 'Start Focus',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: childPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: resetTimer,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: childPrimary,
                          minimumSize: const Size(58, 52),
                          side: const BorderSide(
                            color: childPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),

                  if (isFinished) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Take a little break. You did great! 🌟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: childText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            AnimatedBuilder(
              animation: data,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        color: childPrimary,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Focus Journey',
                              style: TextStyle(
                                color: childText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${data.completedFocusSessions} sessions completed',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${data.totalFocusMinutes} minutes focused in total',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
  void initState() {
    super.initState();
    selectedMood = data.mood;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(
        title: const Text('How Do I Feel?'),
        backgroundColor: childBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'How are you feeling today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'There are no wrong answers. Choose what feels right.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: moods.map((mood) {
                  final chosen = selectedMood == mood.$1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          selectedMood = mood.$1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: chosen
                              ? childPrimary.withValues(alpha: .13)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: chosen
                                ? childPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              mood.$2,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mood.$1,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: childText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mood.$3,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              chosen
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: chosen ? childPrimary : Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _primaryButton(
                'Save My Mood',
                Icons.favorite_rounded,
                selectedMood == null
                    ? null
                    : () {
                        final moodValue = selectedMood!;

                        data.addMoodEntry(moodValue);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thanks for sharing. '
                              'You feel ${moodValue.toLowerCase()} today ',
                            ),
                          ),
                        );

                        Navigator.pop(context);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildRewardsScreen extends StatelessWidget {
  const ChildRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, child) {
        final points = data.points;

        final rewards = [...data.rewards]
          ..sort(
            (a, b) => a.targetPoints.compareTo(b.targetPoints),
          );

        final unlockedCount = rewards
            .where((reward) => data.hasAchievedReward(reward))
            .length;

        final nextReward = rewards.cast<ChildReward?>().firstWhere(
          (reward) =>
              reward != null && !data.hasAchievedReward(reward),
          orElse: () => null,
        );

        final progress = nextReward == null
            ? 1.0
            : (points / nextReward.targetPoints)
                .clamp(0.0, 1.0)
                .toDouble();

        return Scaffold(
          backgroundColor: childBackground,
          appBar: AppBar(
            title: const Text(
              'My Rewards',
              style: TextStyle(
                color: childText,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: childBackground,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Current points
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      childPrimary,
                      Color(0xFF998BEA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your points',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$points',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$unlockedCount of ${rewards.length} rewards achieved',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Next reward
              _rewardPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your next goal 🎯',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: childText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (rewards.isEmpty) ...[
                      const Icon(
                        Icons.card_giftcard_rounded,
                        color: childPrimary,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your parent has not added any rewards yet.',
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ] else if (nextReward == null) ...[
                      const Text(
                        'Amazing! You achieved every reward! 🏆',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: childPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep completing tasks and collecting points.',
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(
                        value: 1,
                        minHeight: 10,
                        color: Color(0xFF43B89C),
                        backgroundColor: childBackground,
                      ),
                    ] else ...[
                      Text(
                        nextReward.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: childPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nextReward.description,
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(nextReward.targetPoints - points).clamp(0, nextReward.targetPoints)} more points to reach your goal.',
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          color: const Color(0xFFFFB547),
                          backgroundColor: childBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).round()}% towards your goal',
                        style: const TextStyle(
                          color: childPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$points / ${nextReward.targetPoints} points',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Your Rewards 🏆',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),

              const SizedBox(height: 12),

              if (rewards.isEmpty)
                _rewardPanel(
                  child: const Text(
                    'Your rewards will appear here once your parent adds them.',
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                )
              else
                ...rewards.map((reward) {
                  final achieved = data.hasAchievedReward(reward);

                  final progress = (points / reward.targetPoints)
                      .clamp(0.0, 1.0)
                      .toDouble();

                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: achieved
                            ? const Color(0xFFBDEBDD)
                            : const Color(0xFFECE7FA),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: (achieved
                                          ? const Color(0xFF43B89C)
                                          : const Color(0xFFFFB547))
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  achieved
                                      ? Icons.emoji_events_rounded
                                      : Icons.card_giftcard_rounded,
                                  color: achieved
                                      ? const Color(0xFF27966F)
                                      : const Color(0xFFE5A14C),
                                  size: 29,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reward.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: childText,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      reward.description,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      '${reward.targetPoints} points required',
                                      style: const TextStyle(
                                        color: childPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                achieved
                                    ? Icons.check_circle_rounded
                                    : Icons.lock_outline_rounded,
                                color: achieved
                                    ? const Color(0xFF43B89C)
                                    : Colors.grey,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          if (achieved)
                            const Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 17,
                                  color: Color(0xFF27966F),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Reward achieved! 🎉',
                                  style: TextStyle(
                                    color: Color(0xFF27966F),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                color: childPrimary,
                                backgroundColor: childBackground,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '$points / ${reward.targetPoints} points',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 10),

              _rewardPanel(
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: childPrimary,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Every step matters! 💜',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: childText,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Keep trying, complete your tasks, '
                            'and celebrate your progress.',
                            style: TextStyle(
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _rewardPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: childPrimary.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}


class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ChildAppState.instance;

    return AnimatedBuilder(
      animation: data,
      builder: (context, child) {
        final tasks = data.tasks;

        final progress = tasks.isEmpty
            ? 0.0
            : data.completedCount / tasks.length;

        final weeklyTasks = data.weeklyCompletedCount;
        final weeklyPoints = data.weeklyPoints;

        final now = DateTime.now();
        final weekStart = now.subtract(const Duration(days: 7));

        final weeklyFocusSessions = data.focusSessions.where((session) {
          return !session.completedAt.isBefore(weekStart) &&
              !session.completedAt.isAfter(now);
        }).toList();

        final weeklyFocusMinutes = weeklyFocusSessions.fold<int>(
          0,
          (total, session) => total + session.durationMinutes,
        );

        final recentTasks = data.weeklyCompletions.take(5).toList();
        final recentFocus = weeklyFocusSessions.take(5).toList();

        return Scaffold(
          backgroundColor: childBackground,
          appBar: AppBar(
            title: const Text(
              'My Progress',
              style: TextStyle(
                color: childText,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: childBackground,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Overall progress
              _whitePanel(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Look how far you’ve come! 🌟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: childText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.completedCount} of ${tasks.length} tasks completed today',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 12,
                        color: childPrimary,
                        backgroundColor: childBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).round()}% of tasks currently completed',
                      style: const TextStyle(
                        color: childPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),

              const SizedBox(height: 12),

              _infoCard(
                Icons.stars_rounded,
                'Total points collected',
                '${data.points}',
                const Color(0xFFFFB547),
              ),

              _infoCard(
                Icons.check_circle_rounded,
                'Total tasks completed',
                '${data.totalTasksCompleted}',
                const Color(0xFF43B89C),
              ),

              _infoCard(
                Icons.timer_rounded,
                'Focus sessions completed',
                '${data.completedFocusSessions}',
                const Color(0xFF5C9FE8),
              ),

              _infoCard(
                Icons.hourglass_bottom_rounded,
                'Total focus time',
                '${data.totalFocusMinutes} minutes',
                childPrimary,
              ),

             
_infoCard(
  Icons.mood_rounded,
  'Latest mood',
  data.mood ?? 'Not shared yet',
  const Color(0xFFE88EB3),
),

const SizedBox(height: 16),

// Mood History
_buildMoodHistory(data),

const SizedBox(height: 22),


              // Weekly activity
              const Text(
                'Your Last 7 Days 📅',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),

              const SizedBox(height: 12),

              _whitePanel(
                Column(
                  children: [
                    _weeklyRow(
                      Icons.check_circle_rounded,
                      'Tasks completed',
                      '$weeklyTasks',
                      const Color(0xFF43B89C),
                    ),
                    const Divider(height: 24),
                    _weeklyRow(
                      Icons.stars_rounded,
                      'Points earned',
                      '$weeklyPoints',
                      const Color(0xFFFFB547),
                    ),
                    const Divider(height: 24),
                    _weeklyRow(
                      Icons.timer_rounded,
                      'Focus sessions',
                      '${weeklyFocusSessions.length}',
                      const Color(0xFF5C9FE8),
                    ),
                    const Divider(height: 24),
                    _weeklyRow(
                      Icons.schedule_rounded,
                      'Focus minutes',
                      '$weeklyFocusMinutes',
                      childPrimary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Recent task history
              const Text(
                'Recent Task Achievements',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),

              const SizedBox(height: 12),

              if (recentTasks.isEmpty)
                _emptyProgress(
                  Icons.emoji_events_outlined,
                  'Your first achievement is waiting!',
                  'Complete a task to see it here.',
                )
              else
                ...recentTasks.map((record) {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE9F8F0),
                        child: Icon(
                          Icons.check_rounded,
                          color: Color(0xFF27966F),
                        ),
                      ),
                      title: Text(
                        record.taskTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: childText,
                        ),
                      ),
                      subtitle: Text(
                        _formatProgressDate(record.completedAt),
                      ),
                      trailing: Text(
                        '+${record.pointsEarned}',
                        style: const TextStyle(
                          color: childPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 22),

              // Recent focus history
              const Text(
                'Focus Journey ⏱️',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: childText,
                ),
              ),

              const SizedBox(height: 12),

              if (recentFocus.isEmpty)
                _emptyProgress(
                  Icons.self_improvement_rounded,
                  'Ready for your first focus session?',
                  'Choose a time in Focus Time and get started!',
                )
              else
                ...recentFocus.map((session) {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF0EDFF),
                        child: Icon(
                          Icons.timer_rounded,
                          color: childPrimary,
                        ),
                      ),
                      title: Text(
                        '${session.durationMinutes}-minute focus session',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: childText,
                        ),
                      ),
                      subtitle: Text(
                        _formatProgressDate(session.completedAt),
                      ),
                      trailing: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF43B89C),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              const Text(
                'Progress is about trying, not being perfect. 🌱',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weeklyRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: childText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: childText,
          ),
        ),
      ],
    );
  }

  Widget _emptyProgress(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: childPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: childText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatProgressDate(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/${local.year} • $hour:$minute';
  }
Widget _buildMoodHistory(ChildAppState data) {
  final history = data.moodHistory;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: childPrimary.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.favorite_rounded,
              color: childPrimary,
            ),
            SizedBox(width: 8),
            Text(
              'Mood History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: childText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Your recent feelings',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 14),

        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '💜',
                    style: TextStyle(fontSize: 36),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your mood journey starts here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Check in to record how you feel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...history.take(7).map((entry) {
            final moodInfo = _moodDetails(entry.mood);
            final date = entry.recordedAt;
            final dateText =
                '${date.day.toString().padLeft(2, '0')}/'
                '${date.month.toString().padLeft(2, '0')}/'
                '${date.year}';
            final timeText =
                '${date.hour.toString().padLeft(2, '0')}:'
                '${date.minute.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: childPrimary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      moodInfo.$2,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.mood,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: childText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$dateText • $timeText',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    ),
  );
}

(String, String) _moodDetails(String mood) {
  switch (mood) {
    case 'Happy':
      return ('Happy', '😊');
    case 'Calm':
      return ('Calm', '😌');
    case 'Sad':
      return ('Sad', '😢');
    case 'Angry':
      return ('Angry', '😠');
    case 'Worried':
      return ('Worried', '😟');
    default:
      return ('Unknown', '💜');
  }
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
