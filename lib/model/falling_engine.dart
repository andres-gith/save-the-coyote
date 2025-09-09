import 'dart:async';
import 'dart:math';

import 'package:flutter/animation.dart';

class CoyoteFallingEngine {
  CoyoteFallingEngine._internal();

  static final CoyoteFallingEngine _instance = CoyoteFallingEngine._internal();

  factory CoyoteFallingEngine() => _instance;

  final StreamController<double> _fallingController = StreamController<double>.broadcast();

  Stream<double> get fallingStream => _fallingController.stream;
  Timer? _timer;
  double _position = 0.0;

  void startFalling() {
    final int durationMs = _getRandomDuration();
    final Curve curve = _getRandomCurve(); // Curves.easeIn;
    _position = 0.0;
    final start = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 4), (timer) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      double t = (elapsed / durationMs).clamp(0.0, 1.0);
      _position = curve.transform(t);
      _fallingController.add(_position);
      if (_position == 1.0) timer.cancel();
    });
  }

  void stopFalling() {
    _timer?.cancel();
  }

  Curve _getRandomCurve() {
    return [
      Curves.easeInQuart,
      Curves.decelerate,
      Curves.easeInCubic,
      Curves.easeInExpo,
      Curves.easeInCirc,
      Curves.easeInOutCubic,
      Curves.easeInOutQuint,
      Curves.easeOut,
      Curves.easeOutQuart,
      Curves.linear,
    ][Random().nextInt(10)];
  }

  int _getRandomDuration({int min = 300, int max = 1500}) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  void dispose() {
    _fallingController.close();
  }
}
