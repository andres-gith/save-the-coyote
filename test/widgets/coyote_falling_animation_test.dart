import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/provider/engine_bloc.dart';
import 'package:save_coyote/widgets/widgets.dart'; // Assuming CoyoteFallingAnimation & Coyote are part of widgets.dart

// Mocks
class MockEngineBloc extends MockBloc<EngineEvent, EngineState> implements EngineBloc {}

void main() {
  late MockEngineBloc mockEngineBloc;
  const double testTopOffset = 100.0;
  const double testHeightOffset = 500.0;
  const double testLeftPosition = 50.0;

  setUp(() {
    mockEngineBloc = MockEngineBloc();
    // Provide a default state for the bloc
    when(() => mockEngineBloc.state).thenReturn(EngineInitial());
  });

  Future<void> pumpCoyoteAnimation(WidgetTester tester, {required EngineState initialState}) async {
    when(() => mockEngineBloc.state).thenReturn(initialState);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack( // Wrap CoyoteFallingAnimation in a Stack
            children: [
              CoyoteFallingAnimation(
                engineBloc: mockEngineBloc,
                topOffset: testTopOffset,
                heightOffset: testHeightOffset,
                leftPosition: testLeftPosition,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('CoyoteFallingAnimation Widget Tests', () {
    testWidgets('renders Positioned Coyote when state is EngineRunning (e.g., CoyoteFalling)', (WidgetTester tester) async {
      const double currentPosition = 0.5;
      await pumpCoyoteAnimation(tester, initialState: const CoyoteFalling(currentPosition));

      final coyoteFinder = find.byType(Coyote);
      expect(coyoteFinder, findsOneWidget, reason: "Coyote widget should be rendered when EngineRunning.");

      final positionedFinder = find.ancestor(
        of: coyoteFinder,
        matching: find.byType(Positioned),
      );
      expect(positionedFinder, findsOneWidget, reason: "Positioned widget should be an ancestor of Coyote.");

      final Positioned positionedWidget = tester.widget<Positioned>(positionedFinder);
      final expectedTop = testTopOffset + (testHeightOffset * currentPosition);
      expect(positionedWidget.top, expectedTop);
      expect(positionedWidget.left, testLeftPosition);
      expect(find.byType(SizedBox), findsNothing);
    });

    testWidgets('renders Positioned Coyote when state is EngineRunning (e.g., CoyoteFell)', (WidgetTester tester) async {
      const double currentPosition = 1.0; 
      await pumpCoyoteAnimation(tester, initialState: const CoyoteFell());

      final coyoteFinder = find.byType(Coyote);
      expect(coyoteFinder, findsOneWidget, reason: "Coyote widget should be rendered when EngineRunning.");

      final positionedFinder = find.ancestor(
        of: coyoteFinder,
        matching: find.byType(Positioned),
      );
      expect(positionedFinder, findsOneWidget, reason: "Positioned widget should be an ancestor of Coyote.");
      
      final Positioned positionedWidget = tester.widget<Positioned>(positionedFinder);
      final expectedTop = testTopOffset + (testHeightOffset * currentPosition);
      expect(positionedWidget.top, expectedTop);
      expect(positionedWidget.left, testLeftPosition);
    });

    testWidgets('renders SizedBox when state is not EngineRunning (e.g., EngineInitial)', (WidgetTester tester) async {
      await pumpCoyoteAnimation(tester, initialState: EngineInitial());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Positioned), findsNothing);
      expect(find.byType(Coyote), findsNothing);
    });

    testWidgets('renders SizedBox when state is not EngineRunning (e.g., Instructions)', (WidgetTester tester) async {
      await pumpCoyoteAnimation(tester, initialState: Instructions());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Positioned), findsNothing);
      expect(find.byType(Coyote), findsNothing);
    });

    group('buildWhen condition tests', () {
      testWidgets('rebuilds when EngineRunning position changes', (WidgetTester tester) async {
        whenListen(
          mockEngineBloc,
          Stream<EngineState>.fromIterable([
            const CoyoteFalling(0.1), 
            const CoyoteFalling(0.5), 
          ]),
          initialState: const CoyoteFalling(0.1),
        );

        await pumpCoyoteAnimation(tester, initialState: const CoyoteFalling(0.1));
        var coyoteFinder = find.byType(Coyote);
        expect(coyoteFinder, findsOneWidget);
        var positionedFinder = find.ancestor(of: coyoteFinder, matching: find.byType(Positioned));
        expect(tester.widget<Positioned>(positionedFinder).top, testTopOffset + (testHeightOffset * 0.1));
        
        await tester.pump(); 
        coyoteFinder = find.byType(Coyote);
        expect(coyoteFinder, findsOneWidget);
        positionedFinder = find.ancestor(of: coyoteFinder, matching: find.byType(Positioned));
        expect(tester.widget<Positioned>(positionedFinder).top, testTopOffset + (testHeightOffset * 0.5));
      });

      testWidgets('does NOT rebuild if EngineRunning position is the same', (WidgetTester tester) async {
        int buildCount = 0;
        whenListen(
          mockEngineBloc,
          Stream<EngineState>.fromIterable([
            const CoyoteFalling(0.2),
            const CoyoteFalling(0.2),
          ]),
          initialState: const CoyoteFalling(0.2),
        );
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: 
          Stack( // Wrap in Stack here as well
            children: [
              BlocBuilder<EngineBloc, EngineState>( 
                bloc: mockEngineBloc, 
                builder: (context, state) {
                  buildCount++;
                  // When this builder runs, it returns CoyoteFallingAnimation which might return Positioned
                  return CoyoteFallingAnimation(
                    engineBloc: mockEngineBloc,
                    topOffset: testTopOffset,
                    heightOffset: testHeightOffset,
                    leftPosition: testLeftPosition,
                  );
                }
              )
            ],
          )
        )));

        await tester.pump(); 
        var coyoteFinder = find.byType(Coyote);
        expect(coyoteFinder, findsOneWidget);
        var positionedFinder = find.ancestor(of: coyoteFinder, matching: find.byType(Positioned));
        final initialTop = testTopOffset + (testHeightOffset * 0.2);
        expect(tester.widget<Positioned>(positionedFinder).top, initialTop);
        int initialBuildCount = buildCount;

        await tester.pump(); 
        coyoteFinder = find.byType(Coyote); 
        expect(coyoteFinder, findsOneWidget);
        positionedFinder = find.ancestor(of: coyoteFinder, matching: find.byType(Positioned));
        expect(tester.widget<Positioned>(positionedFinder).top, initialTop);
        expect(buildCount, initialBuildCount, reason: "buildWhen should prevent rebuild if position is same");
      });

      testWidgets('does NOT rebuild if previous state is not EngineRunning', (WidgetTester tester) async {
        whenListen(
          mockEngineBloc,
          Stream<EngineState>.fromIterable([
            EngineInitial(),
            const CoyoteFalling(0.5),
          ]),
          initialState: EngineInitial(),
        );

        await pumpCoyoteAnimation(tester, initialState: EngineInitial());
        expect(find.byType(Positioned), findsNothing);
        expect(find.byType(Coyote), findsNothing);

        await tester.pump(); 
        expect(find.byType(Positioned), findsNothing, reason: "Should not rebuild if previous was not EngineRunning");
        expect(find.byType(Coyote), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('does NOT rebuild if current state is not EngineRunning', (WidgetTester tester) async {
        whenListen(
          mockEngineBloc,
          Stream<EngineState>.fromIterable([
            const CoyoteFalling(0.5),
            EngineInitial(),
          ]),
          initialState: const CoyoteFalling(0.5),
        );

        await pumpCoyoteAnimation(tester, initialState: const CoyoteFalling(0.5));
        var coyoteFinder = find.byType(Coyote);
        expect(coyoteFinder, findsOneWidget);
        expect(find.ancestor(of: coyoteFinder, matching: find.byType(Positioned)), findsOneWidget);
        
        await tester.pump(); 
        coyoteFinder = find.byType(Coyote); 
        expect(coyoteFinder, findsOneWidget, reason: "Should not rebuild to SizedBox if current is not EngineRunning via buildWhen logic");
        expect(find.ancestor(of: coyoteFinder, matching: find.byType(Positioned)), findsOneWidget);
        expect(find.byType(SizedBox), findsNothing);
      });
    });
  });
}
