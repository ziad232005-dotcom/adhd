import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../parent/parent_store.dart';
import 'invite_teacher_screen.dart';
import 'shadow_ui.dart';
import 'teacher_directory_screen.dart';

/// Two doors, one gate: browse verified teachers, or invite someone the
/// parent already knows (including a teacher from the child's school).
/// Either way the teacher must be verified by MAZID before any request.
class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key, required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: 'Add Support Team Member',
      body: [
        const Text(
          'How would you like to add?',
          style: TextStyle(
            color: MazidColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'For ${child.name} • pick the option that fits you.',
          style: const TextStyle(color: MazidColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _Option(
          icon: Icons.search_rounded,
          title: 'Find a Verified Shadow Teacher',
          description: 'Browse teachers approved by the MAZID team.',
          tag: 'Verified only',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherDirectoryScreen(child: child),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Option(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Invite Someone I Know',
          description:
              'Your child’s school teacher or a teacher you already trust. '
              'Invite them by email or invite code.',
          tag: 'Email or code',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InviteTeacherScreen(child: child),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const ShadowNote.privacy(
          'Your child’s data stays private. Nobody sees it before you '
          'approve access.',
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.description,
    required this.tag,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: MazidColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MazidColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ShadowBadge(
                  tag,
                  color: MazidColors.success,
                  background: MazidColors.successSoft,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: MazidColors.primary),
        ],
      ),
    );
  }
}
