import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  DashedBorderPainter({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double startX = strokeWidth / 2;
    final double endX = size.width - strokeWidth / 2;
    final double startY = strokeWidth / 2;
    final double endY = size.height - strokeWidth / 2;

    // Draw top-left rounded corner
    final double radius = dashWidth / 2;
    final double controlPointDistance = radius * 0.55;
    final Offset topLeftStart = Offset(startX, startY + radius);
    final Offset topLeftEnd = Offset(startX + radius, startY);
    final Offset topLeftControlPoint1 =
        Offset(topLeftStart.dx, topLeftStart.dy - controlPointDistance);
    final Offset topLeftControlPoint2 =
        Offset(topLeftEnd.dx - controlPointDistance, topLeftEnd.dy);
    final Path topLeftPath = Path()
      ..moveTo(topLeftStart.dx, topLeftStart.dy)
      ..cubicTo(
          topLeftControlPoint1.dx,
          topLeftControlPoint1.dy,
          topLeftControlPoint2.dx,
          topLeftControlPoint2.dy,
          topLeftEnd.dx,
          topLeftEnd.dy);
    canvas.drawPath(topLeftPath, paint);

    // Draw top-right rounded corner
    final Offset topRightStart = Offset(endX - radius, startY);
    final Offset topRightEnd = Offset(endX, startY + radius);
    final Offset topRightControlPoint1 =
        Offset(topRightStart.dx + controlPointDistance, topRightStart.dy);
    final Offset topRightControlPoint2 =
        Offset(topRightEnd.dx, topRightEnd.dy - controlPointDistance);
    final Path topRightPath = Path()
      ..moveTo(topRightStart.dx, topRightStart.dy)
      ..cubicTo(
          topRightControlPoint1.dx,
          topRightControlPoint1.dy,
          topRightControlPoint2.dx,
          topRightControlPoint2.dy,
          topRightEnd.dx,
          topRightEnd.dy);
    canvas.drawPath(topRightPath, paint);

    // Draw bottom-right rounded corner
    final Offset bottomRightStart = Offset(endX, endY - radius);
    final Offset bottomRightEnd = Offset(endX - radius, endY);
    final Offset bottomRightControlPoint1 =
        Offset(bottomRightStart.dx, bottomRightStart.dy + controlPointDistance);
    final Offset bottomRightControlPoint2 =
        Offset(bottomRightEnd.dx + controlPointDistance, bottomRightEnd.dy);
    final Path bottomRightPath = Path()
      ..moveTo(bottomRightStart.dx, bottomRightStart.dy)
      ..cubicTo(
          bottomRightControlPoint1.dx,
          bottomRightControlPoint1.dy,
          bottomRightControlPoint2.dx,
          bottomRightControlPoint2.dy,
          bottomRightEnd.dx,
          bottomRightEnd.dy);
    canvas.drawPath(bottomRightPath, paint);

    // Draw bottom-left rounded corner
    final Offset bottomLeftStart = Offset(startX + radius, endY);
    final Offset bottomLeftEnd = Offset(startX, endY - radius);
    final Offset bottomLeftControlPoint1 =
        Offset(bottomLeftStart.dx - controlPointDistance, bottomLeftStart.dy);
    final Offset bottomLeftControlPoint2 =
        Offset(bottomLeftEnd.dx, bottomLeftEnd.dy + controlPointDistance);
    final Path bottomLeftPath = Path()
      ..moveTo(bottomLeftStart.dx, bottomLeftStart.dy)
      ..cubicTo(
          bottomLeftControlPoint1.dx,
          bottomLeftControlPoint1.dy,
          bottomLeftControlPoint2.dx,
          bottomLeftControlPoint2.dy,
          bottomLeftEnd.dx,
          bottomLeftEnd.dy);
    canvas.drawPath(bottomLeftPath, paint);

    // Draw dashed lines on top and bottom sides (excluding rounded corners)
    double currentX = startX + radius;
    while (currentX < endX - radius) {
      final double x1 = currentX;
      final double x2 = currentX + dashWidth;
      const double y1 = 0;
      const double y2 = 0;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint); // Top border

      final double y3 = size.height;
      final double y4 = size.height;
      canvas.drawLine(Offset(x1, y3), Offset(x2, y4), paint); // Bottom border

      currentX += dashWidth + dashSpace;
    }

    // Draw dashed lines on left and right sides (excluding rounded corners)
    double currentY = startY + radius;
    while (currentY < endY - radius) {
      const double x1 = 0;
      const double x2 = 0;
      final double y1 = currentY;
      final double y2 = currentY + dashWidth;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint); // Left border

      final double x3 = size.width;
      final double x4 = size.width;
      canvas.drawLine(Offset(x3, y1), Offset(x4, y2), paint); // Right border

      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
