import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/big_brother_game..dart';

import 'package:big_brother_game/ui/surveillance_intro.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _showIntro = true;
  late final BigBrotherGame _game;

  @override
  void initState() {
    super.initState();
    _game = BigBrotherGame();
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
    });
    // Trigger the game logic to start spawning entities and playing background sound
    if (!_game.isGameStarted) {
      _game.startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          // The game loads in the background immediately
          GameWidget<BigBrotherGame>(
            game: _game,
          ),
          
          // The intro screen covers the game until dismissed
          if (_showIntro)
            SurveillanceIntro(onEnter: _startGame),
        ],
      ),
    );
  }
}