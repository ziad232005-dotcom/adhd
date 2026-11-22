import 'package:flutter/material.dart';

import 'child.dart' show childPrimary;

/// A ring that empties as the focus time runs out, with the time inside.
/// [remaining] goes from 1 (just started) to 0 (finished).
class FocusRing extends StatelessWidget {
  const FocusRing({super.key, required this.remaining, required this.label});

  final double remaining;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: remaining.clamp(0.0, 1.0),
              strokeWidth: 14,
              strokeCap: StrokeCap.round,
              color: childPrimary,
              backgroundColor: const Color(0xFFEDEAFB),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: childPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
