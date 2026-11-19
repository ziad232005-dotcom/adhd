import 'package:flutter/material.dart';

import '../core/app_features.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'admin_applications_screen.dart';
import 'application_summary_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'verification_form_screen.dart';

/// What a Shadow Teacher sees after submitting: waiting, more
/// information needed, or rejected. Verified teachers see the home
/// screen instead.
class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;
    final app = store.myApplication;

    if (app == null) return const SizedBox.shrink();

    switch (app.status) {
      case ApplicationStatus.infoRequired:
        return _infoRequired(context, app);
      case ApplicationStatus.rejected:
        return _rejected(context, store, app);
      default:
        return _waiting(context, app);
    }
  }

  String _invitedText(List<ShadowInvitation> list) {
    final count = list.length;
    final schools = {
      for (final i in list)
        if (i.schoolName.isNotEmpty) i.schoolName,
    };
    final where = schools.isEmpty ? '' : ' (${schools.join(', ')})';

    return count == 1
        ? 'A parent$where invited you to support their child. Once you are '
            'verified, their request appears on your home screen.'
        : '$count parents$where invited you. Once you are verified, their '
            'requests appear on your home screen.';
  }

  Widget _header(String asset, String title, ApplicationStatus status) {
    return Column(
      children: [
        const SizedBox(height: 4),
        MazidMascot(size: 110, asset: asset),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MazidColors.textDark,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ShadowBadge.status(status),
      ],
    );
  }

  // ---------------------------------------------------------- waiting

  Widget _waiting(BuildContext context, ShadowApplication app) {
    return ShadowScaffold(
      title: 'Verification status',
      showBack: false,
      body: [
        _header(
          MazidAssets.octopusGlasses,
          'We’re reviewing your application',
          app.status,
        ),
        const SizedBox(height: 6),
        const Text(
          'Our team is checking your documents.',
          textAlign: TextAlign.center,
          style: TextStyle(color: MazidColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ShadowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application ${app.id} • Sent ${ShadowUi.shortDate(app.submittedAt)}',
                style: const TextStyle(
                  color: MazidColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              const _TimelineStep(
                title: 'Application submitted',
                subtitle: 'Your details and documents were received',
                state: _StepState.done,
              ),
              _TimelineStep(
                title: 'Under verification',
                subtitle: 'We check certificates and issuers',
                state: _StepState.now,
              ),
              const _TimelineStep(
                title: 'Additional information',
                subtitle: 'Only if we need something more',
                state: _StepState.todo,
              ),
              const _TimelineStep(
                title: 'Decision',
                subtitle: 'You’ll be notified in the app',
                state: _StepState.todo,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const ShadowNote.privacy(
          'Your account is restricted until you’re verified. You can’t see '
          'any child before then.',
        ),
        if (ShadowStore.instance.invitationsForMe.isNotEmpty) ...[
          const SizedBox(height: 14),
          ShadowNote(
            _invitedText(ShadowStore.instance.invitationsForMe),
            icon: Icons.mail_outline_rounded,
            color: MazidColors.success,
            background: MazidColors.successSoft,
          ),
        ],
        const SizedBox(height: 14),
        MazidOutlineButton(
          label: 'View my application',
          borderColor: MazidColors.primary,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplicationSummaryScreen(application: app),
            ),
          ),
        ),
        if (AppFeatures.demoMode)
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminApplicationsScreen(),
                ),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
              label: const Text('Admin review (demo)'),
            ),
          ),
      ],
    );
  }

  // ----------------------------------------------------- info required

  Widget _infoRequired(BuildContext context, ShadowApplication app) {
    return ShadowScaffold(
      title: 'Verification result',
      showBack: false,
      body: [
        _header(
          MazidAssets.octopusIdea,
          'We need a bit more information',
          app.status,
        ),
        const SizedBox(height: 20),
        ShadowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB7791F),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Message from the verification team',
                    style: TextStyle(
                      color: MazidColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                app.adminNote.isEmpty
                    ? 'Please review your documents and send them again.'
                    : app.adminNote,
                style: const TextStyle(
                  color: MazidColors.textBody,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (app.requestedItems.isNotEmpty) ...[
          const ShadowSectionTitle('Requested items'),
          for (final item in app.requestedItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShadowCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: Color(0xFFB7791F),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: MazidColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
      bottom: MazidPrimaryButton(
        label: 'Update my application',
        onPressed: () => _openForm(context),
      ),
    );
  }

  // ----------------------------------------------------------- rejected

  Widget _rejected(
    BuildContext context,
    ShadowStore store,
    ShadowApplication app,
  ) {
    return ShadowScaffold(
      title: 'Verification result',
      showBack: false,
      body: [
        _header(
          MazidAssets.octopus,
          'We couldn’t verify your account',
          app.status,
        ),
        const SizedBox(height: 20),
        ShadowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: MazidColors.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Reason',
                    style: TextStyle(
                      color: MazidColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                app.adminNote.isEmpty
                    ? 'We were unable to approve this application.'
                    : app.adminNote,
                style: const TextStyle(
                  color: MazidColors.textBody,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const ShadowSectionTitle('What you can do'),
        const _Bullet('Check that your certificate shows the issuer'),
        const _Bullet('Submit a new application with clear PDFs'),
        const _Bullet('Contact support if you think this is a mistake'),
      ],
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MazidPrimaryButton(
            label: 'Submit a new application',
            onPressed: () {
              store.reopenMyApplication();
              _openForm(context);
            },
          ),
          const SizedBox(height: 10),
          MazidOutlineButton(
            label: 'Contact support',
            borderColor: MazidColors.primary,
            onPressed: () => ShadowUi.snack(
              context,
              'Support contact will be added soon.',
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, now, todo }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    this.last = false,
  });

  final String title;
  final String subtitle;
  final _StepState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final Widget dot;

    switch (state) {
      case _StepState.done:
        dotColor = MazidColors.success;
        dot = Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: MazidColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        );
      case _StepState.now:
        dotColor = const Color(0xFFB7791F);
        dot = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4DB),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
        );
      case _StepState.todo:
        dotColor = MazidColors.border;
        dot = Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: MazidColors.border, width: 2),
          ),
        );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                dot,
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == _StepState.done
                          ? MazidColors.success
                          : MazidColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: state == _StepState.todo
                          ? MazidColors.textMuted
                          : MazidColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: MazidColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: MazidColors.textBody,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
