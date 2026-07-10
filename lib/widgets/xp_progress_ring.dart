import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class XpProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int level;
  final Widget child;
  final double size;

  const XpProgressRing({
    super.key,
    required this.progress,
    required this.level,
    required this.child,
    this.size = 90.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom Gradient Progress Ring
          Positioned.fill(
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                trackColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Inside Avatar / Image
          SizedBox(
            width: size - 14,
            height: size - 14,
            child: ClipOval(
              child: child,
            ),
          ),
          
          // Floating Level Badge at Bottom
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF8E2DE2)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "LVL $level",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Gradient gradient;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw active progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Start from top (-pi / 2)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gradient != gradient;
  }
}
