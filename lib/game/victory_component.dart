import 'dart:math';
import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';

class VictoryComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {

  @override
  final BigBrotherGame game;

  VictoryComponent(this.game);

  late RectangleComponent _panel;
  late RectangleComponent _border;
  late TextComponent _title;
  late TextComponent _score;
  late TextComponent _rating;
  late TextComponent _reinitialize;

  double _pulse = 0;
  double _countUp = 0;
  double _scanOffset = 0;

  bool _showRating = false;
  bool _showReinit = false;

  bool _cursorVisible = true;
  double _cursorTimer = 0;

  String getRating(int score) {
    if (score < 15) return "CLASSIFICATION: ACCEPTABLE";
    if (score < 30) return "CLASSIFICATION: CONTROLLED";
    if (score < 40) return "CLASSIFICATION: STABILIZED";
    return "CLASSIFICATION: TOTAL DOMINANCE";
  }

  @override
  Future<void> onLoad() async {
    size = game.size;
    final center = game.size / 2;

    // ===== Background (Green Authority Glow) =====
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Colors.black.withOpacity(0.97),
              Colors.green.withOpacity(0.12),
            ],
          ).createShader(
            Rect.fromLTWH(0, 0, game.size.x, game.size.y),
          ),
      ),
    );

    // ===== Panel =====
    _panel = RectangleComponent(
      size: Vector2(640, 420),
      position: center,
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF0F1414),
    );

    _panel.scale = Vector2.all(0.96);
    add(_panel);

    _panel.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.35, curve: Curves.easeOut),
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
        ..color = Colors.greenAccent.withOpacity(0.6),
    );

    add(_border);

    // ===== Title =====
    _title = TextComponent(
      text: "MISSION COMPLETE",
      anchor: Anchor.center,
      position: center + Vector2(0, -150),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );

    add(_title);

    // ===== Score =====
    _score = TextComponent(
      text: "THREATS ELIMINATED: 0",
      anchor: Anchor.center,
      position: center + Vector2(0, -80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 20,
          letterSpacing: 2,
        ),
      ),
    );

    add(_score);

    // ===== Rating (Delayed Reveal) =====
    _rating = TextComponent(
      text: "",
      anchor: Anchor.center,
      position: center + Vector2(0, 0),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 18,
          letterSpacing: 2,
        ),
      ),
    );

    add(_rating);

    // ===== Terminal Reinitialize Text =====
    _reinitialize = TextComponent(
      text: "",
      anchor: Anchor.center,
      position: center + Vector2(0, 140),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );

    add(_reinitialize);

    // Staged reveal
    Future.delayed(const Duration(seconds: 1), () {
      _showRating = true;
      _rating.text = getRating(game.score);
    });

    Future.delayed(const Duration(seconds: 2), () {
      _showReinit = true;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ===== Border Pulse =====
    _pulse += dt;
    final glow = (sin(_pulse * 1.5) + 1) / 2;

    _border.paint.color =
        Colors.greenAccent.withOpacity(0.5 + glow * 0.3);

    // ===== Score Count Up =====
    if (_countUp < game.score) {
      _countUp += dt * 25;
      if (_countUp > game.score) {
        _countUp = game.score.toDouble();
      }

      _score.text =
      "THREATS ELIMINATED: ${_countUp.toInt()}";
    }

    // ===== Blinking Cursor =====
    if (_showReinit) {
      _cursorTimer += dt;
      if (_cursorTimer >= 0.6) {
        _cursorTimer = 0;
        _cursorVisible = !_cursorVisible;
      }

      _reinitialize.text = _cursorVisible
          ? "> REINITIALIZE SYSTEM _"
          : "> REINITIALIZE SYSTEM ";
    }

    // ===== Subtle Scanline Drift =====
    _scanOffset += dt * 30;
    if (_scanOffset > size.y) _scanOffset = 0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calm scanline overlay
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.03);

    for (double y = _scanOffset; y < size.y; y += 6) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        paint,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.resetGame();
    removeFromParent();
  }
}