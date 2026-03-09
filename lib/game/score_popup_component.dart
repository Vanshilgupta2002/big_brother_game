import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScorePopupComponent extends TextComponent {
  ScorePopupComponent({
    required Vector2 position,
    bool isPenalty = false,
    String? value,
  }) : super(
    text: value ?? (isPenalty ? "-1" : "+1"),
    position: position,
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: TextStyle(
        color: isPenalty
            ? Colors.redAccent
            : Colors.greenAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  double lifeTime = 0.6;

  @override
  void update(double dt) {
    super.update(dt);

    lifeTime -= dt;
    position.y -= 30 * dt;

    if (lifeTime <= 0) {
      removeFromParent();
    }
  }
}