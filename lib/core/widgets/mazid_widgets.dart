import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mazid_theme.dart';

/// Paths of the octopus mascot images used across the app.
class MazidAssets {
  const MazidAssets._();

  static const String octopus = 'images/mazid/octopus.png';
  static const String octopusHeart = 'images/mazid/octopus_heart.png';
  static const String octopusCelebrate = 'images/mazid/octopus_celebrate.png';
  static const String octopusIdea = 'images/mazid/octopus_idea.png';
  static const String octopusGlasses = 'images/mazid/octopus_glasses.png';
  static const String octopusHeadphones =
      'images/mazid/octopus_headphones.png';
}

/// The MΛZID octopus mascot.
class MazidMascot extends StatelessWidget {
  const MazidMascot({
    super.key,
    this.asset = MazidAssets.octopus,
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
class MazidWave extends StatelessWidget {
  const MazidWave({super.key, this.height = 75});

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
      ..color = MazidColors.wave
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
class MazidAuthScaffold extends StatelessWidget {
  const MazidAuthScaffold({
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
      backgroundColor: MazidColors.background,
      body: Stack(
        children: [
          if (showWave)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MazidWave(),
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
                          color: MazidColors.textDark,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      MazidSpacing.screenPadding,
                      showBack ? 4 : MazidSpacing.screenPadding,
                      MazidSpacing.screenPadding,
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
class MazidAuthHeader extends StatelessWidget {
  const MazidAuthHeader({
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
        if (mascot != null) MazidMascot(asset: mascot!, size: mascotSize),
        if (mascot == null && icon != null)
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: MazidColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: MazidColors.primary),
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: MazidColors.textDark,
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
              color: MazidColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// Filled primary button (full width, pill shaped).
class MazidPrimaryButton extends StatelessWidget {
  const MazidPrimaryButton({
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
      height: MazidSpacing.buttonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: MazidColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: MazidColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: MazidTheme.fontFamily,
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
class MazidOutlineButton extends StatelessWidget {
  const MazidOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.borderColor = MazidColors.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: MazidColors.primary,
      backgroundColor: MazidColors.surface,
      side: BorderSide(color: borderColor, width: 1.5),
      shape: const StadiumBorder(),
      minimumSize: const Size(double.infinity, MazidSpacing.buttonHeight),
      textStyle: const TextStyle(
        fontFamily: MazidTheme.fontFamily,
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
class MazidFieldLabel extends StatelessWidget {
  const MazidFieldLabel(this.text, {super.key});

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
          color: MazidColors.textDark,
        ),
      ),
    );
  }
}

/// Labeled text field with a leading icon.
class MazidTextField extends StatelessWidget {
  const MazidTextField({
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
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final List<TextInputFormatter>? inputFormatters;
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
        MazidFieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autocorrect: autocorrect,
          inputFormatters: inputFormatters,
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
class MazidPasswordField extends StatefulWidget {
  const MazidPasswordField({
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
  State<MazidPasswordField> createState() => _MazidPasswordFieldState();
}

class _MazidPasswordFieldState extends State<MazidPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MazidFieldLabel(widget.label),
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
class MazidErrorBanner extends StatelessWidget {
  const MazidErrorBanner({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MazidColors.errorSoft,
        borderRadius: BorderRadius.circular(MazidSpacing.fieldRadius),
        border: Border.all(
          color: MazidColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: MazidColors.error,
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
                    color: MazidColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: MazidColors.textMuted,
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

/// Rules a password must follow to be accepted.
class MazidPasswordPolicy {
  const MazidPasswordPolicy._();

  static const int minLength = 8;

  static final RegExp _capital = RegExp(r'^[A-Z]');
  static final RegExp _special = RegExp(r'[^A-Za-z0-9\s]');

  static bool hasMinLength(String value) => value.length >= minLength;

  static bool startsWithCapital(String value) => _capital.hasMatch(value);

  static bool hasSpecialCharacter(String value) => _special.hasMatch(value);

  static bool isStrong(String value) =>
      hasMinLength(value) &&
      startsWithCapital(value) &&
      hasSpecialCharacter(value);
}

/// Live checklist that shows which password rules are already satisfied.
class MazidPasswordChecklist extends StatelessWidget {
  const MazidPasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rule(
              'At least ${MazidPasswordPolicy.minLength} characters',
              MazidPasswordPolicy.hasMinLength(text),
            ),
            _rule(
              'Starts with a capital letter',
              MazidPasswordPolicy.startsWithCapital(text),
            ),
            _rule(
              'Has a special character (. # @ !)',
              MazidPasswordPolicy.hasSpecialCharacter(text),
            ),
          ],
        );
      },
    );
  }

  Widget _rule(String label, bool satisfied) {
    final color = satisfied ? MazidColors.success : MazidColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

/// Shared form validators, so the same rules are not copied into every screen.
class MazidValidators {
  const MazidValidators._();

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email.';
    if (!_email.hasMatch(text)) return 'Please enter a valid email address.';
    return null;
  }

  static final RegExp _personName =
      RegExp(r'^[\p{L}\p{M}]+( [\p{L}\p{M}]+)*$', unicode: true);

  /// A name made of letters (any language) and single spaces only.
  static String? personName(String? value, String emptyMessage) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return emptyMessage;
    if (!_personName.hasMatch(text)) {
      return 'The name can only contain letters.';
    }
    if (text.replaceAll(' ', '').length < 2) {
      return 'The name is too short.';
    }
    return null;
  }

  /// Same rule as [personName], but an empty value is allowed.
  static String? optionalPersonName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return personName(value, '');
  }

  static String? requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';

    if (!MazidPasswordPolicy.hasMinLength(text)) {
      return 'Use at least ${MazidPasswordPolicy.minLength} characters.';
    }
    if (!MazidPasswordPolicy.startsWithCapital(text)) {
      return 'The first letter must be a capital letter.';
    }
    if (!MazidPasswordPolicy.hasSpecialCharacter(text)) {
      return 'Add a special character such as . # @ or !';
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

/// Input formatters shared by the forms.
class MazidInputFormatters {
  const MazidInputFormatters._();

  /// Letters (any language) and single spaces only. Digits, symbols and
  /// emojis are removed as the user types or pastes.
  static final List<TextInputFormatter> name = [_NameFormatter()];
}

class _NameFormatter extends TextInputFormatter {
  static final RegExp _notAllowed = RegExp(r'[^\p{L}\p{M} ]', unicode: true);
  static final RegExp _manySpaces = RegExp(r' {2,}');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text
        .replaceAll(_notAllowed, '')
        .replaceAll(_manySpaces, ' ')
        .trimLeft();

    if (cleaned == newValue.text) return newValue;

    final removed = newValue.text.length - cleaned.length;
    final offset = (newValue.selection.baseOffset - removed)
        .clamp(0, cleaned.length)
        .toInt();

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
