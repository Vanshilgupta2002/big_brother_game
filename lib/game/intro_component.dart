import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';


class IntroComponent extends PositionComponent
    with TapCallbacks, HasGameRef<BigBrotherGame> {

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    final text = TextComponent(
      text: "BIG BROTHER v2.4\n\nSURVEILLANCE PROTOCOL ACTIVE\n\nIDENTIFY DISSIDENTS\nPROTECT SYSTEM STABILITY\n\nCLICK TO BEGIN",
      anchor: Anchor.center,
      position: gameRef.size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(text);
  }

  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    gameRef.startGame();
  }
}