import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Primary bracket button: black fill, white mono label — `[ LABEL ]`.
///
/// Use for the main action on a screen (e.g. `[ PROCEED ]`, `[ COMPLETE ]`).
class BracketButton extends StatelessWidget {
  const BracketButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Widget child = Text(
      '[ $label ]',
      style: AppTheme.labelLg.copyWith(
        color: enabled ? AppTheme.onPrimary : AppTheme.outline,
      ),
    );

    final Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        disabledBackgroundColor: AppTheme.surfaceContainerHigh,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMd,
          vertical: AppTheme.spaceSm + 6,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
        ),
        textStyle: AppTheme.labelLg,
      ),
      child: child,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Secondary bracket button: white fill, black border and mono label — `[ LABEL ]`.
///
/// Use for secondary actions (e.g. `[ EXACT ]`, `[ REMOVE ITEM ]`).
class OutlineBracketButton extends StatelessWidget {
  const OutlineBracketButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color background = selected ? AppTheme.primary : AppTheme.surface;
    final Color foreground =
        selected ? AppTheme.onPrimary : AppTheme.onSurface;

    final Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppTheme.surface,
        disabledForegroundColor: AppTheme.outline,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm + 4,
          vertical: AppTheme.spaceSm,
        ),
        side: BorderSide(
          color: enabled ? AppTheme.onSurface : AppTheme.outlineVariant,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
        ),
        textStyle: AppTheme.labelMd,
      ),
      child: Text('[ $label ]', maxLines: 1, softWrap: false),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
