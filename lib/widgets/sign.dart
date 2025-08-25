part of 'widgets.dart';

class Sign extends StatelessWidget {
  const Sign({super.key, required this.title, this.fontSize = 32, this.fontColor = Colors.red});

  final String title;
  final double fontSize;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RepaintBoundary(child: Image.asset('assets/sign.png', height: 300)),
        Positioned(
          top: 55,
          child: SizedBox.fromSize(
            size: Size(190.0, 110.0),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Styles.fontStyle.copyWith(fontSize: fontSize, color: fontColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
