import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/mazid_theme.dart';
import 'incoming_request_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Home of a verified Shadow Teacher: their ID, parent requests and the
/// children they support. A child appears here only after the parent
/// has confirmed access.
class ShadowHomeScreen extends StatelessWidget {
  const ShadowHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;
    final app = store.myApplication;

    if (app == null) return const SizedBox.shrink();

    final incoming = store.incomingRequests;
    final children = store.myChildren;

    return ShadowScaffold(
      title: 'Shadow Teacher',
      showBack: false,
      body: [
        Row(
          children: [
            ShadowAvatar(
              initials: app.initials,
              size: 56,
              imagePath: app.photoPath,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.fullName,
                    style: const TextStyle(
                      color: MazidColors.textDark,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShadowBadge.verified(label: 'Verified Shadow Teacher'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ShadowCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Shadow Teacher ID',
                      style: TextStyle(
                        color: MazidColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.id,
                      style: const TextStyle(
                        color: MazidColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Invite code: ${app.inviteCode}',
                      style: const TextStyle(
                        color: MazidColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: app.inviteCode));
                  if (context.mounted) {
                    ShadowUi.snack(context, 'Invite code copied');
                  }
                },
                child: const Text('Copy code'),
              ),
            ],
          ),
        ),
        ShadowCard(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I’m available for new children',
                      style: TextStyle(
                        color: MazidColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Parents see this in the verified directory.',
                      style: TextStyle(
                        color: MazidColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: app.available,
                onChanged: ShadowStore.instance.setMyAvailability,
              ),
            ],
          ),
        ),
        const ShadowSectionTitle('Parent requests'),
        if (incoming.isEmpty)
          const ShadowCard(
            child: Text(
              'No requests yet. Share your invite code with a parent, or '
              'wait for a parent to find you in the verified directory.',
              style: TextStyle(
                color: MazidColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          )
        else
          for (final c in incoming)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadowCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomingRequestScreen(connectionId: c.id),
                  ),
                ),
                child: Row(
                  children: [
                    ShadowAvatar(
                      initials: c.parentName.isEmpty ? '?' : c.parentName[0],
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Wants you to support ${c.childName}',
                            style: const TextStyle(
                              color: MazidColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: MazidColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
        const ShadowSectionTitle('Children I support'),
        if (children.isEmpty)
          const ShadowCard(
            child: Text(
              'You’ll see a child here after you accept a request and the '
              'parent confirms access.',
              style: TextStyle(
                color: MazidColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          )
        else
          for (final c in children)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadowCard(
                child: Row(
                  children: [
                    ShadowAvatar(
                      initials: c.childName.isEmpty ? '?' : c.childName[0],
                      background: MazidColors.pinkSoft,
                      foreground: MazidColors.pink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.childName,
                            style: const TextStyle(
                              color: MazidColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            c.status == ConnectionStatus.active
                                ? 'Access: ${_summary(c)}'
                                : 'Waiting for ${c.parentName} to confirm access',
                            style: const TextStyle(
                              color: MazidColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ShadowBadge(
                      c.status == ConnectionStatus.active
                          ? 'Active'
                          : 'Waiting',
                      color: c.status == ConnectionStatus.active
                          ? MazidColors.success
                          : const Color(0xFFB7791F),
                      background: c.status == ConnectionStatus.active
                          ? MazidColors.successSoft
                          : const Color(0xFFFFF4DB),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  static String _summary(TeacherConnection c) {
    final names = <String>[
      for (final p in SharePermission.all)
        if (c.permissions[p.key] == true) p.title,
    ];
    return names.isEmpty ? 'none' : names.join(', ');
  }
}
