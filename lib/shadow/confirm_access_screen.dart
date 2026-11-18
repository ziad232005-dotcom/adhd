import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'team_member_detail_screen.dart';

/// The last step: the teacher accepted, and the parent decides exactly
/// what they may see before access starts.
class ConfirmAccessScreen extends StatefulWidget {
  const ConfirmAccessScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  State<ConfirmAccessScreen> createState() => _ConfirmAccessScreenState();
}

class _ConfirmAccessScreenState extends State<ConfirmAccessScreen> {
  final _store = ShadowStore.instance;
  Map<String, bool>? _permissions;

  void _confirm(TeacherConnection c) {
    _store.parentConfirm(c.id, _permissions ?? c.permissions);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TeamMemberDetailScreen(connectionId: c.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _store.connectionById(widget.connectionId);

    if (c == null || c.status != ConnectionStatus.awaitingParent) {
      return ShadowScaffold(
        title: 'Confirm access',
        body: const [
          SizedBox(height: 40),
          Center(child: Text('There is nothing to confirm here.')),
        ],
      );
    }

    final perms = _permissions ??= Map<String, bool>.of(c.permissions);
    final teacher = _store.listingById(c.teacherId);
    final name = teacher?.name ?? 'The teacher';

    return ShadowScaffold(
      title: 'Confirm access',
      body: [
        ShadowCard(
          color: MazidColors.successSoft,
          borderColor: MazidColors.successSoft,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: MazidColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${name.split(' ').first} accepted your request. Review '
                  'their access to ${c.childName}, then confirm.',
                  style: const TextStyle(
                    color: MazidColors.textDark,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ShadowCard(
          child: Row(
            children: [
              ShadowAvatar(initials: teacher?.initials ?? 'ST'),
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
                      ),
                    ),
                    Text(
                      'Shadow Teacher → ${c.childName}',
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
        ),
        const ShadowSectionTitle('Access you’re granting'),
        ShadowCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final p in SharePermission.all)
                ShadowPermissionTile(
                  title: p.title,
                  subtitle: p.subtitle,
                  value: perms[p.key] ?? false,
                  onChanged: (v) => setState(() => perms[p.key] = v),
                ),
              const ShadowPermissionTile(
                title: 'Family contact details',
                subtitle: 'Never shared with Shadow Teachers',
                value: false,
                locked: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'You can change this or revoke access anytime.',
            style: TextStyle(color: MazidColors.textMuted, fontSize: 12),
          ),
        ),
      ],
      bottom: ShadowActionBar(
        label: 'Confirm & activate',
        onBack: () => Navigator.pop(context),
        onPressed: () => _confirm(c),
      ),
    );
  }
}
