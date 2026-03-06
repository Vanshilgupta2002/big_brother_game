import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/big_brother_game..dart';


void main() {
  runApp(
    GameWidget(
      game: BigBrotherGame(),
    ),
  );
}