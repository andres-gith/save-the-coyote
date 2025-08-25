part of 'widgets.dart';

class Coyote extends StatelessWidget {
  const Coyote({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: Image.asset('assets/coyote_falling.png', height: 50));
  }
}
