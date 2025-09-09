import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:save_coyote/model/models.dart';

void main() {
  group('CoyoteFallingEngine', () {
    test('singleton instance', () {
      final instance1 = CoyoteFallingEngine();
      final instance2 = CoyoteFallingEngine();
      expect(instance1, same(instance2));
    });

    test('startFalling emits values and completes', () async {
      final engine = CoyoteFallingEngine();
      final List<double> positions = [];
      final completer = Completer<void>();

      engine.fallingStream.listen(
        (position) {
          positions.add(position);
          if (position == 1.0) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      );

      engine.startFalling();

      // Wait for the stream to complete or a timeout
      await expectLater(completer.future, completes);

      expect(positions, isNotEmpty);
      expect(positions.first, lessThanOrEqualTo(1.0));
      expect(positions.last, equals(1.0));
      // Check if positions are generally increasing
      for (int i = 0; i < positions.length - 1; i++) {
        expect(positions[i], lessThanOrEqualTo(positions[i + 1]));
      }
      //engine.dispose(); // Dispose after test
    });

    test('stopFalling stops emitting values', () async {
      final engine = CoyoteFallingEngine();
      final List<double> positions = [];
      bool streamClosed = false;

      engine.fallingStream.listen(
        (position) {
          positions.add(position);
        },
        onDone: () {
          streamClosed = true;
        },
      );

      engine.startFalling();
      await Future.delayed(const Duration(milliseconds: 50)); // Let it run for a bit
      engine.stopFalling();
      final countAfterStop = positions.length;
      await Future.delayed(const Duration(milliseconds: 100)); // Wait to see if more values are emitted

      expect(positions.length, countAfterStop); // No new values after stop
      expect(streamClosed, isFalse); // Stream should not be closed by stopFalling

      //engine.dispose(); // Dispose after test
    });

    test('startFalling replaces existing timer', () async {
      final engine = CoyoteFallingEngine();
      final List<double> positions1 = [];
      final List<double> positions2 = [];
      final completer1 = Completer<void>();
      final completer2 = Completer<void>();

      // First falling session
      engine.fallingStream.listen((pos) {
        if (!completer1.isCompleted && !completer2.isCompleted) positions1.add(pos);
        if (pos == 1.0 && !completer1.isCompleted && positions1.isNotEmpty) completer1.complete();
      });
      engine.startFalling();
      await expectLater(completer1.future.timeout(const Duration(seconds: 2)), completes);

      // Start falling again immediately
      // The old stream subscription is still active but will stop receiving values if the timer is reset.
      // We need a new listener or a way to differentiate.
      // For simplicity, let's assume the stream is listened to once per "session" or reset the listener.
      // Or, we can check if the first stream stops getting new distinct values after the second start.

      // A new subscription to see the effect of the second startFalling
      final sub2 = engine.fallingStream.listen((pos) {
        positions2.add(pos);
        if (pos == 1.0 && !completer2.isCompleted) completer2.complete();
      });

      engine.startFalling(); // This should reset the timer and position
      await expectLater(completer2.future.timeout(const Duration(seconds: 2)), completes);
      await sub2.cancel();

      expect(positions1.isNotEmpty, isTrue);
      expect(positions1.last, 1.0);
      expect(positions2.isNotEmpty, isTrue);
      expect(positions2.first, lessThan(0.1)); // Should start from near 0
      expect(positions2.last, 1.0);

      //engine.dispose();
    });

    test('dispose closes the stream', () async {
      final engine = CoyoteFallingEngine();
      bool isClosed = false;
      engine.fallingStream.listen(
        null, // We don't care about data
        onDone: () {
          isClosed = true;
        },
      );
      engine.dispose();
      await Future.delayed(Duration.zero); // Allow stream to close
      expect(isClosed, isTrue);
    });
  });
}
