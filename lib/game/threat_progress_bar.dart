import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'big_brother_game..dart';


class ThreatProgressBar extends PositionComponent
    with HasGameReference<BigBrotherGame> {

  final double barHeight = 18;
  final double segmentSpacing = 2;

  double shimmerOffset = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(game.size.x - 80, barHeight);
    position = Vector2(40, 25);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Subtle shimmer animation
    shimmerOffset += dt * 120;
    if (shimmerOffset > size.x) {
      shimmerOffset = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final maxThreats = game.maxThreats;
    final remaining = game.remainingThreats;
    final cleared = maxThreats - remaining;

    final segmentWidth =
        (size.x - ((maxThreats - 1) * segmentSpacing)) / maxThreats;

    // ===== Dynamic Color Shift =====
    Color barColor;
    if (remaining > 25) {
      barColor = Colors.redAccent;
    } else if (remaining > 10) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.greenAccent;
    }

    // ===== Outer Frame =====
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = barColor.withOpacity(0.8);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      framePaint,
    );

    // ===== Segments =====
    for (int i = 0; i < maxThreats; i++) {
      final x = i * (segmentWidth + segmentSpacing);

      final rect = Rect.fromLTWH(
        x,
        0,
        segmentWidth,
        size.y,
      );

      if (i < cleared) {
        canvas.drawRect(
          rect,
          Paint()..color = barColor.withOpacity(0.9),
        );
      } else {
        canvas.drawRect(
          rect,
          Paint()..color = Colors.white.withOpacity(0.05),
        );
      }
    }

    // ===== Subtle Shimmer Effect =====
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          barColor.withOpacity(0.25),
          Colors.transparent,
        ],
        stops: const [0.3, 0.5, 0.7],
      ).createShader(
        Rect.fromLTWH(
          shimmerOffset - 60,
          0,
          120,
          size.y,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      shimmerPaint,
    );

    // ===== Final Phase Pulse (≤10 threats) =====
    if (remaining <= 10 && !game.isGameOver) {
      final pulse =
          (sin(DateTime.now().millisecond / 1000 * pi * 2) + 1) / 2;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = barColor.withOpacity(0.15 * pulse),
      );
    }

    // ===== Percentage Text =====
    final percent =
    ((cleared / maxThreats) * 100).clamp(0, 100).toInt();

    final textPainter = TextPainter(
      text: TextSpan(
        text: "CONTROL INTEGRITY: $percent%",
        style: TextStyle(
          color: barColor,
          fontSize: 12,
          fontFamily: 'Courier',
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y + 4,
      ),
    );
  }
}