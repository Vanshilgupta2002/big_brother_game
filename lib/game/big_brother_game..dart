import 'package:big_brother_game/game/hud_component.dart';
import 'package:flame/game.dart';
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

  @override
  Color backgroundColor() => const Color(0xFF050A0A);

  @override
  Future<void> onLoad() async {
    super.onLoad();
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
  }

  void _spawnRandomPerson() {
    if (tiles.isEmpty) return;

    final tile = tiles[random.nextInt(tiles.length)];
    tile.spawnPerson(random.nextBool());
  }



  void increaseScore() {
    if (isGameOver) return;

    score++;

    // increase difficulty every 10 points
    if (score % 10 == 0 && spawnInterval > 0.4) {
      spawnInterval -= 0.1;
    }
  }
  void loseLife() {
    if (isGameOver) return;

    lives--;

    if (lives <= 0) {
      isGameOver = true;
      // pauseEngine();   // 👈 important
      add(GameOverComponent(this));
    }
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
}