part of 'widgets.dart';

class InstructionsWidget extends StatelessWidget {
  const InstructionsWidget({super.key, required this.engineBloc});

  final EngineBloc engineBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: engineBloc,
      buildWhen: (previous, current) => current is Instructions || previous is Instructions,
      builder: (context, state) =>
          state is Instructions ? InstructionsText(onTap: () => engineBloc.add(StartFallEvent())) : const SizedBox(),
    );
  }
}
