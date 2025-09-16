import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:save_coyote/provider/score_bloc.dart';
import 'package:save_coyote/widgets/widgets.dart'; // Assuming PlayerName is part of widgets.dart

// Mocks
class MockScoreBloc extends MockBloc<ScoreEvent, ScoreState> implements ScoreBloc {}

// Minimal Styles mock
class Styles {
  static Color colorYellow = Colors.yellow;
}

// Placeholder for SaveNameDialog to test dialog interaction
class SaveNameDialog extends StatelessWidget {
  final String? lastRecordedName;
  final Function(String) onSave;

  const SaveNameDialog({super.key, this.lastRecordedName, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: lastRecordedName ?? '');
    return AlertDialog(
      title: const Text('Enter Name'), // Placeholder title
      content: TextField(controller: controller, autofocus: true, key: const Key('name_dialog_textfield')),
      actions: [
        TextButton(
          key: const Key('name_dialog_save_button'),
          child: const Text('Save'),
          onPressed: () => onSave(controller.text),
        ),
      ],
    );
  }
}

void main() {
  late MockScoreBloc mockScoreBloc;

  setUpAll(() {
    registerFallbackValue(ScoreReadyEvent());
  });

  setUp(() {
    mockScoreBloc = MockScoreBloc();
    // Default stub for add, can be overridden if specific event verification is needed beyond just call count
    when(() => mockScoreBloc.add(any())).thenReturn(null); 
  });

  Future<void> pumpPlayerName(WidgetTester tester, {ScoreState? initialState}) async {
    when(() => mockScoreBloc.state).thenReturn(initialState ?? ScoreInitial());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerName(scoreBloc: mockScoreBloc),
        ),
      ),
    );
  }

  group('PlayerName Widget Tests', () {
    group('Builder Logic', () {
      testWidgets('displays name when state is ScoreReady with non-empty name', (WidgetTester tester) async {
        const playerName = 'COYOTE';
        when(() => mockScoreBloc.state).thenReturn(const ScoreReady(lastRecordedName: playerName, counter: 0, failCounter: 0));
        
        await pumpPlayerName(tester, initialState: const ScoreReady(lastRecordedName: playerName, counter: 0, failCounter: 0));

        final nameTextFinder = find.text(playerName.toUpperCase());
        expect(nameTextFinder, findsOneWidget);

        final Text nameTextWidget = tester.widget<Text>(nameTextFinder);
        expect(nameTextWidget.style?.color, Styles.colorYellow);
        expect(nameTextWidget.style?.fontSize, 18);

        // Verify tap action
        await tester.tap(nameTextFinder);
        verify(() => mockScoreBloc.add(ChangeRecordedNameEvent())).called(1);
      });

      testWidgets('displays SizedBox.shrink when name is empty in ScoreReady', (WidgetTester tester) async {
        await pumpPlayerName(tester, initialState: const ScoreReady(lastRecordedName: '', counter: 0, failCounter: 0));
        expect(find.byType(SizedBox), findsOneWidget); // Specifically SizedBox.shrink()
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('displays SizedBox.shrink when name is null in ScoreReady', (WidgetTester tester) async {
        await pumpPlayerName(tester, initialState: const ScoreReady(lastRecordedName: null, counter: 0, failCounter: 0));
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('displays SizedBox.shrink for ScoreInitial state', (WidgetTester tester) async {
        await pumpPlayerName(tester, initialState: ScoreInitial());
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });
    });
  });
}
