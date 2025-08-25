part of 'widgets.dart';

class Rocks extends StatelessWidget {
  const Rocks({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: Image.asset('assets/rocks.png', height: 300));
  }
}
