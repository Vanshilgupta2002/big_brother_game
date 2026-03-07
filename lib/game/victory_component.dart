import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';


class VictoryComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {

  @override
  final BigBrotherGame game;

  VictoryComponent(this.game);

  @override
  Future<void> onLoad() async {
    size = game.size;

    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = Colors.black.withOpacity(0.85),
      ),
    );

    final text = TextComponent(
      text: """
MISSION COMPLETE

ALL DISSENT ELIMINATED

TOTAL CONTROL ACHIEVED

CLICK TO REINITIALIZE
""",
      anchor: Anchor.center,
      position: game.size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.greenAccent,
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
    removeFromParent();
  }
}