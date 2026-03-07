import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScorePopupComponent extends TextComponent {
  double lifeTime = 1.0;
  final bool isPenalty;

  ScorePopupComponent({
    required Vector2 position,
    this.isPenalty = false,
  }) : super(
          text: isPenalty ? "LIFE LOST" : "+1 THREAT ELIMINATED",
          position: position,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 80 * dt; // Float upwards
    lifeTime -= dt;

    if (lifeTime <= 0) {
      removeFromParent();
    } else {
      textRenderer = TextPaint(
        style: TextStyle(
          color: (isPenalty ? Colors.redAccent : Colors.greenAccent)
              .withValues(alpha: lifeTime.clamp(0.0, 1.0)),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
