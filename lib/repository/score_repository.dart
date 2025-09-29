import 'package:save_coyote/model/score_model.dart';

abstract interface class ScoreRepository {
  Future<void> initialize();

  int getCounterValue();
  void setCounterValue(int value);

  int getFailCounterValue();
  void setFailCounterValue(int value);

  int? getMinScoreValue();
  void setMinScoreValue(int value);

  String getLastRecordedName();
  void setLastRecordedName(String name);

  int getRecordValue();
  void setRecordValue(int value);

  List<ScoreModel> getMaxScoresList();
  void setMaxScoresList(List<ScoreModel> scores);

}