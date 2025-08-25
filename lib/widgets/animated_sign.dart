part of 'widgets.dart';

class AnimatedSign extends StatelessWidget {
  const AnimatedSign({
    super.key,
    required this.animation,
    required this.title,
    required this.fontSize,
    required this.fontColor,
  });

  final Animation<double> animation;
  final String title;
  final double fontSize;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) //
            ..rotateX(animation.value * pi), // perspective
          child: child,
        );
      },
      child: Sign(title: title, fontSize: fontSize, fontColor: fontColor),
    );
  }
}
