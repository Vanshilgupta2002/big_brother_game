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
  final bool isPriority;

  late double lifeTime;
  bool wasTapped = false;

  Vector2? basePosition;
  double pulseTimer = 0;

  PersonComponent({
    required this.isRebel,
    required this.isSuspicious,
    required this.isPriority,
  }) : super(
    radius: 25,
    anchor: Anchor.center,
    paint: Paint()
      ..color = isPriority
          ? const Color(0xFFFFD700) // gold
          : isRebel
          ? Colors.red
          : (isSuspicious
          ? const Color(0xFF2E8B57)
          : Colors.green),
  );

  @override
  void onMount() {
    super.onMount();
    basePosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    lifeTime = isPriority
        ? 0.7
        : 1.0 + (game.random.nextDouble() * 0.8);
  }

  @override
  void update(double dt) {
    super.update(dt);

    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
      return;
    }

    // 🟡 Priority pulse (stronger)
    if (isPriority) {
      pulseTimer += dt * 6;
      final pulse = 1.0 + 0.15 * (0.5 + 0.5 * math.sin(pulseTimer));
      scale = Vector2.all(pulse);
      position = basePosition!;
    }

    // 🟥 Normal Rebel pulse
    else if (isRebel) {
      pulseTimer += dt * 4;
      final intensity =
      game.isFinalPhase ? 0.12 : 0.08;

      final pulse =
          1.0 + intensity * (0.5 + 0.5 * math.sin(pulseTimer));
      scale = Vector2.all(pulse);
      position = basePosition!;
    }

    // 🟡 Suspicious jitter
    else if (isSuspicious) {
      scale = Vector2.all(1.0);
      position = basePosition! +
          Vector2(
            (game.random.nextDouble() - 0.5) * 2,
            (game.random.nextDouble() - 0.5) * 2,
          );
    }

    // 🟢 Citizen
    else {
      scale = Vector2.all(1.0);
      position = basePosition!;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.isGameOver) return;

    game.useAuthority();
    if (game.isGameOver) {
      removeFromParent();
      return;
    }

    wasTapped = true;
    final impactPosition = absolutePosition.clone();
    if (isPriority) {
      game.increaseScore(amount: 2);

      // 🔥 Reward life bonus (max cap 5 optional)
      game.lives = (game.lives + 1).clamp(0, 5);
    }else if (isRebel) {
      game.increaseScore(amount: 1);
    } else {
      game.loseLife();
    }

    game.add(
      ExplosionComponent(position: impactPosition),
    );

    game.add(
      ScorePopupComponent(
        position: impactPosition,
        isPenalty: !isRebel && !isPriority,
        value: isPriority ? "+2  +1 LIFE" : null,
      ),
    );

    removeFromParent();
  }

  @override
  void onRemove() {
    // Normal rebels punish if missed
    if (isRebel && !isPriority && !wasTapped) {
      game.loseLife();
    }

    super.onRemove();
  }
}