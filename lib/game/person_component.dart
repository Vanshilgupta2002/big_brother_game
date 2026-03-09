import 'dart:math' as math;


import 'package:big_brother_game/game/explosion_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'big_brother_game..dart';
import 'score_popup_component.dart';

class PersonComponent extends CircleComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {
  final bool isRebel;
  final bool isSuspicious;

  late double lifeTime;
  bool wasTapped = false;

  // Motion identity
  Vector2? basePosition;
  double pulseTimer = 0;

  PersonComponent({
    required this.isRebel,
    required this.isSuspicious,
  }) : super(
    radius: 25,
    anchor: Anchor.center,
    paint: Paint()
      ..color = isRebel
          ? Colors.red
          : (isSuspicious
          ? const Color(0xFF2E8B57)
          : Colors.green),
  );

  @override
  Future<void> onLoad() async {
    lifeTime = 1.0 + (game.random.nextDouble() * 0.8);
    basePosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);

    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
      return;
    }

    // 🟥 Rebel → subtle pulse (scale animation)
    if (isRebel) {
      pulseTimer += dt * 4;
      final intensity = game.isFinalPhase ? 0.12 : 0.08;

      final pulse = 1.0 + intensity * (0.5 + 0.5 * math.sin(pulseTimer));
      scale = Vector2.all(pulse);
      position = basePosition!;
    }

    // 🟡 Suspicious → subtle jitter
    else if (isSuspicious) {
      scale = Vector2.all(1.0);
      position = basePosition! +
          Vector2(
            (game.random.nextDouble() - 0.5) * 2,
            (game.random.nextDouble() - 0.5) * 2,
          );
    }

    // 🟢 Citizen → completely stable
    else {
      scale = Vector2.all(1.0);
      position = basePosition!;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.isGameOver) return;

    game.useAuthority();

    // Stop logic if authority just ended the game
    if (game.isGameOver) {
      removeFromParent();
      return;
    }

    wasTapped = true;
    final impactPosition = absolutePosition.clone();

    if (isRebel) {
      game.increaseScore();

      game.add(
        ExplosionComponent(
          position: impactPosition,
        ),
      );

      game.add(
        ScorePopupComponent(
          position: impactPosition,
        ),
      );
    } else {
      game.loseLife();

      game.add(
        ExplosionComponent(
          position: impactPosition,
        ),
      );

      game.add(
        ScorePopupComponent(
          position: impactPosition,
          isPenalty: true,
        ),
      );
    }

    removeFromParent();
  }

  @override
  void onRemove() {
    if (isRebel && !wasTapped) {
      game.loseLife();
    }

    super.onRemove();
  }
}