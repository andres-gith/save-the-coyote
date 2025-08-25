// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get appTitle => 'Salva al Coyote';

  @override
  String get instructionsTitle => 'SALVA AL COYOTE!';

  @override
  String get instructionsDescription =>
      'Toca la pantalla para detener al Coyote y salvarlo de la caida.';

  @override
  String get newRecord => 'NUEVO RECORD';

  @override
  String scoreScreenSaved1(num times) {
    final intl.NumberFormat timesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String timesString = timesNumberFormat.format(times);

    String _temp0 = intl.Intl.pluralLogic(
      times,
      locale: localeName,
      other: 'SALVASTE AL COYOTE',
      zero: 'AUN NO SALVASTE AL COYOTE',
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
      other: 'VECES',
      one: 'VEZ',
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
      other: 'Y SE CAYO',
      zero: 'Y AUN NO SE CAYO',
    );
    return '$_temp0';
  }

  @override
  String get scoreTableTitle1 => 'PUNTAJE';

  @override
  String get scoreTableTitle2 => 'JUGADOR';

  @override
  String get scoreTableTitle3 => '(CONTADOR)';

  @override
  String get yourMinimumScore => 'TU PUNTAJE MINIMO ES';

  @override
  String get enterYourName => 'Ingresa tu nombre';

  @override
  String get save => 'GUARDAR';

  @override
  String get youFailed => 'FALLASTE!';
}
