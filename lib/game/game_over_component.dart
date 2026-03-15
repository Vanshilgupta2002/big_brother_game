import 'dart:math';
import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';

class GameOverComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {

  @override
  final BigBrotherGame game;

  GameOverComponent(this.game);

  late RectangleComponent _panel;
  late RectangleComponent _border;
  late TextComponent _titleText;
  late TextComponent _scoreText;
  late TextComponent _buttonText;

  double _pulseTimer = 0;
  double _titlePulse = 0;
  double _countUp = 0;

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

    final center = game.size / 2;

    // ===== Background Cinematic Vignette =====
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.black.withOpacity(0.96),
              Colors.red.withOpacity(0.18),
            ],
          ).createShader(
            Rect.fromLTWH(0, 0, game.size.x, game.size.y),
          ),
      ),
    );

    // ===== Main Panel =====
    _panel = RectangleComponent(
      size: Vector2(640, 420),
      position: center,
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF141414),
    );

    _panel.scale = Vector2.all(0.95);
    add(_panel);

    _panel.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.4, curve: Curves.easeOut),
      ),
    );

    // ===== Border =====
    _border = RectangleComponent(
      size: Vector2(640, 420),
      position: center,
      anchor: Anchor.center,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.redAccent.withOpacity(0.7),
    );

    add(_border);

    final rank = getRank(game.score);
    final evaluation = getEvaluation(game.score);

    // ===== Title =====
    _titleText = TextComponent(
      text: rank,
      anchor: Anchor.center,
      position: center + Vector2(0, -140),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );

    add(_titleText);

    // ===== Score =====
    _scoreText = TextComponent(
      text: "THREATS ELIMINATED: 0",
      anchor: Anchor.center,
      position: center + Vector2(0, -70),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          letterSpacing: 2,
        ),
      ),
    );

    add(_scoreText);

    // ===== Evaluation =====
    add(
      TextComponent(
        text: evaluation,
        anchor: Anchor.center,
        position: center + Vector2(0, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ),
    );

    // ===== Button Background =====
    final buttonBg = RectangleComponent(
      size: Vector2(300, 55),
      position: center + Vector2(0, 130),
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.greenAccent.withOpacity(0.08),
    );

    add(buttonBg);

    add(
      RectangleComponent(
        size: Vector2(300, 55),
        position: center + Vector2(0, 130),
        anchor: Anchor.center,
        paint: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.greenAccent.withOpacity(0.6),
      ),
    );

    _buttonText = TextComponent(
      text: "REINITIALIZE SYSTEM",
      anchor: Anchor.center,
      position: center + Vector2(0, 130),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );

    add(_buttonText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ===== Border Pulse =====
    _pulseTimer += dt;
    final pulse = (sin(_pulseTimer * 2) + 1) / 2;
    _border.paint.color =
        Colors.redAccent.withOpacity(0.5 + pulse * 0.4);

    // ===== Title Glow =====
    _titlePulse += dt;
    final glow = (sin(_titlePulse * 2) + 1) / 2;

    _titleText.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.redAccent.withOpacity(0.7 + glow * 0.3),
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
    );

    // ===== Score Count Up Animation =====
    if (_countUp < game.score) {
      _countUp += dt * 20; // speed of counting
      if (_countUp > game.score) {
        _countUp = game.score.toDouble();
      }

      _scoreText.text =
      "THREATS ELIMINATED: ${_countUp.toInt()}";
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final center = size / 2;
    final buttonRect = Rect.fromCenter(
      center: (center + Vector2(0, 130)).toOffset(),
      width: 300,
      height: 55,
    );

    if (buttonRect.contains(event.localPosition.toOffset())) {
      game.playClickSound();
      game.resetGame();
      removeFromParent();
    }
  }
}