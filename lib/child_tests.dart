import 'package:flutter/material.dart';

import 'child.dart' show childBackground, childPrimary, childText;
import 'parent/parent_store.dart';

/// The "Tests" tab on the child's own screen: the attention test, and the
/// questionnaire that only a parent can open.
class ChildTestsScreen extends StatelessWidget {
  const ChildTestsScreen({
    super.key,
    required this.child,
    required this.onOpenTova,
    required this.onOpenCars,
  });

  final ParentChild child;
  final VoidCallback onOpenTova;
  final VoidCallback onOpenCars;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: childBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Tests',
          style: TextStyle(color: childText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: childBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _TestCard(
            icon: Icons.center_focus_strong_rounded,
            color: const Color(0xFF5C9FE8),
            title: 'Attention test (TOVA)',
            text: 'A short test that needs your full attention. '
                'Tap when you see the signal.',
            action: 'Start',
            onTap: onOpenTova,
          ),
          _TestCard(
            icon: Icons.fact_check_rounded,
            color: const Color(0xFF43B89C),
            title: 'CARS questionnaire',
            text: 'A parent answers these questions about ${child.name}. '
                'The parent code is needed.',
            action: 'Parent only',
            onTap: onOpenCars,
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: childText,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(color: childText, height: 1.4)),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: childPrimary,
                shape: const StadiumBorder(),
              ),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
