import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_store.dart';
import 'send_request_screen.dart';
import 'shadow_models.dart';
import 'shadow_ui.dart';

/// Professional profile of a verified teacher. No contact details and
/// no child data are shown here.
class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({
    super.key,
    required this.teacher,
    required this.child,
  });

  final TeacherListing teacher;
  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: 'Profile',
      body: [
        Center(child: ShadowAvatar(initials: teacher.initials, size: 76)),
        const SizedBox(height: 12),
        Text(
          teacher.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MazidColors.textDark,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Center(child: ShadowBadge.verified(label: 'Verified Shadow Teacher')),
        const SizedBox(height: 8),
        Center(child: ShadowAvailability(available: teacher.available)),
        const SizedBox(height: 18),
        Row(
          children: [
            _Stat('${teacher.yearsExperience} yrs', 'Experience'),
            const SizedBox(width: 10),
            _Stat(
              teacher.adhdExperience.isEmpty ? '—' : teacher.adhdExperience,
              'ADHD',
            ),
            const SizedBox(width: 10),
            _Stat(teacher.governorate, 'Location'),
          ],
        ),
        const SizedBox(height: 14),
        ShadowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qualification',
                style: TextStyle(
                  color: MazidColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${teacher.qualification} • ${teacher.specialty}',
                style: const TextStyle(
                  color: MazidColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${teacher.university} • ${teacher.graduationYear}',
                style: const TextStyle(
                  color: MazidColors.textMuted,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const ShadowSectionTitle('Verified certificates', top: 18),
        ShadowCard(
          child: Column(
            children: [
              for (final cert in teacher.verifiedCertificates)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: MazidColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cert,
                          style: const TextStyle(
                            color: MazidColors.textBody,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const Text(
                        'Verified',
                        style: TextStyle(
                          color: MazidColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const ShadowNote.warning(
          'Verified means MAZID reviewed the documents. Review the profile '
          'and decide what’s right for your child.',
        ),
        const SizedBox(height: 10),
        const ShadowNote.privacy(
          'Contact details are shared only after you both agree to connect.',
        ),
      ],
      bottom: MazidPrimaryButton(
        label: !teacher.available
            ? 'Not available right now'
            : ShadowStore.instance.liveConnection(teacher.id, child.id) != null
                ? 'Request already sent'
                : 'Send Connection Request',
        onPressed: !teacher.available ||
                ShadowStore.instance.liveConnection(teacher.id, child.id) !=
                    null
            ? null
            : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SendRequestScreen(
              teacher: teacher,
              initialChild: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ShadowCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MazidColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: MazidColors.textMuted,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
