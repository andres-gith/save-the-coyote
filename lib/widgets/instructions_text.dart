part of 'widgets.dart';

class InstructionsText extends StatelessWidget {
  const InstructionsText({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(
                text: '${AppLocalizations.of(context)!.instructionsTitle}\n\n',
                style: TextStyle(fontSize: 40, color: Colors.yellow),
              ),
              TextSpan(
                text: '${AppLocalizations.of(context)!.instructionsDescription}\n',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          style: Styles.fontStyle,
        ),
      ),
    );
  }
}
