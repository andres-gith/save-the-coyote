part of 'widgets.dart';

class Counter extends StatelessWidget {
  const Counter({super.key, required this.counter, required this.fontColor, required this.onTap});

  final int counter;
  final VoidCallback onTap;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: counter > 0,
      child: TextButton(
        onPressed: onTap,
        child: Text('$counter', style: Styles.fontStyle.copyWith(color: fontColor, fontSize: 40.0)),
      ),
    );
  }
}
