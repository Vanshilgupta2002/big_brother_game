import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:big_brother_game/game/explosion_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'score_popup_component.dart';

class PersonComponent extends CircleComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {
  final bool isRebel;
  late double lifeTime;
  bool wasTapped = false;

  double blinkTimer = 0;
  bool showEye = true;


  final bool isSuspicious;


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
          ? const Color(0xFF2E8B57) // darker green
          : Colors.green),
  );

  @override
  Future<void> onLoad() async {
    lifeTime = 1.0 + (game.random.nextDouble() * 0.8);
  }
  @override
  void update(double dt) {
    super.update(dt);

    // 👁 Blink logic (used for rebel eye + suspicious pulse timing)
    blinkTimer += dt;
    if (blinkTimer >= 0.3) {
      blinkTimer = 0;
      showEye = !showEye;
    }

    // 🔍 Suspicious citizen pulsing (only if NOT rebel)
    if (isSuspicious && !isRebel) {
      position += Vector2(
        (game.random.nextDouble() - 0.5) * 1.5,
        (game.random.nextDouble() - 0.5) * 1.5,
      );
    }
    // ⏳ Lifetime logic
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }



  @override
  void onTapDown(TapDownEvent event) {
    wasTapped = true;

    final impactPosition = absolutePosition.clone();

    if (isRebel) {
      game.increaseScore();

      // 💥 Explosion effect
      game.add(
        ExplosionComponent(
          position: impactPosition,
        ),
      );

      // +1 popup
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
    // If rebel escaped (not tapped), lose life.
    // We must do this before calling super.onRemove() because game reference is detached afterwards.
    if (isRebel && !wasTapped) {
      game.loseLife();
    }

    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isRebel && showEye) {
      final eyePaint = Paint()..color = Colors.white;

      canvas.drawCircle(
        Offset(0, 0),
        6,
        eyePaint,
      );
    }
  }


}

