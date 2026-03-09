
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'big_brother_game..dart';

class ThreatProgressBar extends PositionComponent
    with HasGameReference<BigBrotherGame> {

  double animatedProgress = 0;
  @override
  Future<void> onLoad() async {
    size = Vector2(
      game.size.x - game.contentPadding * 2 - 24,
      12,
    );

    position = Vector2(
      game.contentPadding + 12,
      game.contentPadding + 5,
    );
  }
  @override
  void update(double dt) {
    super.update(dt);

    final targetProgress =
        (game.maxThreats - game.remainingThreats) /
            game.maxThreats;

    // Smooth animation
    animatedProgress +=
        (targetProgress - animatedProgress) * 6 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Background
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08);

    // Fill color becomes brighter near completion
    final fillPaint = Paint()
      ..color = animatedProgress > 0.75
          ? Colors.greenAccent
          : Colors.green;

    // Border (monitor style)
    final borderPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Background bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(6),
      ),
      backgroundPaint,
    );

    // Filled portion
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          size.x * animatedProgress,
          size.y,
        ),
        const Radius.circular(6),
      ),
      fillPaint,
    );

    // Subtle border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(6),
      ),
      borderPaint,
    );
  }
}