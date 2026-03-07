import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ExplosionComponent extends PositionComponent {
  final int particleCount = 8;
  final Random random = Random();

  ExplosionComponent({required Vector2 position}) {
    this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 80 + random.nextDouble() * 80;

      final particle = CircleComponent(
        radius: 4,
        paint: Paint()..color = Colors.redAccent,
        anchor: Anchor.center,
      );

      particle.add(
        MoveEffect.by(
          Vector2(cos(angle), sin(angle)) * speed,
          EffectController(duration: 0.3),
        ),
      );

      particle.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.3),
        ),
      );

      add(particle);
    }

    // Remove explosion after 0.35 sec
    add(
      TimerComponent(
        period: 0.35,
        removeOnFinish: true,
        onTick: () {
          removeFromParent();
        },
      ),
    );
  }
}