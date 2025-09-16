import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/provider/engine_bloc.dart';
import 'package:save_coyote/widgets/widgets.dart'; // Assuming IntroWidget is part of widgets.dart

// Mocks
class MockEngineBloc extends MockBloc<EngineEvent, EngineState> implements EngineBloc {}

void main() {
  late MockEngineBloc mockEngineBloc;

  setUpAll(() {
    registerFallbackValue(OnLoadEvent());
  });

  setUp(() {
    mockEngineBloc = MockEngineBloc();
    // Default stub for add, can be overridden if specific event verification is needed
    when(() => mockEngineBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpIntroWidget(WidgetTester tester, {required EngineState initialState}) async {
    // Stub the initial state of the bloc
    when(() => mockEngineBloc.state).thenReturn(initialState);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IntroWidget(engineBloc: mockEngineBloc),
        ),
      ),
    );
  }

  group('IntroWidget Tests', () {
    testWidgets('renders IntroGif when EngineBloc state is IntroScreen', (WidgetTester tester) async {
      await pumpIntroWidget(tester, initialState: IntroScreen());

      expect(find.byType(IntroGif), findsOneWidget);
      //expect(find.byType(SizedBox), findsNothing); // Or findsOneWidget if IntroGif contains SizedBox internally
                                                  // Based on placeholder, IntroGif doesn't contain SizedBox directly.
    });

    testWidgets('renders SizedBox when EngineBloc state is not IntroScreen', (WidgetTester tester) async {
      await pumpIntroWidget(tester, initialState: EngineInitial()); // Any state other than IntroScreen

      expect(find.byType(IntroGif), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget); // The one returned by IntroWidget itself
    });

    testWidgets('renders SizedBox for another non-IntroScreen state', (WidgetTester tester) async {
      await pumpIntroWidget(tester, initialState: const CoyoteFalling(0.5)); 

      expect(find.byType(IntroGif), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('IntroGif onViewed callback adds ShowInstructions event to EngineBloc', (WidgetTester tester) async {
      // Ensure the bloc is in the IntroScreen state to render IntroGif
      await pumpIntroWidget(tester, initialState: IntroScreen());

      // Find the placeholder IntroGif and simulate its onViewed callback
      // (Our placeholder uses an ElevatedButton to trigger `onViewed`)
      final introGifViewedTrigger = find.byType(GestureDetector);
      expect(introGifViewedTrigger, findsOneWidget);

      await tester.tap(introGifViewedTrigger);
      await tester.pump(); // Allow for event processing

      // Verify that ShowInstructions event was added to the bloc
      verify(() => mockEngineBloc.add(ShowInstructions())).called(1);
    });
  });
}
