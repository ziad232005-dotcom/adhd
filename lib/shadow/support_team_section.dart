import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../parent/parent_store.dart';
import 'add_member_screen.dart';
import 'confirm_access_screen.dart';
import 'request_sent_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'team_member_detail_screen.dart';

/// "Support Team" block inside a child's profile: the parent, every
/// connected Shadow Teacher, and the button to add someone.
class SupportTeamSection extends StatelessWidget {
  const SupportTeamSection({super.key, required this.child});

  final ParentChild child;

  void _open(BuildContext context, TeacherConnection c) {
    final Widget screen;

    switch (c.status) {
      case ConnectionStatus.active:
        screen = TeamMemberDetailScreen(connectionId: c.id);
      case ConnectionStatus.awaitingParent:
        screen = ConfirmAccessScreen(connectionId: c.id);
      default:
        screen = RequestSentScreen(connectionId: c.id);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final team = store.connectionsForChild(child.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadowCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _MemberRow(
                    initials: 'You',
                    name: 'You',
                    role: 'Parent • Guardian',
                    badge: const ShadowBadge(
                      'Owner',
                      color: MazidColors.primary,
                      background: MazidColors.softPurple,
                    ),
                  ),
                  for (final c in team) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MemberRow(
                      initials: store.listingById(c.teacherId)?.initials ?? 'ST',
                      name: store.listingById(c.teacherId)?.name ??
                          'Shadow Teacher',
                      role: 'Shadow Teacher',
                      badge: ShadowBadge.connection(c.status),
                      onTap: () => _open(context, c),
                    ),
                  ],
                ],
              ),
            ),
            if (team.isEmpty) ...[
              const SizedBox(height: 10),
              const ShadowNote.privacy(
                'Add a verified Shadow Teacher to support your child at '
                'school. Nobody sees your child’s data until you approve.',
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMemberScreen(child: child),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Support Team Member'),
                style: FilledButton.styleFrom(
                  backgroundColor: MazidColors.primary,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.initials,
    required this.name,
    required this.role,
    required this.badge,
    this.onTap,
  });

  final String initials;
  final String name;
  final String role;
  final Widget badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ShadowAvatar(initials: initials, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: MazidColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      color: MazidColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            badge,
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: MazidColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
