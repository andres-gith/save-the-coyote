import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/provider/providers.dart';
import 'package:save_coyote/screens/screens.dart';
import 'package:save_coyote/styles/styles.dart';
import 'package:save_coyote/widgets/widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.engineBloc, required this.scoreBloc});

  final EngineBloc engineBloc;
  final ScoreBloc scoreBloc;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController fallController;
  late Animation<double> fallAnimation;
  late AnimationController signController;
  late Animation<double> signAnimation;

  late Size deviceSize;
  late EdgeInsets deviceInsets;
  final Size backgroundSize = const Size(672.0, 1000.0);
  final smokeController = GifController();
  late final GifView smokeImage;

  late double roadRunnerTop;
  late double roadRunnerLeft;

  @override
  void initState() {
    super.initState();
    smokeImage = GifView.asset('assets/smoke2.gif', controller: smokeController);
    fallController = AnimationController(duration: randomDuration(), vsync: this);
    fallAnimation = fallAnimation = _assignFallAnimation(fallController);
    signController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    signAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurveTween(curve: Curves.bounceOut).animate(signController));
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

  void resetSmoke() {
    smokeController.play();
  }

  void coyotePositionListener() {
    widget.engineBloc.add(UpdatePositionEvent(fallAnimation.value));
  }

  void startFall() {
    widget.engineBloc.add(StartFallEvent());
  }

  void stopFall() {
    widget.engineBloc.add(StopFallEvent(fallAnimation.value));
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
    signController.dispose();
    smokeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EngineBloc, EngineState>(
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
            resetSmoke();
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
          signController.reset();
          signController.forward();
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Stack(
              fit: StackFit.expand,
              children: [
                if (state is EngineRunning)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 0),
                    top:
                        roadRunnerTop +
                        ((deviceSize.height - deviceInsets.top - deviceInsets.bottom - 150) * state.position),
                    left: roadRunnerLeft + 50.0,
                    child: const Coyote(),
                  ),
                Visibility(
                  visible: state is FailedToSaveCoyote,
                  child: Positioned(bottom: deviceInsets.bottom + 50.0, right: 50.0, child: smokeImage),
                ),
                Positioned(
                  //top: 98.0,
                  //left: 180.0,
                  top: roadRunnerTop,
                  left: roadRunnerLeft,
                  child: RepaintBoundary(child: const RoadRunner()),
                ),
                Positioned(bottom: deviceInsets.bottom, right: 0.0, child: Rocks()),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) {
                    if (state is CoyoteFalling) {
                      stopFall();
                    } else if (state is CoyoteStopped) {
                      startFall();
                    }
                  },
                  child: SizedBox.expand(),
                ),
                if (state is CoyoteStopped)
                  Positioned(
                    bottom: deviceInsets.bottom - deviceInsets.bottom - 30.0,
                    left: 0.0,
                    child: AnimatedSign(
                      animation: signAnimation,
                      title: state is CoyoteSaved ? '${state.score}!' : AppLocalizations.of(context)!.youFailed,
                      fontSize: state is CoyoteSaved ? 52.0 : 30.0,
                      fontColor: state is CoyoteSaved ? Styles.colorBrown : Styles.colorRed,
                    ),
                  ),
                Positioned(
                  right: 20.0,
                  top: deviceInsets.top + 8.0,
                  child: BlocConsumer<ScoreBloc, ScoreState>(
                    listener: (context, state) {
                      if (state is ChangeRecordedName) {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black54,
                          barrierDismissible: false,
                          builder: (context) => SaveNameDialog(
                            lastRecordedName: state.lastRecordedName,
                            onSave: (String name) {
                              widget.scoreBloc.add(SaveRecordNameEvent(name));
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return state is ScoreReady && (state.lastRecordedName?.isNotEmpty ?? false)
                          ? GestureDetector(
                              onTap: () => widget.scoreBloc.add(ChangeRecordedNameEvent()),
                              child: Text(
                                '${state.lastRecordedName?.toUpperCase()}',
                                style: TextStyle(color: Styles.colorYellow, fontSize: 18),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
                Positioned(
                  left: 10.0,
                  right: 10.0,
                  bottom: deviceInsets.bottom,
                  child: ScoreCounters(scoreBloc: widget.scoreBloc),
                ),
                if (state is Instructions) InstructionsText(onTap: startFall),
                if (state is IntroScreen) IntroGif(onViewed: () => widget.engineBloc.add(ShowInstructions())),
              ],
            ),
          ],
        );
      },
    );
  }
}
