import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// A parent asked this verified teacher to support their child.
/// Before the parent confirms access, the teacher sees only the child's
/// first name and age.
class IncomingRequestScreen extends StatelessWidget {
  const IncomingRequestScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final c = store.connectionById(connectionId);

        if (c == null || c.status != ConnectionStatus.awaitingTeacher) {
          return ShadowScaffold(
            title: 'Connection request',
            children: const [
              SizedBox(height: 40),
              Center(child: Text('This request is no longer open.')),
            ],
          );
        }

        return ShadowScaffold(
          title: 'Connection request',
          children: [
            ShadowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShadowAvatar(
                        initials: c.parentName.isEmpty ? '?' : c.parentName[0],
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.parentName,
                              style: const TextStyle(
                                color: MazidColors.textDark,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Parent • wants you on their team',
                              style: TextStyle(
                                color: MazidColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  ShadowInfoRow('Child', c.childName),
                  ShadowInfoRow('Age', '${c.childAge} years'),
                ],
              ),
            ),
            const ShadowSectionTitle('What happens if you accept'),
            const _Step(
              1,
              'The parent chooses what you can see',
              'Activities, focus, behavior and mood',
            ),
            const _Step(
              2,
              'You support the child at school',
              'Add daily notes and reports',
            ),
            const _Step(
              3,
              'Either of you can end it anytime',
              'Access stops immediately',
            ),
            const SizedBox(height: 8),
            ShadowNote.privacy(
              'You see only ${c.childName}’s first name and age until '
              '${c.parentName} confirms access.',
            ),
          ],
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MazidPrimaryButton(
                label: 'Accept request',
                onPressed: () {
                  store.teacherAccept(c.id);
                  ShadowUi.snack(
                    context,
                    'Accepted. ${c.parentName} will confirm access.',
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              MazidOutlineButton(
                label: 'Decline',
                borderColor: MazidColors.error,
                onPressed: () {
                  store.teacherDecline(c.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.title, this.subtitle);

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: MazidColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: MazidColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
