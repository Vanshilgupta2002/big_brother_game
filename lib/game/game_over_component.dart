
import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';

class GameOverComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {

  @override
  final BigBrotherGame game;

  GameOverComponent(this.game);

  String getRank(int score) {
    if (score < 10) return "SYSTEM FAILURE";
    if (score < 25) return "REGIME UNSTABLE";
    if (score < 40) return "CONTROL MAINTAINED";
    return "TOTAL SURVEILLANCE DOMINANCE";
  }

  String getEvaluation(int score) {
    if (score < 10) {
      return "Mass dissent detected.\nSurveillance collapse.";
    }
    if (score < 25) {
      return "Public order partially restored.\nMonitoring insufficient.";
    }
    if (score < 40) {
      return "Threat suppression effective.\nStability maintained.";
    }
    return "Absolute authority achieved.\nAll dissent neutralized.";
  }

  @override
  Future<void> onLoad() async {
    size = game.size;

    // Dark overlay background
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = Colors.black.withOpacity(0.85),
      ),
    );

    final rank = getRank(game.score);
    final evaluation = getEvaluation(game.score);

    final text = TextComponent(
      text: """
$rank

THREATS ELIMINATED: ${game.score}

$evaluation

CLICK TO REINITIALIZE
""",
      anchor: Anchor.center,
      position: game.size / 2,
      textRenderer:  TextPaint(
        style: TextStyle(
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
    game.resetGame();
    removeFromParent();
  }
}