import 'package:big_brother_game/game/hud_component.dart';
import 'package:big_brother_game/game/intro_component.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'cctv_tile.dart';
import 'dart:math';
import 'person_component.dart';
import 'cctv_tile.dart';

import 'game_over_component.dart';

class BigBrotherGame extends FlameGame {
  final int gridSize = 3;

  final List<CCTVTile> tiles = [];
  final Random random = Random();

  int score = 0;
  int lives = 3;
  bool isGameOver = false;

  double spawnTimer = 0;
  double spawnInterval = 1.2;

  double flashTimer = 0;

  @override
  Color backgroundColor() => const Color(0xFF050A0A);
  @override
  Future<void> onLoad() async {
    await FlameAudio.audioCache.loadAll([
      'click.wav',

    ]);

    add(IntroComponent());
  }


  void startGame() {
    _createGrid();
    add(HudComponent(this));
  }


  void _createGrid() {
    final tileWidth = size.x / gridSize;
    final tileHeight = size.y / gridSize;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tile = CCTVTile(
          position: Vector2(col * tileWidth, row * tileHeight),
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
  }

  void _spawnRandomPerson() {
    if (tiles.isEmpty) return;

    final tile = tiles[random.nextInt(tiles.length)];
    tile.spawnPerson(random.nextBool());
  }



  void increaseScore() {
    if (isGameOver) return;

    score++;

    if (score % 8 == 0 && spawnInterval > 0.35) {
      spawnInterval -= 0.08;
    }
    print("Playing click sound");

    FlameAudio.play('click.wav');
  }
  void loseLife() {
    if (isGameOver) return;

    lives--;
    flashTimer = 0.2; // trigger flash

    if (lives <= 0) {
      isGameOver = true;
      add(GameOverComponent(this));
    }
    FlameAudio.play('click.wav');
  }
  void resetGame() {
    for (final component in children.toList()) {
      component.removeFromParent();
    }

    tiles.clear();

    score = 0;
    lives = 3;
    spawnInterval = 1.2;
    spawnTimer = 0;
    isGameOver = false;

    _createGrid();
    add(HudComponent(this));
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 🔴 Flash effect when losing life
    if (flashTimer > 0) {
      final flashPaint = Paint()
        ..color = Colors.red.withOpacity(0.3);

      canvas.drawRect(size.toRect(), flashPaint);
    }

    // 🟢 CRT scanline effect
    final scanPaint = Paint()
      ..color = Colors.green.withOpacity(0.05);

    for (double y = 0; y < size.y; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        scanPaint,
      );
    }
  }


  }


