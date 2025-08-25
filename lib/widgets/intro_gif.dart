part of 'widgets.dart';

class IntroGif extends StatelessWidget {
  const IntroGif({super.key, required this.onViewed});

  final VoidCallback onViewed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewed,
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: RepaintBoundary(child: GifView.asset('assets/intro.gif', height: 300, onFinish: onViewed, loop: false)),
      ),
    );
  }
}
