import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';


class GameOverComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {
  @override
  final BigBrotherGame game;

  GameOverComponent(this.game);
  @override
  Future<void> onLoad() async {
    size = game.size;

    final text = TextComponent(
      text: "SYSTEM FAILURE\n\nSURVEILLANCE COLLAPSED\n\nFINAL REPORT: ${game.score} THREATS ELIMINATED\n\nCLICK TO REINITIALIZE",
      anchor: Anchor.center,
      position: game.size / 2,
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
    game.resetGame();
  }
}