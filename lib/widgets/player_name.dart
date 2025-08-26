part of 'widgets.dart';

class PlayerName extends StatelessWidget {
  const PlayerName({super.key, required this.scoreBloc});
  final ScoreBloc scoreBloc;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScoreBloc, ScoreState>(
      listener: (context, state) {
        if (state is ChangeRecordedName) {
          showDialog(
            context: context,
            barrierColor: Colors.black54,
            barrierDismissible: false,
            builder: (context) =>
                SaveNameDialog(
                  lastRecordedName: state.lastRecordedName,
                  onSave: (String name) {
                    scoreBloc.add(SaveRecordNameEvent(name));
                    Navigator.of(context).pop();
                  },
                ),
          );
        }
      },
      builder: (context, state) {
        return state is ScoreReady && (state.lastRecordedName?.isNotEmpty ?? false)
            ? GestureDetector(
          onTap: () => scoreBloc.add(ChangeRecordedNameEvent()),
          child: Text(
            '${state.lastRecordedName?.toUpperCase()}',
            style: TextStyle(color: Styles.colorYellow, fontSize: 18),
          ),
        )
            : const SizedBox.shrink();
      },
    );
  }
}
