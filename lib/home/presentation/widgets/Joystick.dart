import 'dart:math';
import 'package:flutter/material.dart';

enum JoystickPosition { up, down, left, right, center }

class Joystick extends StatefulWidget {
  final ValueChanged<JoystickPosition>? position;
  const Joystick({super.key, this.position});

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset offset = Offset.zero;
  double maxRadius = 70;
  JoystickPosition position = JoystickPosition.center;

  void _reset() {
    setState(() {
      offset = Offset.zero;
      position = JoystickPosition.center;
      widget.position?.call(position);
    });
  }

  
  void _update(Offset localPos) {
    final dx = localPos.dx - 70;
    final dy = localPos.dy - 70;
    final distance = sqrt(dx * dx + dy * dy);
    Offset newPos;

    if (distance < maxRadius) {
      newPos = Offset(dx, dy);
    } else {
      final angle = atan2(dy, dx);
      newPos = Offset(maxRadius * cos(angle), maxRadius * sin(angle));
    }

    if (newPos.dy < -40) {
      position = JoystickPosition.up;
    } else if (newPos.dy > 40) {
      position = JoystickPosition.down;
    } else if (newPos.dx < -40) {
      position = JoystickPosition.left;
    } else if (newPos.dx > 40) {
      position = JoystickPosition.right;
    } else {
      position = JoystickPosition.center;
    }

    setState(() => offset = newPos);
  widget.position?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => _update(details.localPosition),
      onPanEnd: (_) => _reset(),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          color: Color(0xffC5C5C5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.translate(
            offset: offset,
            child: Container(
              width: 60,
              height: 60,
              decoration:  BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
