import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';


class ThreatProgressBar extends PositionComponent
    with HasGameReference<BigBrotherGame> {

  double animatedProgress = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(game.size.x * 0.8, 12);
    position = Vector2(game.size.x * 0.1, 20);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final targetProgress =
        (game.maxThreats - game.remainingThreats) /
            game.maxThreats;

    // Smooth animation
    animatedProgress += (targetProgress - animatedProgress) * 6 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1);

    final fillPaint = Paint()
      ..color = animatedProgress > 0.8
          ? Colors.greenAccent
          : Colors.green;

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
  }
}