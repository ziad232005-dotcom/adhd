import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'shadow_home_screen.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';
import 'verification_form_screen.dart';
import 'verification_status_screen.dart';

/// Decides what a Shadow Teacher sees: the intro on the first visit,
/// the review status while waiting, and the home screen once verified.
/// A Shadow Teacher never reaches a child before being verified.
class ShadowTeacherGate extends StatelessWidget {
  const ShadowTeacherGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ShadowStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        switch (store.myStatus) {
          case ApplicationStatus.draft:
            return const ShadowIntroScreen();
          case ApplicationStatus.verified:
            return const ShadowHomeScreen();
          case ApplicationStatus.pendingReview:
          case ApplicationStatus.underVerification:
          case ApplicationStatus.infoRequired:
          case ApplicationStatus.rejected:
            return const VerificationStatusScreen();
        }
      },
    );
  }
}

/// First screen of the verification: what will happen and what to bring.
class ShadowIntroScreen extends StatelessWidget {
  const ShadowIntroScreen({super.key});

  void _start(BuildContext context) {
    ShadowStore.instance.ensureApplication();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = ShadowStore.instance.myApplication != null;

    return ShadowScaffold(
      title: 'Shadow Teacher',
      showBack: false,
      children: [
        const SizedBox(height: 4),
        const Center(
          child: MazidMascot(
            size: 110,
            asset: MazidAssets.octopusGlasses,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Become a verified',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MazidColors.textDark,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Shadow Teacher',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MazidColors.primary,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Parents trust MΛZID because every Shadow Teacher is checked before joining.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MazidColors.textMuted,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        const _Benefit(
          icon: Icons.verified_user_outlined,
          title: 'We verify your qualifications',
          subtitle: 'Degree and certificates are reviewed',
        ),
        const SizedBox(height: 10),
        const _Benefit(
          icon: Icons.lock_outline_rounded,
          title: 'Only your assigned child',
          subtitle: 'You see a child after the parent approves',
        ),
        const SizedBox(height: 10),
        const _Benefit(
          icon: Icons.schedule_rounded,
          title: 'Review takes 2–3 working days',
          subtitle: 'We notify you of the result',
        ),
        const ShadowSectionTitle('What you’ll need', top: 22),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _NeedChip('Your personal details'),
            _NeedChip('Degree certificate (PDF)'),
            _NeedChip('Optional: course certificates'),
          ],
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'Takes about 10 minutes • Your progress is saved',
            style: TextStyle(color: MazidColors.textMuted, fontSize: 12),
          ),
        ),
      ],
      bottom: MazidPrimaryButton(
        label: hasData ? 'Continue verification' : 'Start verification',
        onPressed: () => _start(context),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: MazidColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: MazidColors.primary, size: 22),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}

class _NeedChip extends StatelessWidget {
  const _NeedChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MazidColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: MazidColors.textBody,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
