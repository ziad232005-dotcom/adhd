import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_store.dart';
import 'request_sent_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Invite a Shadow Teacher the parent already knows, by email or by the
/// invite code the teacher shows on their home screen. Only verified
/// accounts can be invited.
class InviteTeacherScreen extends StatefulWidget {
  const InviteTeacherScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<InviteTeacherScreen> createState() => _InviteTeacherScreenState();
}

class _InviteTeacherScreenState extends State<InviteTeacherScreen> {
  final _controller = TextEditingController();

  bool _byEmail = true;
  bool _checked = false;
  TeacherListing? _found;
  bool _unverified = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final store = ShadowStore.instance;
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ShadowUi.snack(
        context,
        _byEmail ? 'Enter an email address.' : 'Enter an invite code.',
      );
      return;
    }

    setState(() {
      _checked = true;
      _found = store.findVerified(text);
      _unverified = _found == null && store.isKnownButUnverified(text);
    });
  }

  void _send() {
    final teacher = _found;
    if (teacher == null) return;

    final connection = ShadowStore.instance.requestConnection(
      teacher,
      widget.child,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => RequestSentScreen(connectionId: connection.id),
      ),
      (route) => route.settings.name == '/child-detail' || route.isFirst,
    );
  }

  Widget _result() {
    final teacher = _found;

    if (teacher != null) {
      return ShadowCard(
        color: MazidColors.successSoft,
        borderColor: MazidColors.successSoft,
        child: Row(
          children: [
            ShadowAvatar(
              initials: teacher.initials,
              size: 46,
              background: Colors.white,
              foreground: MazidColors.success,
            ),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified_user_rounded, color: MazidColors.success),
          ],
        ),
      );
    }

    if (_unverified) {
      return const ShadowNote.warning(
        'This teacher has an account but is not verified yet. You can invite '
        'them once the MAZID team verifies their documents.',
      );
    }

    return const ShadowNote.warning(
      'No verified Shadow Teacher found. Check the spelling, or ask them to '
      'register and get verified in MAZID first.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: 'Invite my Shadow Teacher',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Email')),
            ButtonSegment(value: false, label: Text('Invite code')),
          ],
          selected: {_byEmail},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() {
            _byEmail = s.first;
            _checked = false;
            _controller.clear();
          }),
        ),
        const SizedBox(height: 18),
        ShadowTextField(
          controller: _controller,
          label: _byEmail ? 'Shadow Teacher’s email' : 'Invite code',
          hint: _byEmail ? 'name@example.com' : 'MZD-1234-TCH',
          keyboardType:
              _byEmail ? TextInputType.emailAddress : TextInputType.text,
          textCapitalization: TextCapitalization.none,
          onChanged: (_) {
            if (_checked) setState(() => _checked = false);
          },
          suffix: TextButton(onPressed: _check, child: const Text('Check')),
        ),
        const SizedBox(height: 14),
        if (_checked) _result(),
        const SizedBox(height: 18),
        const ShadowNote(
          'Only verified accounts can be invited. Teachers find their invite '
          'code on their MAZID home screen after they are verified.',
        ),
      ],
      bottom: MazidPrimaryButton(
        label: 'Send invitation',
        onPressed: _found == null ? null : _send,
      ),
    );
  }
}
