import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_coyote/provider/providers.dart';
import 'package:save_coyote/widgets/widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.engineBloc, required this.scoreBloc});

  final EngineBloc engineBloc;
  final ScoreBloc scoreBloc;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController fallController;
  late Animation<double> fallAnimation;
  late Size deviceSize;
  late EdgeInsets deviceInsets;
  final Size backgroundSize = const Size(672.0, 1000.0);

  late double roadRunnerTop;
  late double roadRunnerLeft;

  @override
  void initState() {
    super.initState();
    fallController = AnimationController(duration: randomDuration(), vsync: this);
    fallAnimation = fallAnimation = _assignFallAnimation(fallController);
  }

  @override
  void didChangeDependencies() {
    deviceSize = MediaQuery.sizeOf(context);
    deviceInsets = MediaQuery.of(context).padding;
    roadRunnerTop = (deviceSize.height * 160.0 / backgroundSize.height) - 48.0;
    roadRunnerLeft = deviceSize.width / 2 - 25.0;
    super.didChangeDependencies();
  }

  Animation<double> _assignFallAnimation(AnimationController controller) {
    controller.removeListener(coyotePositionListener);
    return CurveTween(
      curve: [
        Curves.easeInQuart,
        Curves.bounceIn,
        Curves.decelerate,
        Curves.easeInCubic,
        Curves.easeInExpo,
        Curves.easeInCirc,
        Curves.easeInOutCubic,
        Curves.easeInOutQuint,
        Curves.easeOut,
        Curves.easeOutQuart,
        Curves.linear,
      ][Random().nextInt(11)],
    ).animate(controller)..addListener(coyotePositionListener);
  }

  void coyotePositionListener() {
    widget.engineBloc.add(UpdatePositionEvent(fallAnimation.value));
  }

  Duration randomDuration({int min = 300, int max = 1700}) {
    final random = Random();
    final duration = min + random.nextInt(max - min + 1);
    return Duration(milliseconds: duration);
  }

  @override
  void dispose() {
    fallController.removeListener(coyotePositionListener);
    fallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EngineBloc, EngineState>(
      bloc: widget.engineBloc,
      listener: (context, state) {
        switch (state.runtimeType) {
          case const (CoyoteFalling):
            if ((state as CoyoteFalling).position == 0.0) {
              fallController.reset();
              fallController.forward();
            }
            break;
          case const (FailedToSaveCoyote):
            fallController.stop();
            Future.delayed(Duration(milliseconds: 500), () {
              widget.engineBloc.add(StopFallEvent((state as FailedToSaveCoyote).position));
            });
            break;
          case const (CoyoteNotSaved):
            widget.scoreBloc.add(CountFailEvent());
          case const (CoyoteSaved):
            widget.scoreBloc.add(ScoredPointsEvent((state as CoyoteSaved).score));
            break;
          case const (Instructions):
          case const (IntroScreen):
            break;
        }
        if (state is CoyoteStopped) {
          fallController.stop();
          Duration duration = randomDuration();
          fallController.duration = duration;
          fallAnimation = _assignFallAnimation(fallController);
        }
      },
      child: Stack(
        children: [
          Stack(
            fit: StackFit.expand,
            children: [
              CoyoteFallingAnimation(
                engineBloc: widget.engineBloc,
                topOffset: roadRunnerTop,
                heightOffset: deviceSize.height - deviceInsets.top - deviceInsets.bottom - 150,
                leftPosition: roadRunnerLeft + 50.0,
              ),
              Positioned(
                bottom: deviceInsets.bottom + 50.0,
                right: 50.0,
                child: RepaintBoundary(child: SmokeAnimation(engineBloc: widget.engineBloc)),
              ),
              Positioned(
                top: roadRunnerTop,
                left: roadRunnerLeft,
                child: RepaintBoundary(child: const RoadRunner()),
              ),
              Positioned(bottom: deviceInsets.bottom, right: 0.0, child: Rocks()),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (_) => widget.engineBloc.add(TapRegisteredEvent(fallAnimation.value)),
                child: SizedBox.expand(),
              ),
              SignAnimation(engineBloc: widget.engineBloc, bottom: deviceInsets.bottom - deviceInsets.bottom - 30.0),
              Positioned(
                right: 20.0,
                top: deviceInsets.top + 8.0,
                child: PlayerName(scoreBloc: widget.scoreBloc),
              ),
              Positioned(
                left: 10.0,
                right: 10.0,
                bottom: deviceInsets.bottom,
                child: ScoreCounters(scoreBloc: widget.scoreBloc),
              ),
              InstructionsWidget(engineBloc: widget.engineBloc),
              IntroWidget(engineBloc: widget.engineBloc),
            ],
          ),
        ],
      ),
    );
  }
}
