import 'package:flutter/material.dart';

import '../child.dart';
import 'parent_store.dart';
import 'parent_ui.dart';

class ParentNotification {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final DateTime time;

  const ParentNotification({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });
}

/// Builds the notification list from real data: the child's activity,
/// reminders that are due and activities coming up in the next 24 hours.
List<ParentNotification> buildParentNotifications({
  List<Map<String, dynamic>> activities = const [],
}) {
  final now = DateTime.now();
  final child = ChildAppState.instance;
  final store = ParentStore.instance;
  final items = <ParentNotification>[];

  for (final observation in child.observations.take(30)) {
    final isTask = observation.type == 'task';
    items.add(
      ParentNotification(
        icon: isTask
            ? Icons.check_circle_outline_rounded
            : Icons.lightbulb_outline_rounded,
        color: isTask ? ParentUi.green : const Color(0xFFE5A14C),
        title: observation.title,
        body: observation.description,
        time: observation.timestamp,
      ),
    );
  }

  for (final reminder in store.reminders) {
    if (reminder.done || reminder.dueAt.isAfter(now)) continue;
    items.add(
      ParentNotification(
        icon: Icons.notifications_active_outlined,
        color: ParentUi.purple,
        title: 'Reminder',
        body: reminder.title,
        time: reminder.dueAt,
      ),
    );
  }

  final soon = now.add(const Duration(hours: 24));
  for (final activity in activities) {
    final date = DateTime.tryParse(activity['dateTime']?.toString() ?? '');
    if (date == null || date.isBefore(now) || date.isAfter(soon)) continue;
    items.add(
      ParentNotification(
        icon: Icons.event_note_rounded,
        color: ParentUi.purple,
        title: 'Upcoming activity',
        body: activity['title']?.toString() ?? 'Activity',
        time: date,
      ),
    );
  }

  items.sort((a, b) => b.time.compareTo(a.time));
  return items;
}

int unreadParentNotifications({
  List<Map<String, dynamic>> activities = const [],
}) {
  final readAt = ParentStore.instance.notificationsReadAt;
  final now = DateTime.now();

  return buildParentNotifications(activities: activities).where((n) {
    if (n.time.isAfter(now)) return false;
    return readAt == null || n.time.isAfter(readAt);
  }).length;
}

class NotificationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> activities;

  const NotificationsScreen({super.key, this.activities = const []});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final DateTime? _readAtWhenOpened;

  @override
  void initState() {
    super.initState();
    _readAtWhenOpened = ParentStore.instance.notificationsReadAt;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ParentStore.instance.markNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = ChildAppState.instance;
    final store = ParentStore.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Notifications'),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([child, store]),
          builder: (context, _) {
            final items = buildParentNotifications(
              activities: widget.activities,
            );

            if (items.isEmpty) {
              return const ParentEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'You are all caught up',
                message:
                    'Updates about your child’s tasks, reminders and '
                    'activities will appear here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final isNew = item.time.isBefore(DateTime.now()) &&
                    (_readAtWhenOpened == null ||
                        item.time.isAfter(_readAtWhenOpened));

                return ParentCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: ParentUi.dark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isNew)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: ParentUi.purple,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.body,
                              style: const TextStyle(
                                color: Color(0xFF817C98),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.time.isAfter(DateTime.now())
                                  ? parentDateTimeLabel(context, item.time)
                                  : parentTimeAgo(item.time),
                              style: const TextStyle(
                                color: ParentUi.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
          },
        ),
      ),
    );
  }
}
