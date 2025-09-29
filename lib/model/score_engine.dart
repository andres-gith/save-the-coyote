import 'package:save_coyote/repository/score_repository.dart';
import 'score_model.dart';

class ScoreEngine {
  ScoreEngine(ScoreRepository scoreRepository) : _scoreRepository = scoreRepository;
  final ScoreRepository _scoreRepository;

  late int _counterValue;
  late int _failCounterValue;
  late int? _minScoreValue;
  late String _lastRecordedName;
  late int _recordValue;
  late List<ScoreModel> _maxScoresList;

  Future<void> initialize() async {
    await _scoreRepository.initialize();
    _counterValue = _scoreRepository.getCounterValue();
    _failCounterValue = _scoreRepository.getFailCounterValue();
    _minScoreValue = _scoreRepository.getMinScoreValue();
    _lastRecordedName = _scoreRepository.getLastRecordedName();
    _recordValue = _scoreRepository.getRecordValue();
    _maxScoresList = _scoreRepository.getMaxScoresList();
  }

  int get counterValue => _counterValue;

  set counterValue(int value) {
    _counterValue = value;
    _scoreRepository.setCounterValue(value);
  }

  int get failCounterValue => _failCounterValue;

  set failCounterValue(int value) {
    _failCounterValue = value;
    _scoreRepository.setFailCounterValue(value);
  }

  int? get minScoreValue => _minScoreValue;

  set minScoreValue(int? value) {
    _minScoreValue = value;
    _scoreRepository.setMinScoreValue(value ?? 0);
  }

  String get lastRecordedName => _lastRecordedName;

  set lastRecordedName(String value) {
    String sanitizedName = _sanitizeName(value);
    _lastRecordedName = sanitizedName;
    _scoreRepository.setLastRecordedName(sanitizedName);
  }

  int get recordValue => _recordValue;

  set recordValue(int value) {
    _recordValue = value;
    _scoreRepository.setRecordValue(value);
  }

  List<ScoreModel> get maxScoresList => _maxScoresList;

  set maxScoresList(List<ScoreModel> value) {
    _maxScoresList = value;
    _scoreRepository.setMaxScoresList(value);
  }

  Future<void> incrementCounter() async {
    counterValue = _counterValue + 1;
  }

  Future<void> incrementFailCounter() async {
    failCounterValue = _failCounterValue + 1;
  }

  Future<void> saveScore(int score) async {
    final newScoreResults = _addValue(_maxScoresList, score, _counterValue, _lastRecordedName);
    maxScoresList = newScoreResults;
    minScoreValue = _getLesserScore(minScoreValue, score);
  }

  List<ScoreModel> _addValue(List<ScoreModel> scores, int score, int counter, String name) {
    List<ScoreModel> newScores = List.of(scores);
    newScores.add(ScoreModel(score: score, counter: counter, name: name));
    newScores.sort((a, b) => b.score.compareTo(a.score));

    return newScores.take(10).toList();
  }

  int _getLesserScore(int? oldValue, int newValue) {
    return oldValue == null
        ? newValue
        : oldValue < newValue
        ? oldValue
        : newValue;
  }

  String _sanitizeName(String value) {
    return value.replaceAll(RegExp(r'[^\w\s]'), '');
  }
}
