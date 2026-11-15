import 'package:flutter/material.dart';

/// Colors and small shared widgets used by the parent screens.
class ParentUi {
  const ParentUi._();

  static const Color purple = Color(0xFF7566D9);
  static const Color dark = Color(0xFF30285E);
  static const Color soft = Color(0xFFF0EDFF);
  static const Color background = Color(0xFFFAF8FF);
  static const Color border = Color(0xFFEFEAFB);
  static const Color muted = Color(0xFF89849F);
  static const Color green = Color(0xFF39A875);
  static const Color red = Color(0xFFD64545);
}

PreferredSizeWidget parentAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: ParentUi.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ParentUi.dark,
            ),
          )
        : null,
    title: Text(
      title,
      style: const TextStyle(
        color: ParentUi.dark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: actions,
  );
}

class ParentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ParentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ParentUi.border),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: content,
    );
  }
}

class ParentEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ParentEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: ParentUi.purple),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ParentUi.dark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ParentUi.muted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ParentUi.purple,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showParentSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// "Today", "Tomorrow" or d/m/yyyy.
String parentDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = day.difference(today).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return '${date.day}/${date.month}/${date.year}';
}

String parentDateTimeLabel(BuildContext context, DateTime date) {
  return '${parentDayLabel(date)} • '
      '${TimeOfDay.fromDateTime(date).format(context)}';
}

String parentTimeAgo(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays} days ago';
}
