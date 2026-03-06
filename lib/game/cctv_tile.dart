import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'person_component.dart';

class CCTVTile extends PositionComponent {

  // ✅ This must be OUTSIDE constructor
  PersonComponent? currentPerson;

  CCTVTile({
    required Vector2 position,
    required Vector2 size,
  }) {
    this.position = position;
    this.size = size;
  }

  void spawnPerson(bool isRebel) {
    if (currentPerson != null) return;

    currentPerson = PersonComponent(isRebel: isRebel);
    currentPerson!.position = size / 2;
    add(currentPerson!);
  }
  @override
  void update(double dt) {
    super.update(dt);

    if (currentPerson != null && currentPerson!.parent == null) {
      currentPerson = null;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFF0F1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(size.toRect(), paint);
  }
}