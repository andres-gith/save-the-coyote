part of 'widgets.dart';

class NewRecordVerbiage extends StatelessWidget {
  const NewRecordVerbiage({super.key, required this.record});

  final int record;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: AppLocalizations.of(context)!.newRecord),
          TextSpan(
            text: ' $record',
            style: TextStyle(fontSize: 32.0, color: Styles.colorYellow),
          ),
          TextSpan(text: '!'),
        ],
        style: Styles.fontStyle.copyWith(fontSize: 28.0),
      ),
    );
  }
}
