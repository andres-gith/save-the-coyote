part of 'widgets.dart';

class ScoreResultTitle extends StatelessWidget {
  const ScoreResultTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AutoSizeText(
        title,
        style: Styles.fontStyle.copyWith(fontSize: 20.0, color: Styles.colorBrown),
        maxLines: 1,
      ),
    );
  }
}
