import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hearable_device_sdk_sample/nine_axis_sensor.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Radar Example'),
        ),
        body: Center(
          child: RadarChart(
            data: [0.45, 0.75, 1.0],
            maxValue: 1.0,
          ),
        ),
      ),
    );
  }
}

class RadarChart extends StatelessWidget {
  final List<double> data;
  final double maxValue;

  RadarChart({
    required this.data,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueGrey.shade300.withOpacity(0.8), width: 1),
              ),
            ),
          ),
          for (int i = 0; i < 12; i++)
            Positioned(
              top: 150,
              left: 50,
              child: Transform.rotate(
                angle: pi / 6 * i,
                child: Container(
                  width: 200,
                  height: 0.5,
                  color: Colors.blueGrey.shade300.withOpacity(0.8),
                ),
              ),
            ),
          for (int i = 0; i < data.length; i++)
            Positioned(
              top: 150 - (data[i] * 100),
              left: 150 - (data[i] * 100),
              child: Container(
                width: data[i] * 200,
                height: data[i] * 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
            ),
            Positioned(
              bottom: 140,
              left: 140, // ボールの位置
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
