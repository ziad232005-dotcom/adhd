import 'package:flutter/material.dart';

import '../core/app_features.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'confirm_access_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'team_member_detail_screen.dart';

/// Where a connection request stands. It follows the request through
/// pending, accepted and active.
class RequestSentScreen extends StatelessWidget {
  const RequestSentScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final c = store.connectionById(connectionId);

        if (c == null) {
          return ShadowScaffold(
            title: 'Request',
            body: const [
              SizedBox(height: 40),
              Center(child: Text('This request was not found.')),
            ],
          );
        }

        final teacher = store.listingById(c.teacherId);
        final name = teacher?.name ?? 'the teacher';
        final first = name.split(' ').first;

        final String title;
        final String subtitle;

        switch (c.status) {
          case ConnectionStatus.awaitingTeacher:
            title = 'Request sent to $first';
            subtitle = 'We’ll show the answer here as soon as it arrives.';
          case ConnectionStatus.awaitingParent:
            title = '$first accepted';
            subtitle = 'Choose what they can see to finish.';
          case ConnectionStatus.active:
            title = '$first is on the team';
            subtitle = 'Access is active.';
          case ConnectionStatus.declined:
            title = '$first declined';
            subtitle = 'You can invite someone else.';
          case ConnectionStatus.revoked:
          case ConnectionStatus.cancelled:
            title = 'Request closed';
            subtitle = 'No access was given.';
        }

        // Only teachers from the example directory answer by demo; a real
        // teacher answers from their own app.
        final isSample = teacher != null &&
            store.applicationById(teacher.id) == null;

        return ShadowScaffold(
          title: 'Request status',
          body: [
            const SizedBox(height: 4),
            const Center(
              child: MazidMascot(
                size: 120,
                asset: MazidAssets.octopusCelebrate,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MazidColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MazidColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Center(child: ShadowBadge.connection(c.status)),
            const SizedBox(height: 20),
            ShadowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request for ${c.childName} • ${ShadowUi.shortDate(c.createdAt)}',
                    style: const TextStyle(
                      color: MazidColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Line(
                    'Request sent',
                    '$first got your invitation',
                    done: true,
                  ),
                  _Line(
                    '$first accepts',
                    c.status == ConnectionStatus.awaitingTeacher
                        ? 'Waiting for the answer'
                        : 'Answered',
                    done: c.status != ConnectionStatus.awaitingTeacher &&
                        c.status != ConnectionStatus.declined,
                  ),
                  _Line(
                    'You confirm access',
                    'Choose what they can see',
                    done: c.status == ConnectionStatus.active,
                    last: true,
                  ),
                ],
              ),
            ),
            if (c.status == ConnectionStatus.awaitingTeacher) ...[
              const SizedBox(height: 14),
              const ShadowNote(
                'The teacher answers from their own MAZID app, under '
                'Parent requests.',
              ),
              if (AppFeatures.demoMode && isSample) ...[
                const SizedBox(height: 10),
                MazidOutlineButton(
                  label: 'Demo: $first accepts',
                  borderColor: MazidColors.primary,
                  onPressed: () => store.teacherAccept(c.id),
                ),
              ],
            ],
          ],
          bottom: _bottom(context, store, c),
        );
      },
    );
  }

  Widget _bottom(
    BuildContext context,
    ShadowStore store,
    TeacherConnection c,
  ) {
    switch (c.status) {
      case ConnectionStatus.awaitingTeacher:
        return MazidOutlineButton(
          label: 'Cancel request',
          borderColor: MazidColors.error,
          onPressed: () {
            store.cancelRequest(c.id);
            Navigator.pop(context);
          },
        );
      case ConnectionStatus.awaitingParent:
        return MazidPrimaryButton(
          label: 'Review & confirm access',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmAccessScreen(connectionId: c.id),
            ),
          ),
        );
      case ConnectionStatus.active:
        return MazidPrimaryButton(
          label: 'View team member',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TeamMemberDetailScreen(connectionId: c.id),
            ),
          ),
        );
      default:
        return MazidPrimaryButton(
          label: 'Back to profile',
          onPressed: () => Navigator.pop(context),
        );
    }
  }
}

class _Line extends StatelessWidget {
  const _Line(this.title, this.subtitle, {required this.done, this.last = false});

  final String title;
  final String subtitle;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? MazidColors.success : MazidColors.border,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: done ? MazidColors.textDark : MazidColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
