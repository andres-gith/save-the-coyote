part of 'widgets.dart';

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({super.key, required this.animation, required this.counter, required this.onTap, required this.fontColor});
  final Animation<double> animation;
  final int counter;
  final VoidCallback onTap;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Counter(
        counter: counter,
        fontColor: fontColor,
        onTap: onTap,
      ),
    );
  }
}
