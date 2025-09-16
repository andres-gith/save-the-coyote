import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/model/score_engine.dart';
import 'package:save_coyote/provider/providers.dart';
import 'package:save_coyote/repository/shared_preferences_score.dart';
import 'package:save_coyote/screens/home.dart';
import 'package:save_coyote/styles/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  GifView.preFetchImage(AssetImage('assets/roadrunner.gif'));
  GifView.preFetchImage(AssetImage('assets/smoke2.gif'));
  await GifView.preFetchImage(AssetImage('assets/intro.gif'));
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<EngineBloc>(create: (context) => EngineBloc()..add(OnLoadEvent())),
        BlocProvider<ScoreBloc>(
          create: (context) => ScoreBloc(engine: ScoreEngine(SharedPreferencesScore()))..add(OnLoadScoreEvent()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Save Coyote',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        fontFamily: "TADEO",
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Styles.colorBrown, // Selection highlight color
          cursorColor: Colors.white, // Cursor color
          selectionHandleColor: Styles.colorBrown, // Handle color
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
