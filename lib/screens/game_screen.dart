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

class _GameScreenState extends State<GameScreen> {
  late Size deviceSize;
  late EdgeInsets deviceInsets;
  final Size backgroundSize = const Size(672.0, 1000.0);

  late double roadRunnerTop;
  late double roadRunnerLeft;
  bool deviceSizeInitialized = false;

  @override
  void didChangeDependencies() {
    if (!deviceSizeInitialized) {
      deviceSize = MediaQuery.sizeOf(context);
      deviceInsets = MediaQuery.paddingOf(context);
      roadRunnerTop = (deviceSize.height * 160.0 / backgroundSize.height) - 48.0;
      roadRunnerLeft = deviceSize.width / 2 - 25.0;
      deviceSizeInitialized = true;
    }
    super.didChangeDependencies();
  }

  Duration randomDuration({int min = 300, int max = 1700}) {
    final random = Random();
    final duration = min + random.nextInt(max - min + 1);
    return Duration(milliseconds: duration);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EngineBloc, EngineState>(
      bloc: widget.engineBloc,
      listener: (context, state) {
        if (state is CoyoteNotSaved) {
          widget.scoreBloc.add(CountFailEvent());
        }
        if (state is CoyoteSaved) {
          widget.scoreBloc.add(ScoredPointsEvent(state.score));
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
                onTapDown: (_) => widget.engineBloc.add(TapRegisteredEvent()),
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
