part of 'widgets.dart';

class RoadRunner extends StatelessWidget {
  const RoadRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoadRunnerBloc(),
      child: BlocConsumer<RoadRunnerBloc, RoadRunnerState>(
        listener: (context, state) {
          var roadRunnerBloc = BlocProvider.of<RoadRunnerBloc>(context);
          if (state is RoadRunnerBeep) {
            Future.delayed(const Duration(milliseconds: 500), () => roadRunnerBloc.add(RoadRunnerGoBackToIdle()));
          }
        },
        builder: (context, state) {
          var roadRunnerBloc = BlocProvider.of<RoadRunnerBloc>(context);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                right: -35,
                child: Visibility(
                  visible: state is RoadRunnerBeep,
                  child: Text('BEEP!\nBEEP!', style: Styles.fontStyle),
                ),
              ),
              GestureDetector(
                onTap: () => roadRunnerBloc.add(RoadRunnerTap()),
                child: GifView.asset('assets/roadrunner.gif', height: 50, fadeDuration: Duration(milliseconds: 100)),
              ),
            ],
          );
        },
      ),
    );
  }
}
