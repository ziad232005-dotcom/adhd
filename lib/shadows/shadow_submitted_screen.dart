import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import 'shadow_ui.dart';

/// Shown after the form was sent. The teacher has no account, so the
/// reference number is what they keep.
class ShadowSubmittedScreen extends StatelessWidget {
  const ShadowSubmittedScreen({super.key, required this.reference});

  final int reference;

  @override
  Widget build(BuildContext context) {
    return ShadowScaffold(
      title: 'Shadow Teacher',
      showBack: false,
      body: [
        const SizedBox(height: 40),
        const Center(
          child: Icon(
            Icons.check_circle_rounded,
            size: 76,
            color: MazidColors.success,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Sent for review',
            style: TextStyle(
              color: MazidColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Your reference number is SH-${reference.toString().padLeft(4, '0')}.\n'
            'After the admin checks your documents, parents will see you in '
            'the Shadow Teachers list.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: MazidColors.textBody, height: 1.5),
          ),
        ),
      ],
      bottom: ShadowActionBar(
        label: 'Done',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
