part of 'widgets.dart';

class SmokeAnimation extends StatefulWidget {
  const SmokeAnimation({super.key, required this.engineBloc});

  final EngineBloc engineBloc;

  @override
  State<SmokeAnimation> createState() => _SmokeAnimationState();
}

class _SmokeAnimationState extends State<SmokeAnimation> {
  final smokeController = GifController();
  late final GifView smokeImage;

  @override
  void initState() {
    super.initState();
    smokeImage = GifView.asset(
      'assets/smoke2.gif',
      controller: smokeController,
      loop: false,
      onFinish: () => widget.engineBloc.add(StopFallEvent()),
    );
  }

  @override
  void dispose() {
    smokeController.dispose();
    super.dispose();
  }

  void resetSmoke() {
    smokeController.play();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EngineBloc, EngineState>(
      bloc: widget.engineBloc,
      listenWhen: (previous, current) => current is CoyoteFell,
      listener: (context, state) => resetSmoke(),
      buildWhen: (previous, current) => current is CoyoteFell || previous is CoyoteFell,
      builder: (context, state) => Visibility(visible: state is CoyoteFell, child: smokeImage),
    );
  }
}
