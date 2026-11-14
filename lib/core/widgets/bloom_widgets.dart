import 'package:flutter/material.dart';

import '../bloom_theme.dart';

/// Paths of the octopus mascot images used across the app.
class BloomAssets {
  const BloomAssets._();

  static const String octopus = 'images/bloom/octopus.png';
  static const String octopusHeart = 'images/bloom/octopus_heart.png';
  static const String octopusCelebrate = 'images/bloom/octopus_celebrate.png';
  static const String octopusIdea = 'images/bloom/octopus_idea.png';
  static const String octopusGlasses = 'images/bloom/octopus_glasses.png';
  static const String octopusHeadphones =
      'images/bloom/octopus_headphones.png';
}

/// The Bloom octopus mascot.
class BloomMascot extends StatelessWidget {
  const BloomMascot({
    super.key,
    this.asset = BloomAssets.octopus,
    this.size = 96,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Soft wave decoration shown at the bottom of the authentication screens.
class BloomWave extends StatelessWidget {
  const BloomWave({super.key, this.height = 75});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(painter: _WavePainter()),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BloomColors.wave
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * -0.10,
        size.width * 0.42,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 1.10,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Page layout shared by the authentication screens: optional back button,
/// scrollable content and the bottom wave.
class BloomAuthScaffold extends StatelessWidget {
  const BloomAuthScaffold({
    super.key,
    required this.child,
    this.showBack = true,
    this.showWave = true,
  });

  final Widget child;
  final bool showBack;
  final bool showWave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BloomColors.background,
      body: Stack(
        children: [
          if (showWave)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BloomWave(),
            ),
          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: BloomColors.textDark,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      BloomSpacing.screenPadding,
                      showBack ? 4 : BloomSpacing.screenPadding,
                      BloomSpacing.screenPadding,
                      32,
                    ),
                    child: child,
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

/// Centered header: mascot (or icon badge), title and subtitle.
class BloomAuthHeader extends StatelessWidget {
  const BloomAuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.mascot,
    this.icon,
    this.mascotSize = 96,
  });

  final String title;
  final String? subtitle;
  final String? mascot;
  final IconData? icon;
  final double mascotSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (mascot != null) BloomMascot(asset: mascot!, size: mascotSize),
        if (mascot == null && icon != null)
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: BloomColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: BloomColors.primary),
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: BloomColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: BloomColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Filled primary button (full width, pill shaped).
class BloomPrimaryButton extends StatelessWidget {
  const BloomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: BloomSpacing.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: BloomColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: BloomColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: BloomTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Outlined secondary button (full width, pill shaped).
class BloomOutlineButton extends StatelessWidget {
  const BloomOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.borderColor = BloomColors.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: BloomColors.primary,
      backgroundColor: BloomColors.surface,
      side: BorderSide(color: borderColor, width: 1.5),
      shape: const StadiumBorder(),
      minimumSize: const Size(double.infinity, BloomSpacing.buttonHeight),
      textStyle: const TextStyle(
        fontFamily: BloomTheme.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon!,
        label: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

/// Small label shown above an input field.
class BloomFieldLabel extends StatelessWidget {
  const BloomFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: BloomColors.textDark,
        ),
      ),
    );
  }
}

/// Labeled text field with a leading icon.
class BloomTextField extends StatelessWidget {
  const BloomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BloomFieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autocorrect: autocorrect,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}

/// Labeled password field with a show/hide toggle.
class BloomPasswordField extends StatefulWidget {
  const BloomPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  State<BloomPasswordField> createState() => _BloomPasswordFieldState();
}

class _BloomPasswordFieldState extends State<BloomPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BloomFieldLabel(widget.label),
        TextFormField(
          controller: widget.controller,
          obscureText: _hidden,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              tooltip: _hidden ? 'Show password' : 'Hide password',
              icon: Icon(
                _hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline error message shown at the top of a form.
class BloomErrorBanner extends StatelessWidget {
  const BloomErrorBanner({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BloomColors.errorSoft,
        borderRadius: BorderRadius.circular(BloomSpacing.fieldRadius),
        border: Border.all(
          color: BloomColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: BloomColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BloomColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: BloomColors.textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared form validators, so the same rules are not copied into every screen.
class BloomValidators {
  const BloomValidators._();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email.';
    if (!_email.hasMatch(text)) return 'Please enter a valid email address.';
    return null;
  }

  static String? requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8 || digits.length > 15) {
      return 'Please enter a valid mobile number.';
    }
    return null;
  }
}
