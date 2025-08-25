import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_view/gif_view.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/provider/providers.dart';
import 'package:save_coyote/screens/home.dart';
import 'package:save_coyote/styles/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  GifView.preFetchImage(AssetImage('assets/roadrunner.gif'));
  GifView.preFetchImage(AssetImage('assets/smoke2.gif'));
  await GifView.preFetchImage(AssetImage('assets/intro.gif'));
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<EngineBloc>(
          create: (context) => EngineBloc()..initialize(),
        ),
        BlocProvider<ScoreBloc>(
          create: (context) => ScoreBloc()..initialize(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Save Coyote',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        fontFamily: "GROBOLD",
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Styles.colorBrown, // Selection highlight color
          cursorColor: Colors.white,          // Cursor color
          selectionHandleColor: Styles.colorBrown, // Handle color
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

