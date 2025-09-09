part of 'widgets.dart';

class CoyoteFallingAnimation extends StatelessWidget {
  const CoyoteFallingAnimation({
    super.key,
    required this.engineBloc,
    required this.topOffset,
    required this.heightOffset,
    required this.leftPosition,
  });

  final EngineBloc engineBloc;
  final double topOffset;
  final double heightOffset;
  final double leftPosition;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: engineBloc,
      buildWhen: (previous, current) {
        return current is EngineRunning && previous is EngineRunning && previous.position != current.position;
      },
      builder: (context, state) {
        return state is EngineRunning
            ? Positioned(
                top: topOffset + (heightOffset * state.position),
                left: leftPosition,
                child: const Coyote(),
              )
            : const SizedBox();
      },
    );
  }
}
