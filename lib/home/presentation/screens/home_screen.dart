import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_game/home/presentation/widgets/Joystick.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int row = 15;
  final int col = 15;

  List<Point<int>> snake = [Point(7, 7)];
  Point<int> food = Point(3, 5);

  JoystickPosition position = JoystickPosition.center;

  Timer? timer;
  int score = 0;
  bool isGameOver = false;
  final Random rnd = Random();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _spawnFood() {
    while (true) {
      final fx = rnd.nextInt(col);
      final fy = rnd.nextInt(row);
      final cnd = Point<int>(fx, fy);
      if (!snake.contains(cnd)) {
        setState(() {
          food = cnd;
        });
        break;
      }
    }
  }

  void _tick() {
    if (isGameOver) return;
    if (position == JoystickPosition.center) return;

    final head = snake.first;
    late Point<int> newHead;

    switch (position) {
      case JoystickPosition.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case JoystickPosition.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case JoystickPosition.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case JoystickPosition.right:
        newHead = Point(head.x + 1, head.y);
        break;
      case JoystickPosition.center:
        return;
    }

    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= col ||
        newHead.y >= row) {
      _gameOver();
      return;
    }

    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score++;
        _spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _gameOver() {
    setState(() {
      isGameOver = true;
      position = JoystickPosition.center;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("game over"),
          content: Text("score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  snake = [Point(col ~/ 2, row ~/ 2)];
                  score = 0;
                  isGameOver = false;
                  _spawnFood();
                  position = JoystickPosition.right;
                });
              },
              child: Text("start over"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = MediaQuery.of(context).size.width;
    final cellSize = boardSize / col;

    return Scaffold(
      appBar: AppBar(title: Text('Snake Game')),
      body: Column(
        children: [
          Text('Score: $score', style: TextStyle(fontSize: 24)),
          Container(
            width: boardSize,
            height: boardSize,
            color: Colors.black,
            child: Stack(
              children: [
                // Food
                Positioned(
                  left: food.x * cellSize,
                  top: food.y * cellSize,
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    color: Colors.red,
                  ),
                ),

                // Snake
                for (int i = 0; i < snake.length; i++)
                  Positioned(
                    left: snake[i].x * cellSize,
                    top: snake[i].y * cellSize,
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      color: i == 0 ? Colors.greenAccent : Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Joystick(
            position: (value) {
              setState(() {
                if (value == JoystickPosition.center) return;
                if ((position == JoystickPosition.left &&
                        value == JoystickPosition.right) ||
                    (position == JoystickPosition.right &&
                        value == JoystickPosition.left) ||
                    (position == JoystickPosition.up &&
                        value == JoystickPosition.down) ||
                    (position == JoystickPosition.down &&
                        value == JoystickPosition.up)) {
                  return;
                }
                position = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
