import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CircularGauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String label;
  final String unit;
  final Color activeColor;

  const CircularGauge({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.label,
    required this.unit,
    this.activeColor = AppTheme.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: 190,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value.clamp(minValue, maxValue),
          minValue: minValue,
          maxValue: maxValue,
          activeColor: activeColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.0),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, letterSpacing: 1.1, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final Color activeColor;

  _GaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    const startAngle = 0.75 * pi; // 135 degrees
    const sweepAngle = 1.5 * pi;  // 270 degrees sweep

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final progressRatio = (value - minValue) / (maxValue - minValue);
    final progressSweep = sweepAngle * progressRatio.clamp(0.0, 1.0);

    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          activeColor.withOpacity(0.4),
          activeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.activeColor != activeColor;
}
