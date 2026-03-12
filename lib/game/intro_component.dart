import 'package:big_brother_game/game/big_brother_game..dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class IntroComponent extends PositionComponent
    with TapCallbacks, HasGameReference<BigBrotherGame> {

  AudioSource? introMusic;
  SoundHandle? introHandle;

  @override
  Future<void> onLoad() async {
    size = game.size;

    final text = TextComponent(
      text: "BIG BROTHER v2.4\n\nSURVEILLANCE PROTOCOL ACTIVE\n\nIDENTIFY DISSIDENTS\nPROTECT SYSTEM STABILITY\n\nCLICK TO BEGIN",
      anchor: Anchor.center,
      position: game.size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(text);

    // Initialize SoLoud and play the audio
    // try {
    //   if (!SoLoud.instance.isInitialized) {
    //     await SoLoud.instance.init();
    //   }
    //   introMusic = await SoLoud.instance.loadAsset('assets/audio/mainentryscreen.mp3');
    //   if (introMusic != null) {
    //     introHandle = await SoLoud.instance.play(introMusic!, looping: true);
    //   }
    // } catch (e) {
    //   debugPrint("Could not load intro music: $e");
    // }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // if (introHandle != null) {
    //   try {
    //     SoLoud.instance.stop(introHandle!);
    //   } catch (_) {}
    // }
    removeFromParent();
    game.startGame();
  }
}