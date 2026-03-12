import 'package:big_brother_game/ui/instruction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/big_brother_game..dart';
// import 'game/big_brother_game.dart';

import 'ui/surveillance_intro.dart';
// import 'ui/identification_protocol.dart';
import 'ui/operator_briefing.dart';

void main() {
  runApp(const MainApp());
}

enum AppScreen { intro, instructions, briefing, game }

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppScreen _currentScreen = AppScreen.intro;
  late final BigBrotherGame _game;

  @override
  void initState() {
    super.initState();
    _game = BigBrotherGame();
  }

  void _showInstructions() {
    setState(() {
      _currentScreen = AppScreen.instructions;
    });
  }

  void _showBriefing() {
    setState(() {
      _currentScreen = AppScreen.briefing;
    });
  }

  void _startGame() {
    setState(() {
      _currentScreen = AppScreen.game;
    });

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

          // Game always running in background
          GameWidget<BigBrotherGame>(
            game: _game,
          ),

          if (_currentScreen == AppScreen.intro)
            SurveillanceIntro(
              onEnter: _showInstructions,
            ),

          if (_currentScreen == AppScreen.instructions)
            IdentificationProtocol(
              onContinue: _showBriefing,
            ),

          if (_currentScreen == AppScreen.briefing)
            OperatorBriefing(
              onStart: _startGame,
            ),
        ],
      ),
    );
  }
}
