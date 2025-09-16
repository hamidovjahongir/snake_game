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
  Offset snakeHead = Offset(150, 150);
  double step = 20;

  Timer? timer;
  int score = 0;
  bool isGameOver = false;
  final Random rnd = Random();

  @override
  void initState() {
    super.initState();
    // timer =  Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
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
          return;
        });
        break;
      }
    }
  }

  void _tick() {
    if (isGameOver) return;

    if (position == JoystickPosition.center) return;

    final head = snake.first;
    Point<int> newHead;

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
        newHead = head;
        break;
    }

    if (newHead.x < 0 ||
        newHead.y >= col ||
        newHead.y < 0 ||
        newHead.x >= row) {
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

      Future.delayed(Duration(seconds: 1), () {
        snake = [Point(col ~/ 2, row ~/ 2)];
        position = JoystickPosition.center;
        score = 0;
        isGameOver = false;
        _spawnFood();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = MediaQuery.of(context).size.width - 40;
    final cellSize = boardSize / col;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Snack Game',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'score $score',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 30,
                height: 2,
              ),
            ),

            Container(
              width: boardSize,
              height: boardSize,
              color: Colors.black,
              child: Stack(
                children: [
                  for (int x = 0; x < col; x++)
                    for (int y = 0; y < row; y++)
                      Positioned(
                        left: x * cellSize,
                        top: y * cellSize,
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(color: Colors.amber),
                        ),
                      ),

                  Positioned(
                    left: food.x * cellSize,
                    top: food.y * cellSize,

                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      color: Colors.red,
                    ),
                  ),

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Joystick(
                  position: (value) {
                    setState(() {
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
          ],
        ),
      ),
    );
  }
}
