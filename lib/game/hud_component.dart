
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'big_brother_game..dart';

class HudComponent extends TextComponent {
  final BigBrotherGame gameRef;

  HudComponent(this.gameRef)
      : super(
    position: Vector2(
      gameRef.contentPadding + 12,
      gameRef.contentPadding + 28,
    ),
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);

    text =
    "THREATS REMAINING: ${gameRef.remainingThreats}\n"
        "AUTHORITY LEFT: ${gameRef.remainingAuthority}\n"
        "STABILITY: ${gameRef.lives}";
  }
}