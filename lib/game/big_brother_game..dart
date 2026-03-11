import 'dart:math';

import 'package:big_brother_game/game/hud_component.dart';
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

  bool isGameStarted = false;
  bool isGameOver = false;
  bool isFinalPhase = false;

  double spawnTimer = 0;
  double spawnInterval = 1.2;
  double flashTimer = 0;
  double scanSweep = 0;
  int scanSweepCount = 0;

  bool recBlink = true;
  double recBlinkTimer = 0;

  AudioSource? clickSound;
  AudioSource? scanLoop;
  SoundHandle? scanHandle;


  final double contentPadding = 24;
  double shakeTimer = 0.5;
  double shakeIntensity = 25;

  double panicPulseTimer = 0;
  double panicFlash = 0;

  AudioSource? scanPing;




  @override
  Color backgroundColor() => const Color(0xFF040808);
  @override
  Future<void> onLoad() async {
    await SoLoud.instance.init();

    clickSound =
    await SoLoud.instance.loadAsset('assets/audio/click.mp3');

    scanLoop =
    await SoLoud.instance.loadAsset('assets/audio/background.mp3');

    scanPing =
    await SoLoud.instance.loadAsset('assets/audio/scanping.mp3');
  }
  Future<void> startGame() async {
    isGameStarted = true;
    _createGrid();
    add(HudComponent(this));
    add(ThreatProgressBar());

    if (scanLoop != null) {
      scanHandle = await SoLoud.instance.play(
        scanLoop!,
        volume: 0.25,
        looping: true,
      );
    }
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
    if (!isGameStarted || isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      _spawnRandomPerson();
    }

    if (flashTimer > 0) {
      flashTimer -= dt;
    }

    // ===== Dynamic Scan Speed Based On Threats =====
    double scanSpeed;

    if (remainingThreats > 24) {
      scanSpeed = 120;      // Normal
    } else if (remainingThreats > 10) {
      scanSpeed = 200;      // Faster
    } else {
      scanSpeed = 320;      // Panic mode
    }
    scanSweep += dt * scanSpeed;

    if (scanSweep >= size.y) {
      scanSweep = 0;
      scanSweepCount++;

// 🔊 Play ping once every 8 sweeps
      if (scanSweepCount >= 6) {
        scanSweepCount = 0;
        if (scanPing != null) {
          SoLoud.instance.play(
            scanPing!,
            volume: 0.35,
          );
        }
      }
    }



    recBlinkTimer += dt;
    if (recBlinkTimer >= 0.6) {
      recBlinkTimer = 0;
      recBlink = !recBlink;
    }
// 🎥 CAMERA SHAKE (IMPROVED)
    if (shakeTimer > 0) {
      shakeTimer -= dt;

      final progress = shakeTimer / 0.45;
      final offset = sin(shakeTimer * 60) * 12 * progress;

      camera.viewfinder.position = Vector2(offset, 0);

      if (shakeTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      }
    }

    // ===== PANIC PULSE LOGIC =====
    if (remainingThreats <= 10 && !isGameOver) {
      panicPulseTimer += dt;

      if (panicPulseTimer >= 1.5) {
        panicPulseTimer = 0;
        panicFlash = 0.25; // pulse duration
      }
    }

    if (panicFlash > 0) {
      panicFlash -= dt;
    }




    // ===== AMBIENT SPEED ADJUSTMENT =====
    if (scanHandle != null) {
      if (remainingThreats <= 10) {
        SoLoud.instance.setRelativePlaySpeed(scanHandle!, 1.15);
      } else if (remainingThreats <= 25) {
        SoLoud.instance.setRelativePlaySpeed(scanHandle!, 1.05);
      } else {
        SoLoud.instance.setRelativePlaySpeed(scanHandle!, 1.0);
      }
    }

  }
  void _spawnRandomPerson() {
    if (tiles.isEmpty) return;

    // First spawn
    final tile = tiles[random.nextInt(tiles.length)];

    final bool isRebel = random.nextBool();
    final bool isPriority =
        isRebel && random.nextDouble() < 0.15;
    final bool isSuspicious =
        !isRebel && random.nextDouble() < 0.3;

    tile.spawnPerson(isRebel, isSuspicious, isPriority);

    // 🔥 25% chance of second spawn
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

    _playClickSound();
  }
  Future<void> loseLife() async {
    if (isGameOver) return;

    lives--;
    flashTimer = 0.35;

    // 🎥 Start camera shake
    shakeTimer = 0.3;
    shakeIntensity = 8;

    if (lives <= 0) {
      isGameOver = true;

      // 🔊 Stop background scan sound ONLY on game over
      if (scanHandle != null) {
        await SoLoud.instance.stop(scanHandle!);
      }

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

  Future<void> resetGame() async {
    isFinalPhase = false;
    remainingThreats = maxThreats;
    remainingAuthority = maxAuthority;
    score = 0;
    lives = 3;
    spawnInterval = 1.2;
    spawnTimer = 0;
    scanSweepCount = 0;
    isGameOver = false;

    if (scanHandle != null) {
      try {
        await SoLoud.instance.stop(scanHandle!);
      } catch (_) {}
    }

    for (final component in children.toList()) {
      component.removeFromParent();
    }

    tiles.clear();

    _createGrid();
    add(HudComponent(this));
    add(ThreatProgressBar());

    if (scanLoop != null) {
      scanHandle = await SoLoud.instance.play(
        scanLoop!,
        volume: 0.25,
        looping: true,
      );
    }
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Rect screenRect = Rect.fromLTWH(
      contentPadding,
      contentPadding,
      size.x - contentPadding * 2,
      size.y - contentPadding * 2,
    );

    // ===== THREAT STAGE OVERLAY =====
    double dangerFactor = remainingThreats / maxThreats;

    Color overlayColor;
    double opacity;

    if (remainingThreats > 25) {
      overlayColor = Colors.red;
      opacity = 0.15 + (dangerFactor * 0.08);
    } else if (remainingThreats > 10) {
      overlayColor = Colors.yellow;
      opacity = 0.18;
    } else {
      overlayColor = Colors.green;
      opacity = 0.20;
    }

    canvas.drawRect(
      screenRect,
      Paint()..color = overlayColor.withOpacity(opacity),
    );

    // ===== SCAN SWEEP =====
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.green.withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          contentPadding,
          scanSweep - 40,
          screenRect.width,
          80,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        contentPadding,
        scanSweep - 40,
        screenRect.width,
        80,
      ),
      sweepPaint,
    );

    // ===== CRT SCANLINES =====
    final scanPaint =
    Paint()..color = Colors.green.withOpacity(0.04);

    for (double y = contentPadding;
    y < size.y - contentPadding;
    y += 4) {
      canvas.drawLine(
        Offset(contentPadding, y),
        Offset(size.x - contentPadding, y),
        scanPaint,
      );
    }

    // ===== NOISE FLICKER =====
    if (Random().nextDouble() < 0.03) {
      canvas.drawRect(
        screenRect,
        Paint()..color = Colors.white.withOpacity(0.03),
      );
    }

    // ===== VIGNETTE =====
    final vignette = RadialGradient(
      center: Alignment.center,
      radius: 0.9,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.6),
      ],
    ).createShader(screenRect);

    canvas.drawRect(screenRect, Paint()..shader = vignette);

    // ===== CAMERA FRAME =====
    final framePaint =
    Paint()..color = const Color(0xFF0B1111);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, contentPadding),
        framePaint);
    canvas.drawRect(
        Rect.fromLTWH(
            0, size.y - contentPadding, size.x, contentPadding),
        framePaint);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, contentPadding, size.y),
        framePaint);
    canvas.drawRect(
        Rect.fromLTWH(
            size.x - contentPadding, 0, contentPadding, size.y),
        framePaint);

    // ===== CAMERA LABEL =====
    final camPainter = TextPainter(
      text: const TextSpan(
        text: "CAM 03  •  SECTOR A",
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
          fontFamily: 'Courier',
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    camPainter.paint(
      canvas,
      Offset(contentPadding + 10, size.y - 20),
    );

    // ===== DATE + TIME =====
    final now = DateTime.now();
    final dateTimeString =
        "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}  "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}";

    final timePainter = TextPainter(
      text: TextSpan(
        text: dateTimeString,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
          fontFamily: 'Courier',
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    timePainter.paint(
      canvas,
      Offset(
        size.x - contentPadding - timePainter.width - 10,
        6,
      ),
    );

    // ===== REC =====
    if (recBlink) {
      canvas.drawCircle(
        Offset(contentPadding + 15, 14),
        5,
        Paint()..color = Colors.redAccent,
      );
    }

    final recTextPainter = TextPainter(
      text: const TextSpan(
        text: "REC",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontFamily: 'Courier',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    recTextPainter.paint(
      canvas,
      Offset(contentPadding + 30, 6),
    );

    // ===== PANIC RED PULSE (≤10 threats) =====
    if (panicFlash > 0) {
      final pulseOpacity = (panicFlash / 0.25) * 0.35;

      canvas.drawRect(
        screenRect,
        Paint()
          ..color = Colors.orangeAccent.withOpacity(pulseOpacity),
      );
    }

    // ===== DAMAGE FLASH (ALWAYS LAST) =====
    if (flashTimer > 0) {
      final intensity = flashTimer * 3;

      canvas.drawRect(
        screenRect,
        Paint()
          ..color = Colors.red.withOpacity(0.5 * intensity),
      );

      if (flashTimer > 0.25) {
        canvas.drawRect(
          screenRect,
          Paint()
            ..color = Colors.white.withOpacity(0.1 * intensity),
        );
      }
    }
  }
}