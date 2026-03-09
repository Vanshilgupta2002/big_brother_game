import 'dart:math';

import 'package:big_brother_game/game/hud_component.dart';
import 'package:big_brother_game/game/intro_component.dart';
import 'package:big_brother_game/game/threat_progress_bar.dart';
import 'package:big_brother_game/game/victory_component.dart';
import 'package:big_brother_game/game/game_over_component.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'cctv_tile.dart';
import 'person_component.dart';

class BigBrotherGame extends FlameGame {
  final int gridSize = 3;
  final List<CCTVTile> tiles = [];
  final Random random = Random();

  int score = 0;
  int lives = 3;

  final int maxThreats = 40;
  int remainingThreats = 40;

  final int maxAuthority = 50;
  int remainingAuthority = 50;

  bool isGameOver = false;
  bool isFinalPhase = false;

  double spawnTimer = 0;
  double spawnInterval = 1.2;
  double flashTimer = 0;
  double scanSweep = 0;

  AudioSource? clickSound;

  final double contentPadding = 24;

  @override
  Color backgroundColor() => const Color(0xFF050A0A);

  @override
  Future<void> onLoad() async {
    await SoLoud.instance.init();
    clickSound =
    await SoLoud.instance.loadAsset('assets/audio/click.mp3');

    add(IntroComponent());
  }

  void startGame() {
    _createGrid();
    add(HudComponent(this));
    add(ThreatProgressBar());
  }

  void _createGrid() {
    final usableWidth = size.x - contentPadding * 2;
    final usableHeight = size.y - contentPadding * 2;

    final tileWidth = usableWidth / gridSize;
    final tileHeight = usableHeight / gridSize;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tile = CCTVTile(
          position: Vector2(
            contentPadding + col * tileWidth,
            contentPadding + row * tileHeight,
          ),
          size: Vector2(tileWidth, tileHeight),
        );

        tiles.add(tile);
        add(tile);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      _spawnRandomPerson();
    }

    if (flashTimer > 0) {
      flashTimer -= dt;
    }

    scanSweep += dt * 120;
    if (scanSweep > size.y) {
      scanSweep = 0;
    }
  }

  void _spawnRandomPerson() {
    if (tiles.isEmpty) return;

    final tile = tiles[random.nextInt(tiles.length)];

    final bool isRebel = random.nextBool();
    final bool isPriority =
        isRebel && random.nextDouble() < 0.15;
    final bool isSuspicious =
        !isRebel && random.nextDouble() < 0.3;

    tile.spawnPerson(isRebel, isSuspicious, isPriority);

    if (random.nextDouble() < 0.25) {
      final secondTile =
      tiles[random.nextInt(tiles.length)];

      final bool secondRebel = random.nextBool();
      final bool secondPriority =
          secondRebel && random.nextDouble() < 0.15;
      final bool secondSuspicious =
          !secondRebel && random.nextDouble() < 0.3;

      secondTile.spawnPerson(
          secondRebel,
          secondSuspicious,
          secondPriority);
    }
  }

  void increaseScore({int amount = 1}) {
    if (isGameOver) return;

    score += amount;
    remainingThreats -= amount;

    if (!isFinalPhase && remainingThreats <= 10) {
      isFinalPhase = true;
      spawnInterval *= 0.75;
    }

    if (remainingThreats <= 0) {
      isGameOver = true;
      add(VictoryComponent(this));
      return;
    }

    if (score % 6 == 0 && spawnInterval > 0.3) {
      spawnInterval -= 0.08;
    }

    _playClickSound();
  }

  void loseLife() {
    if (isGameOver) return;

    lives--;
    flashTimer = 0.2;

    if (lives <= 0) {
      isGameOver = true;
      add(GameOverComponent(this));
    }

    _playClickSound();
  }

  void useAuthority() {
    if (isGameOver) return;

    remainingAuthority--;

    if (remainingAuthority <= 0) {
      isGameOver = true;
      add(GameOverComponent(this));
    }
  }

  void _playClickSound() {
    if (clickSound != null) {
      SoLoud.instance.play(clickSound!).ignore();
    }
  }

  void resetGame() {
    isFinalPhase = false;
    remainingThreats = maxThreats;
    remainingAuthority = maxAuthority;
    score = 0;
    lives = 3;
    spawnInterval = 1.2;
    spawnTimer = 0;
    isGameOver = false;

    for (final component in children.toList()) {
      component.removeFromParent();
    }

    tiles.clear();

    _createGrid();
    add(HudComponent(this));
    add(ThreatProgressBar());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ===== INSIDE SCREEN AREA (game view only) =====

    final Rect screenRect = Rect.fromLTWH(
      contentPadding,
      contentPadding,
      size.x - contentPadding * 2,
      size.y - contentPadding * 2,
    );

    // Threat stage overlay (only inside screen)
    Color overlayColor;
    if (remainingThreats > 25) {
      overlayColor = Colors.red;
    } else if (remainingThreats > 10) {
      overlayColor = Colors.yellow;
    } else {
      overlayColor = Colors.green;
    }

    final overlayPaint = Paint()
      ..color = overlayColor.withOpacity(0.05);

    canvas.drawRect(screenRect, overlayPaint);

    // Moving scan sweep (only inside screen)
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.green.withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          contentPadding,
          scanSweep - 50,
          screenRect.width,
          100,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        contentPadding,
        scanSweep - 50,
        screenRect.width,
        100,
      ),
      sweepPaint,
    );

    // CRT scanlines (inside screen only)
    final scanPaint = Paint()
      ..color = Colors.green.withOpacity(0.04);

    for (double y = contentPadding;
    y < size.y - contentPadding;
    y += 4) {
      canvas.drawLine(
        Offset(contentPadding, y),
        Offset(size.x - contentPadding, y),
        scanPaint,
      );
    }

    // Life flash
    if (flashTimer > 0) {
      final flashPaint = Paint()
        ..color = Colors.red.withOpacity(0.3);
      canvas.drawRect(screenRect, flashPaint);
    }

    // ===== CAMERA FRAME =====

    final framePaint = Paint()
      ..color = const Color(0xFF0B1111);

    // Top
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, contentPadding),
        framePaint);

    // Bottom
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.y - contentPadding, size.x, contentPadding),
        framePaint);

    // Left
    canvas.drawRect(
        Rect.fromLTWH(0, 0, contentPadding, size.y),
        framePaint);

    // Right
    canvas.drawRect(
        Rect.fromLTWH(
            size.x - contentPadding, 0, contentPadding, size.y),
        framePaint);

    // ===== INNER SCREEN BORDER =====

    final borderPaint = Paint()
      ..color = Colors.green.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(screenRect, borderPaint);

    // ===== REC + TIMESTAMP =====

    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}";

    final textPainter = TextPainter(
      text: TextSpan(
        text: "REC ●   $timeString",
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(contentPadding + 10, 4),
    );
  }
}