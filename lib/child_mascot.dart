import 'package:flutter/material.dart';

import 'child.dart' show childPrimary;
import 'core/widgets/mazid_widgets.dart';

/// A greeting that fits the time of day.
String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The octopus picture that fits what the child is doing.
String mascotFor({required bool allDone, required bool hasPoints}) {
  if (allDone) return MazidAssets.octopusCelebrate;
  if (hasPoints) return MazidAssets.octopusHeart;
  return MazidAssets.octopus;
}

/// A snack bar with the celebrating octopus, shown when a task is done.
SnackBar celebrationSnackBar(String text) => SnackBar(
      backgroundColor: childPrimary,
      content: Row(
        children: [
          const MazidMascot(asset: MazidAssets.octopusCelebrate, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
