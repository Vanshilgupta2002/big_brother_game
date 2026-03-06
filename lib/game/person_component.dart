import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';



class PersonComponent extends CircleComponent
    with TapCallbacks, HasGameRef<BigBrotherGame> {
  final bool isRebel;
  double lifeTime = 1.5;
  bool wasTapped = false;

  double blinkTimer = 0;
  bool showEye = true;

  PersonComponent({required this.isRebel})
      : super(
    radius: 25,
    anchor: Anchor.center,
    paint: Paint()
      ..color = isRebel ? Colors.red : Colors.green,
  );
  @override
  void update(double dt) {
    super.update(dt);

    // 👁 Blink logic
    blinkTimer += dt;
    if (blinkTimer >= 0.3) {
      blinkTimer = 0;
      showEye = !showEye;
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

    if (isRebel) {
      gameRef.increaseScore();
    } else {
      gameRef.loseLife();
    }

    removeFromParent();
  }

  @override
  void onRemove() {
    super.onRemove();

    // If rebel escaped (not tapped), lose life
    if (isRebel && !wasTapped) {
      gameRef.loseLife();
    }
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

