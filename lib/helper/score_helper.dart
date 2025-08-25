class ScoreHelper {
  static List<String> addValue(List<String> scores, int score, int counter, String name) {
    List<String> newScores = List.of(scores);
    newScores.add('$score|$counter|$name');
    newScores.sort((a, b) => int.parse(b.split('|')[0]).compareTo(int.parse(a.split('|')[0])));

    return newScores.take(10).toList();
  }

  static int getLesserScore(int? oldValue, int newValue) {
    return oldValue == null
        ? newValue
        : oldValue < newValue
        ? oldValue
        : newValue;
  }
}
