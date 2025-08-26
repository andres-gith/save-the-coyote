part of 'widgets.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.engineBloc});

  final EngineBloc engineBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: engineBloc,
      buildWhen: (previous, current) => current is IntroScreen || previous is IntroScreen,
      builder: (context, state) => Visibility(
        visible: state is IntroScreen,
        child: IntroGif(onViewed: () => engineBloc.add(ShowInstructions())),
      ),
    );
  }
}
