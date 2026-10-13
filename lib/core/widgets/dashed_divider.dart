import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dashed horizontal rule, the receipt-tape separator from the mockups.
class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color = AppTheme.onSurface,
    this.thickness = 1,
    this.dashLength = 6,
    this.gapLength = 4,
    this.height = 12,
  });

  final Color color;
  final double thickness;
  final double dashLength;
  final double gapLength;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          thickness: thickness,
          dashLength: dashLength,
          gapLength: gapLength,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double thickness;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    final double y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashLength, y), paint);
      x += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      thickness != oldDelegate.thickness ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength;
}
