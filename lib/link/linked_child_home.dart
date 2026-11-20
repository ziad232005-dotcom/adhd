import 'package:flutter/material.dart';

import '../child.dart';
import '../main.dart';
import '../parent/parent_store.dart';

/// The only screen of a phone that belongs to a child. Leaving it needs the
/// parent's code.
class LinkedChildHome extends StatelessWidget {
  const LinkedChildHome({super.key, required this.child});

  final ParentChild child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChildDashboardScreen(
        child: child,
        onUnlock: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        ),
      ),
    );
  }
}
