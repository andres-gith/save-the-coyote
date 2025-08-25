import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_coyote/provider/providers.dart';
import 'package:save_coyote/screens/game_screen.dart';
import 'package:save_coyote/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundImage(
        child: GameScreen(
          engineBloc: BlocProvider.of<EngineBloc>(context),
          scoreBloc: BlocProvider.of<ScoreBloc>(context),
        ),
      ),
    );
  }
}
