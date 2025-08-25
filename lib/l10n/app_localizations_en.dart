// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get appTitle => 'Save the Coyote';

  @override
  String get instructionsTitle => 'SAVE THE COYOTE!';

  @override
  String get instructionsDescription =>
      'Tap the screen to save the Coyote from falling.';

  @override
  String get newRecord => 'NEW RECORD';

  @override
  String scoreScreenSaved1(num times) {
    final intl.NumberFormat timesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String timesString = timesNumberFormat.format(times);

    String _temp0 = intl.Intl.pluralLogic(
      times,
      locale: localeName,
      other: 'YOU SAVED THE COYOTE',
      zero: 'YOU DIDN\'T SAVED THE COYOTE YET',
    );
    return '$_temp0';
  }

  @override
  String scoreScreenSaved2(num times) {
    final intl.NumberFormat timesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String timesString = timesNumberFormat.format(times);

    String _temp0 = intl.Intl.pluralLogic(
      times,
      locale: localeName,
      other: 'TIMES',
      one: 'ONCE',
      zero: '',
    );
    return '$_temp0,';
  }

  @override
  String scoreScreenSaved3(num times) {
    final intl.NumberFormat timesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String timesString = timesNumberFormat.format(times);

    String _temp0 = intl.Intl.pluralLogic(
      times,
      locale: localeName,
      other: 'AND HE FELL',
      zero: 'AND HE DIDN\'T FELL YET',
    );
    return '$_temp0';
  }

  @override
  String get scoreTableTitle1 => 'SCORE';

  @override
  String get scoreTableTitle2 => 'PLAYER';

  @override
  String get scoreTableTitle3 => '(COUNTER)';

  @override
  String get yourMinimumScore => 'YOUR MINIMUM SCORE IS';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get save => 'SAVE';

  @override
  String get youFailed => 'YOU FAILED!';
}
