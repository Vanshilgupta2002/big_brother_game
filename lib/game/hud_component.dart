import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';


class HudComponent extends TextComponent {
  final BigBrotherGame gameRef;

  HudComponent(this.gameRef)
      : super(
    position: Vector2(10, 40), // Shifted down to prevent overlap with ThreatProgressBar
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.greenAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    text = """
THREATS REMAINING: ${gameRef.remainingThreats}
AUTHORITY LEFT: ${gameRef.remainingAuthority}
STABILITY: ${gameRef.lives}
""";
  }
}