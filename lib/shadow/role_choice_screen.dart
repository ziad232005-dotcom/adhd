import 'package:flutter/material.dart';

import '../core/app_features.dart';
import '../core/mazid_theme.dart';
import '../core/widgets/mazid_widgets.dart';
import 'admin_applications_screen.dart';
import 'shadow_gate.dart';
import 'shadow_models.dart';
import 'shadow_store.dart';
import 'shadow_ui.dart';

/// Shown right after "Create Account": is this person a parent or a
/// Shadow Teacher?
class RoleChoiceScreen extends StatefulWidget {
  const RoleChoiceScreen({super.key, required this.onContinue});

  /// Called with the chosen role. The caller moves on to verification.
  final ValueChanged<ShadowRole> onContinue;

  @override
  State<RoleChoiceScreen> createState() => _RoleChoiceScreenState();
}

class _RoleChoiceScreenState extends State<RoleChoiceScreen> {
  ShadowRole _selected = ShadowRole.parent;

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: '',
      body: [
        const SizedBox(height: 8),
        const Center(child: MazidMascot(size: 110)),
        const SizedBox(height: 14),
        const Text(
          'How will you use MΛZID?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MazidColors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the role that fits you.\nYou can change it later from your profile.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MazidColors.textMuted,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 26),
        _RoleCard(
          icon: Icons.family_restroom_rounded,
          title: 'I’m a Parent',
          description: 'Support my child, manage tasks, routines and rewards.',
          badge: ShadowBadge(
            'Free to start',
            color: MazidColors.success,
            background: MazidColors.successSoft,
          ),
          selected: _selected == ShadowRole.parent,
          onTap: () => setState(() => _selected = ShadowRole.parent),
        ),
        const SizedBox(height: 14),
        _RoleCard(
          icon: Icons.school_rounded,
          title: 'I’m a Shadow Teacher',
          description:
              'Support children at school after a parent invites me.',
          badge: ShadowBadge(
            'Verification required',
            color: Color(0xFFB7791F),
            background: Color(0xFFFFF4DB),
          ),
          selected: _selected == ShadowRole.shadowTeacher,
          onTap: () => setState(() => _selected = ShadowRole.shadowTeacher),
        ),
        if (AppFeatures.demoMode) ...[
          const SizedBox(height: 18),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Skips the email code so the Shadow Teacher flow can be
                // tried without the backend.
                ShadowStore.instance.setRole(ShadowRole.shadowTeacher);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShadowTeacherGate(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: const Text('Open Shadow Teacher (demo, no code)'),
            ),
          ),
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
      ],
      bottom: MazidPrimaryButton(
        label: 'Continue',
        onPressed: () => widget.onContinue(_selected),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MazidColors.primary : MazidColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: MazidColors.softPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MazidColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: MazidColors.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: MazidColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  badge,
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? MazidColors.primary : MazidColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
