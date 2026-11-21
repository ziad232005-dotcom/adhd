import 'package:flutter/material.dart';

import '../child.dart';
import '../main.dart';
import '../parent/parent_store.dart';
import '../sync/result_sync.dart';

/// The only screen of a phone that belongs to a child. Leaving it needs the
/// parent's code.
class LinkedChildHome extends StatefulWidget {
  const LinkedChildHome({super.key, required this.child});

  final ParentChild child;

  @override
  State<LinkedChildHome> createState() => _LinkedChildHomeState();
}

class _LinkedChildHomeState extends State<LinkedChildHome> {
  @override
  void initState() {
    super.initState();
    // Results played without internet are sent now.
    ResultSync.instance.flush();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChildDashboardScreen(
        child: widget.child,
        onUnlock: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        ),
      ),
    );
  }
}
