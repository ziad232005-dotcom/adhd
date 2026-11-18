import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_store.dart';
import 'request_sent_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// The parent picks the child and what the teacher may see, then sends
/// the connection request.
class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({
    super.key,
    required this.teacher,
    required this.initialChild,
  });

  final TeacherListing teacher;
  final ParentChild initialChild;

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  late int _childId;
  final Map<String, bool> _permissions = SharePermission.defaults();

  @override
  void initState() {
    super.initState();
    _childId = widget.initialChild.id;
  }

  void _send() {
    final children = ParentStore.instance.children;
    final index = children.indexWhere((c) => c.id == _childId);
    if (index == -1) return;

    final connection = ShadowStore.instance.requestConnection(
      widget.teacher,
      children[index],
      permissions: _permissions,
    );

    // Replace this page so "back" returns to the child's profile.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => RequestSentScreen(connectionId: connection.id),
      ),
      (route) => route.settings.name == '/child-detail' || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = ParentStore.instance.children;
    final teacher = widget.teacher;

    return ShadowScaffold(
      title: 'Connection request',
      children: [
        ShadowCard(
          child: Row(
            children: [
              ShadowAvatar(initials: teacher.initials, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: const TextStyle(
                        color: MazidColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Verified Shadow Teacher',
                      style: TextStyle(
                        color: MazidColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ShadowSectionTitle('Which child?'),
        for (final c in children)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _childId = c.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _childId == c.id
                      ? const Color(0xFFF7F5FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _childId == c.id
                        ? MazidColors.primary
                        : MazidColors.border,
                    width: _childId == c.id ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    ShadowAvatar(
                      initials: c.name.isEmpty ? '?' : c.name[0].toUpperCase(),
                      size: 36,
                      background: MazidColors.pinkSoft,
                      foreground: MazidColors.pink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              color: MazidColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${c.age} years • ${c.grade}',
                            style: const TextStyle(
                              color: MazidColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _childId == c.id
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: _childId == c.id
                          ? MazidColors.primary
                          : MazidColors.border,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ShadowSectionTitle('What can ${teacher.name.split(' ').first} see?'),
        ShadowCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final p in SharePermission.all)
                ShadowPermissionTile(
                  title: p.title,
                  subtitle: p.subtitle,
                  value: _permissions[p.key] ?? false,
                  onChanged: (v) => setState(() => _permissions[p.key] = v),
                ),
              const ShadowPermissionTile(
                title: 'Family contact details',
                subtitle: 'Never shared before approval',
                value: false,
                locked: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'They must accept first, then you confirm access.',
            style: TextStyle(color: MazidColors.textMuted, fontSize: 12),
          ),
        ),
      ],
      bottom: MazidPrimaryButton(
        label: 'Send Connection Request',
        onPressed: _send,
      ),
    );
  }
}
