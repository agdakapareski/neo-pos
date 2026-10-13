import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Uppercase mono label used for section headers and meta lines,
/// e.g. `// ITEM DETAIL //` or `TICKET #00084`.
class TerminalLabel extends StatelessWidget {
  const TerminalLabel(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.muted = false,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ?? AppTheme.labelMd;
    return Text(
      text.toUpperCase(),
      style: base.copyWith(
        color: color ??
            (muted ? AppTheme.onSurfaceVariant : base.color ?? AppTheme.onSurface),
      ),
    );
  }
}
