import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleCheckPainter extends CustomPainter {
  final double circle1Progress;
  final double circle2Progress;
  final double shrinkProgress;
  final double dotsAndLinesProgress;
  final double checkProgress;
  final double rotationAngle;

  CircleCheckPainter({
    required this.circle1Progress,
    required this.circle2Progress,
    required this.shrinkProgress,
    required this.dotsAndLinesProgress,
    required this.checkProgress,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final minRadius = maxRadius * 0.5;
    final radius = maxRadius - (maxRadius - minRadius) * (1 - shrinkProgress);

    // Draw first thin circle
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5 * math.pi,
      circle1Progress * 2 * math.pi,
      false,
      circlePaint,
    );

    // Draw second thin circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -0.5 * math.pi,
      circle2Progress * 2 * math.pi,
      false,
      circlePaint,
    );

    // Draw rotating dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final numberOfDots = 40;
    final angleStep = 2 * math.pi / numberOfDots;
    final dotRadius = 1.5;

    for (int i = 0; i < numberOfDots; i++) {
      final dotProgress = (dotsAndLinesProgress * numberOfDots - i).clamp(0.0, 1.0);
      if (dotProgress <= 0) continue;

      final angle = i * angleStep + rotationAngle;
      final dotCenter = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, dotRadius * dotProgress, dotPaint);
    }

    // Draw lines around the circle
    if (dotsAndLinesProgress > 0) {
      final linePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final numberOfLines = 60;
      final lineAngleStep = 2 * math.pi / numberOfLines;
      final maxLineLength = 20.0;
      final lineStartDistance = 10.0;

      for (int i = 0; i < numberOfLines; i++) {
        final progress = (dotsAndLinesProgress * numberOfLines - i).clamp(0.0, 1.0);
        if (progress <= 0) continue;

        final angle = i * lineAngleStep;
        final lineLength = maxLineLength * progress;
        final startPoint = Offset(
          center.dx + (radius + lineStartDistance) * math.cos(angle),
          center.dy + (radius + lineStartDistance) * math.sin(angle),
        );
        final endPoint = Offset(
          center.dx + (radius + lineStartDistance + lineLength) * math.cos(angle),
          center.dy + (radius + lineStartDistance + lineLength) * math.sin(angle),
        );

        linePaint.color = Colors.white.withOpacity(progress);

        canvas.drawLine(startPoint, endPoint, linePaint);
      }
    }

    // Draw green circle background for checkmark
    if (checkProgress > 0) {
      final greenCirclePaint = Paint()
        ..color = const Color.fromARGB(255, 18, 249, 147)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, minRadius * 0.5 * checkProgress, greenCirclePaint);

      // Draw smaller white checkmark
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(center.dx - minRadius * 0.2, center.dy);
      path.lineTo(center.dx - minRadius * 0.05, center.dy + minRadius * 0.15);
      path.lineTo(center.dx + minRadius * 0.2, center.dy - minRadius * 0.15);

      final pathMetrics = path.computeMetrics().first;
      final extractPath = pathMetrics.extractPath(0, pathMetrics.length * checkProgress);

      canvas.drawPath(extractPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}