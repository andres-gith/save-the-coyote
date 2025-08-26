part of 'widgets.dart';

class SignAnimation extends StatefulWidget {
  const SignAnimation({super.key, required this.engineBloc, required this.bottom});

  final EngineBloc engineBloc;
  final double bottom;

  @override
  State<SignAnimation> createState() => _SignAnimationState();
}

class _SignAnimationState extends State<SignAnimation> with SingleTickerProviderStateMixin {
  late AnimationController signController;
  late Animation<double> signAnimation;

  @override
  void initState() {
    super.initState();
    signController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    signAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurveTween(curve: Curves.bounceOut).animate(signController));
  }

  @override
  void dispose() {
    signController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: widget.engineBloc,
      listenWhen: (previous, current) => current is CoyoteStopped,
      listener: (context, state) {
        if (state is CoyoteStopped) {
          signController.reset();
          signController.forward();
        }
      },
      buildWhen: (previous, current) => current is CoyoteStopped || previous is CoyoteStopped,
      builder: (context, state) {
        return Visibility(
          visible: state is CoyoteStopped,
          child: Positioned(
            bottom: widget.bottom,
            left: 0.0,
            child: AnimatedSign(
              animation: signAnimation,
              title: state is CoyoteSaved ? '${state.score}!' : AppLocalizations.of(context)!.youFailed,
              fontSize: state is CoyoteSaved ? 52.0 : 30.0,
              fontColor: state is CoyoteSaved ? Styles.colorBrown : Styles.colorRed,
            ),
          ),
        );
      },
    );
  }
}
