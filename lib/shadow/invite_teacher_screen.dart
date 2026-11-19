import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import '../parent/parent_store.dart';
import 'request_sent_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Invite someone the parent already knows (a teacher from the child's
/// school, a private teacher), by email or by invite code.
///
/// A verified teacher gets a request right away. Anyone else can still
/// be invited by email: the invitation waits and is delivered once the
/// MAZID team verifies them. The child's data is never shared before
/// the teacher is verified and the parent confirms access.
class InviteTeacherScreen extends StatefulWidget {
  const InviteTeacherScreen({super.key, required this.child});

  final ParentChild child;

  @override
  State<InviteTeacherScreen> createState() => _InviteTeacherScreenState();
}

class _InviteTeacherScreenState extends State<InviteTeacherScreen> {
  final _controller = TextEditingController();
  final _schoolController = TextEditingController();

  bool _byEmail = true;
  bool _checked = false;
  TeacherListing? _found;
  bool _unverified = false;

  @override
  void dispose() {
    _controller.dispose();
    _schoolController.dispose();
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

  bool get _looksLikeEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_controller.text.trim());

  /// A waiting invitation is possible for any valid email that is not a
  /// verified teacher yet.
  bool get _canInviteUnverified =>
      _byEmail && _checked && _found == null && _looksLikeEmail;

  void _sendWaitingInvitation() {
    ShadowStore.instance.inviteByEmail(
      _controller.text,
      widget.child,
      schoolName: _schoolController.text,
    );

    Navigator.popUntil(
      context,
      (route) => route.settings.name == '/child-detail' || route.isFirst,
    );
    ShadowUi.snack(
      context,
      'Invitation saved. It reaches the teacher once they are verified.',
    );
  }

  void _send() {
    if (_canInviteUnverified) {
      _sendWaitingInvitation();
      return;
    }

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

    if (_canInviteUnverified) {
      return ShadowNote.warning(
        _unverified
            ? 'This teacher is registered but not verified yet. Your '
                'invitation will wait and be delivered as soon as the MAZID '
                'team verifies them.'
            : 'No MAZID account with this email yet. You can still invite '
                'them: ask them to register as a Shadow Teacher and get '
                'verified, and your invitation will reach them then.',
      );
    }

    return const ShadowNote.warning(
      'No verified Shadow Teacher found with this code. Check the spelling, '
      'or invite them by email instead.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: 'Invite someone I know',
      body: [
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
        if (_canInviteUnverified) ...[
          const SizedBox(height: 14),
          ShadowTextField(
            controller: _schoolController,
            label: 'School name (optional)',
            hint: 'If they are your child’s school teacher',
            required: false,
          ),
        ],
        const SizedBox(height: 18),
        const ShadowNote(
          'Nobody sees your child’s data until the teacher is verified by '
          'MAZID and you approve access.',
        ),
      ],
      bottom: MazidPrimaryButton(
        label: _found != null ? 'Send request' : 'Send invitation',
        onPressed: (_found != null || _canInviteUnverified) ? _send : null,
      ),
    );
  }
}
