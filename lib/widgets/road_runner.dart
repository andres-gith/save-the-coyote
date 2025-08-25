part of 'widgets.dart';

class RoadRunner extends StatelessWidget {
  const RoadRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return GifView.asset('assets/roadrunner.gif', height: 50, fadeDuration: Duration(milliseconds: 100),);
  }
}
