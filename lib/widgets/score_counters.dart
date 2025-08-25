part of 'widgets.dart';

class ScoreCounters extends StatefulWidget {
  const ScoreCounters({super.key, required this.scoreBloc});

  final ScoreBloc scoreBloc;

  @override
  State<ScoreCounters> createState() => _ScoreCountersState();
}

class _ScoreCountersState extends State<ScoreCounters> with TickerProviderStateMixin {
  late AnimationController savedCounterController;
  late Animation<double> savedCounterScaleAnimation;
  late AnimationController failCounterController;
  late Animation<double> failCounterScaleAnimation;

  @override
  void initState() {
    super.initState();

    savedCounterController = AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    savedCounterScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.bounceOut)), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 1),
    ]).animate(savedCounterController);
    failCounterController = AnimationController(vsync: this, duration: Duration(milliseconds: 900));
    failCounterScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.bounceOut)), weight: 6),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.decelerate)), weight: 1),
    ]).animate(failCounterController);
  }

  @override
  void dispose() {
    savedCounterController.dispose();
    failCounterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreBloc, ScoreState>(
      listener: (context, state) {
        if (state is ScoreResults) {
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            barrierDismissible: false,
            builder: (context) => ScoreResultsScreen(
              onDismiss: () => widget.scoreBloc.add(DismissScoresEvent()),
              failCounter: state.failCounter,
              counter: state.counter,
              maxScores: state.maxScores,
              minScore: state.minScore,
            ),
          );
        } else if (state is ScoredPoints) {
          savedCounterController.reset();
          savedCounterController.forward();
        } else if (state is ScoredFail) {
          failCounterController.reset();
          failCounterController.forward();
        } else if (state is NewRecord) {
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            barrierDismissible: false,
            builder: (context) => RecordScreen(
              lastRecordedName: state.lastRecordedName,
              record: state.score,
              onSave: (String name) {
                widget.scoreBloc.add(SaveRecordEvent(state.score, name));
                Navigator.of(context).pop();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return state is ScoreReady
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedCounter(
                    animation: savedCounterScaleAnimation,
                    counter: state.counter - state.failCounter,
                    fontColor: Styles.colorYellow,
                    onTap: () => widget.scoreBloc.add(ShowScoresEvent()),
                  ),
                  AnimatedCounter(
                    animation: failCounterScaleAnimation,
                    counter: state.failCounter,
                    fontColor: Styles.colorRed,
                    onTap: () => widget.scoreBloc.add(ShowScoresEvent()),
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }
}
