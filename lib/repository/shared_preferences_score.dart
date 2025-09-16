import 'package:save_coyote/repository/score_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesScore implements ScoreRepository {
  late SharedPreferences prefs;

  static const String failCounterKey = 'fail';
  static const String counterKey = 'counter';
  static const String maxScoresListKey = 'maxScoreList';
  static const String minScoreKey = 'minScore';
  static const String lastRecordedNameKey = 'lastRecordedName';
  static const String scoreRecordKey = 'record';

  @override
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  int getCounterValue() {
    return prefs.getInt(counterKey) ?? 0;
  }

  @override
  void setCounterValue(int value) async {
    await prefs.setInt(counterKey, value);
  }

  @override
  int getFailCounterValue() {
    return prefs.getInt(failCounterKey) ?? 0;
  }

  @override
  void setFailCounterValue(int value) async {
    await prefs.setInt(failCounterKey, value);
  }

  @override
  int? getMinScoreValue() {
    return prefs.getInt(minScoreKey);
  }

  @override
  void setMinScoreValue(int value) async {
    await prefs.setInt(minScoreKey, value);
  }

  @override
  String getLastRecordedName() {
    return prefs.getString(lastRecordedNameKey) ?? '';
  }

  @override
  void setLastRecordedName(String name) async {
    await prefs.setString(lastRecordedNameKey, name);
  }

  @override
  int getRecordValue() {
    return prefs.getInt(scoreRecordKey) ?? 0;
  }

  @override
  void setRecordValue(int value) async {
    await prefs.setInt(scoreRecordKey, value);
  }

  @override
  List<String> getMaxScoresList() {
    return prefs.getStringList(maxScoresListKey) ?? List<String>.empty();
  }

  @override
  void setMaxScoresList(List<String> scores) async {
    await prefs.setStringList(maxScoresListKey, scores);
  }
}
