import 'package:big_brother_game/game/big_brother_game..dart';
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

  PersonComponent({required this.isRebel})
      : super(
    radius: 25,
    anchor: Anchor.center,
    paint: Paint()
      ..color = isRebel ? Colors.red : Colors.green,
  );

  @override
  Future<void> onLoad() async {
    lifeTime = 1.0 + (game.random.nextDouble() * 0.8);
  }
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
      game.increaseScore();
      game.add(ScorePopupComponent(position: absolutePosition.clone()));
    } else {
      game.loseLife();
      game.add(ScorePopupComponent(
        position: absolutePosition.clone(),
        isPenalty: true,
      ));
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

