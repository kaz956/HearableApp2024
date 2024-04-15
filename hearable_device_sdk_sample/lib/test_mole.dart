import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(WhackAMoleApp());
}

class WhackAMoleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Whack a Mole'),
        ),
        body: Center(
          child: WhackAMole(),
        ),
      ),
    );
  }
}

class WhackAMole extends StatefulWidget {
  @override
  _WhackAMoleState createState() => _WhackAMoleState();
}

class _WhackAMoleState extends State<WhackAMole> {
  Random _random = Random();
  Timer? _timer;
  Offset _molePosition = Offset(0, 0);
  bool _visible = true;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _generateMole();
    });
  }

  void _generateMole() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double randomX = _random.nextDouble() * screenWidth;
    double randomY = _random.nextDouble() * screenHeight;

    setState(() {
      _molePosition = Offset(randomX, randomY);
      _visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        double x = details.globalPosition.dx;
        double y = details.globalPosition.dy;

        if (_isHit(x, y)) {
          setState(() {
            _visible = false;
            _score++;
          });
        }
      },
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            if (_visible)
              Positioned(
                left: _molePosition.dx,
                top: _molePosition.dy,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isHit(double x, double y) {
    double moleX = _molePosition.dx;
    double moleY = _molePosition.dy;

    if (x >= moleX && x <= moleX + 50 && y >= moleY && y <= moleY + 50) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
