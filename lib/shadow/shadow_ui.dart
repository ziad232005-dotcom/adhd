import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/mazid_theme.dart';
import 'shadow_models.dart';

/// Small shared pieces for the Shadow Teacher screens.
class ShadowUi {
  const ShadowUi._();

  static const double pad = 24;

  static (Color, Color) statusColors(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.draft:
        return (MazidColors.textMuted, const Color(0xFFF2F1F7));
      case ApplicationStatus.pendingReview:
        return (const Color(0xFFB7791F), const Color(0xFFFFF4DB));
      case ApplicationStatus.underVerification:
        return (MazidColors.primary, MazidColors.softPurple);
      case ApplicationStatus.infoRequired:
        return (const Color(0xFFB4541A), const Color(0xFFFFEBDD));
      case ApplicationStatus.verified:
        return (MazidColors.success, MazidColors.successSoft);
      case ApplicationStatus.rejected:
        return (MazidColors.error, MazidColors.errorSoft);
    }
  }

  static (Color, Color) connectionColors(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.active:
        return (MazidColors.success, MazidColors.successSoft);
      case ConnectionStatus.awaitingTeacher:
        return (const Color(0xFFB7791F), const Color(0xFFFFF4DB));
      case ConnectionStatus.awaitingParent:
        return (MazidColors.primary, MazidColors.softPurple);
      default:
        return (MazidColors.textMuted, const Color(0xFFF2F1F7));
    }
  }

  static String date(DateTime? value) {
    if (value == null) return '';
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d / $m / ${value.year}';
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String shortDate(DateTime? value) {
    if (value == null) return '';
    return '${value.day} ${_months[value.month - 1]} ${value.year}';
  }

  static void snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A page with the MAZID background, an app bar and optional bottom
/// buttons that stay visible.
class ShadowScaffold extends StatelessWidget {
  const ShadowScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.showBack = true,
    this.actions,
    this.padding = const EdgeInsets.fromLTRB(ShadowUi.pad, 8, ShadowUi.pad, 24),
  });

  final String title;
  final List<Widget> body;
  final Widget? bottom;
  final bool showBack;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MazidColors.background,
      appBar: AppBar(
        backgroundColor: MazidColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBack
            ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: MazidColors.textDark,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: MazidColors.border),
                  ),
                ),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: MazidColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(padding: padding, children: body),
          ),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ShadowUi.pad,
                      8,
                      ShadowUi.pad,
                      16,
                    ),
                    child: bottom,
                  ),
                ),
              ),
            ),
    );
  }
}

class ShadowCard extends StatelessWidget {
  const ShadowCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Colors.white,
    this.borderColor = MazidColors.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MazidSpacing.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );

    if (onTap == null) return box;

    return InkWell(
      borderRadius: BorderRadius.circular(MazidSpacing.cardRadius),
      onTap: onTap,
      child: box,
    );
  }
}

class ShadowBadge extends StatelessWidget {
  const ShadowBadge(
    this.label, {
    super.key,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  factory ShadowBadge.status(ApplicationStatus status, {Key? key}) {
    final (fg, bg) = ShadowUi.statusColors(status);
    return ShadowBadge(status.label, key: key, color: fg, background: bg);
  }

  factory ShadowBadge.connection(ConnectionStatus status, {Key? key}) {
    final (fg, bg) = ShadowUi.connectionColors(status);
    return ShadowBadge(status.label, key: key, color: fg, background: bg);
  }

  factory ShadowBadge.verified({Key? key, String label = 'Verified'}) {
    return ShadowBadge(
      label,
      key: key,
      color: MazidColors.success,
      background: MazidColors.successSoft,
      icon: Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tinted note with an icon (privacy, warning, hint).
class ShadowNote extends StatelessWidget {
  const ShadowNote(
    this.text, {
    super.key,
    this.icon = Icons.info_outline_rounded,
    this.color = MazidColors.primary,
    this.background = MazidColors.softPurple,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  const ShadowNote.warning(this.text, {super.key})
      : icon = Icons.info_outline_rounded,
        color = const Color(0xFFB7791F),
        background = const Color(0xFFFFF4DB);

  const ShadowNote.privacy(this.text, {super.key})
      : icon = Icons.lock_outline_rounded,
        color = MazidColors.primary,
        background = MazidColors.softPurple;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: MazidColors.textDark,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowAvatar extends StatelessWidget {
  const ShadowAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.imagePath,
    this.background = MazidColors.softPurple,
    this.foreground = MazidColors.primary,
  });

  final String initials;
  final double size;
  final String? imagePath;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: path != null
          ? Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _text(),
            )
          : _text(),
    );
  }

  Widget _text() {
    return Text(
      initials,
      style: TextStyle(
        color: foreground,
        fontSize: size * 0.34,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ShadowSectionTitle extends StatelessWidget {
  const ShadowSectionTitle(this.text, {super.key, this.top = 22});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: MazidColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Label + value on one row (summary and review screens).
class ShadowInfoRow extends StatelessWidget {
  const ShadowInfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: MazidColors.textMuted,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: MazidColors.textBody,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row with a switch, used for what a teacher may see.
class ShadowPermissionTile extends StatelessWidget {
  const ShadowPermissionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: locked
                        ? MazidColors.textMuted
                        : MazidColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: MazidColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: MazidColors.textMuted,
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: MazidColors.primary,
            ),
        ],
      ),
    );
  }
}

/// Bottom pair of buttons: Back + main action.
class ShadowActionBar extends StatelessWidget {
  const ShadowActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.onBack,
    this.backLabel = 'Back',
    this.destructive = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onBack;
  final String backLabel;
  final bool destructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? MazidColors.error : MazidColors.primary;

    final main = SizedBox(
      height: MazidSpacing.buttonHeight,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: MazidTheme.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        label: Text(label),
      ),
    );

    if (onBack == null) return main;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: MazidSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: MazidColors.primary,
                side: const BorderSide(
                  color: MazidColors.primary,
                  width: 1.5,
                ),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontFamily: MazidTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(backLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: main),
      ],
    );
  }
}

/// A dropdown that looks like the rest of the form fields.
class ShadowDropdown extends StatelessWidget {
  const ShadowDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Select',
    this.required = true,
    this.errorText,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final current = options.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label, required: required),
        DropdownButtonFormField<String>(
          initialValue: current,
          isExpanded: true,
          hint: Text(hint),
          decoration: InputDecoration(errorText: errorText),
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// Date field that opens the date picker.
class ShadowDateField extends StatelessWidget {
  const ShadowDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.required = true,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label, required: required),
        InkWell(
          borderRadius: BorderRadius.circular(MazidSpacing.fieldRadius),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (picked != null) onPicked(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            child: Text(
              value == null ? 'DD / MM / YYYY' : ShadowUi.date(value),
              style: TextStyle(
                color: value == null
                    ? MazidColors.textMuted
                    : MazidColors.textBody,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Text field with the label above it and an optional required star.
class ShadowTextField extends StatelessWidget {
  const ShadowTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.required = true,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label, required: required),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.required});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: MazidColors.error),
              ),
          ],
        ),
        style: const TextStyle(
          color: MazidColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
