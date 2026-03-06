import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';


class GameOverComponent extends PositionComponent
    with TapCallbacks, HasGameRef<BigBrotherGame> {
  final BigBrotherGame gameRef;

  GameOverComponent(this.gameRef);
  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    final text = TextComponent(
      text: "SYSTEM FAILURE\nFINAL SCORE: ${gameRef.score}\n\nCLICK TO RESTART",
      anchor: Anchor.center,
      position: gameRef.size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(text);
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.resetGame();
  }
}