import 'package:flutter/material.dart';

import 'child.dart' show childPrimary;
import 'core/ambient.dart';

/// Turns the calm background sound on or off.
class AmbientButton extends StatelessWidget {
  const AmbientButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Ambient.instance,
      builder: (_, _) => IconButton(
        tooltip: Ambient.instance.enabled ? 'Sound on' : 'Sound off',
        onPressed: Ambient.instance.toggle,
        icon: Icon(
          Ambient.instance.enabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          color: childPrimary,
        ),
      ),
    );
  }
}
