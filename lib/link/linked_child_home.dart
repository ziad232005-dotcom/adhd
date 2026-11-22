import 'package:flutter/material.dart';

import '../child.dart';
import '../main.dart';
import '../parent/parent_store.dart';
import '../sync/result_sync.dart';
import '../sync/task_sync.dart';

/// The only screen of a phone that belongs to a child. Leaving it needs the
/// parent's code.
class LinkedChildHome extends StatefulWidget {
  const LinkedChildHome({super.key, required this.child});

  final ParentChild child;

  @override
  State<LinkedChildHome> createState() => _LinkedChildHomeState();
}

class _LinkedChildHomeState extends State<LinkedChildHome>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  /// Sends results played without internet and reads the parent's newest
  /// tasks and rewards.
  void _refresh() {
    ResultSync.instance.flush();
    TaskSync.instance.pullIfLinked();
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
