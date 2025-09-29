import 'package:flutter/material.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/model/score_model.dart';
import 'package:save_coyote/styles/styles.dart';
import 'package:save_coyote/widgets/widgets.dart';

class ScoreResultsScreen extends StatelessWidget {
  const ScoreResultsScreen({
    super.key,
    required this.onDismiss,
    required this.failCounter,
    required this.counter,
    required this.maxScores,
    this.minScore,
  });

  final VoidCallback onDismiss;
  final int failCounter;
  final int counter;
  final List<ScoreModel> maxScores;
  final int? minScore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              icon: Text('X', style: Styles.fontStyle.copyWith(fontSize: 40.0)),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: AppLocalizations.of(context)!.scoreScreenSaved1(counter - failCounter)),
                TextSpan(
                  text: ' ${counter - failCounter} ',
                  style: TextStyle(color: Styles.colorYellow, fontSize: 32.0),
                ),
                TextSpan(text: AppLocalizations.of(context)!.scoreScreenSaved2(counter - failCounter)),
                TextSpan(text: ' ${AppLocalizations.of(context)!.scoreScreenSaved3(failCounter)}'),
                TextSpan(
                  text: ' $failCounter',
                  style: TextStyle(color: Styles.colorRed, fontSize: 32.0),
                ),
                TextSpan(text: '!'),
              ],
            ),
            style: Styles.fontStyle.copyWith(fontSize: 24.0),
          ),

          const SizedBox(height: 40.0),
          Flexible(
            child: SingleChildScrollView(
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      ScoreResultTitle(title: AppLocalizations.of(context)!.scoreTableTitle1),
                      ScoreResultTitle(title: AppLocalizations.of(context)!.scoreTableTitle2),
                      ScoreResultTitle(title: AppLocalizations.of(context)!.scoreTableTitle3),
                    ],
                  ),
                  ...maxScores.map((rowScore) {
                    return TableRow(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text('${rowScore.score}', style: Styles.fontStyle.copyWith(fontSize: 32.0)),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            rowScore.name,
                            style: Styles.fontStyle.copyWith(fontSize: 20.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text('${rowScore.counter}', style: Styles.fontStyle.copyWith(fontSize: 28.0)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          if (minScore != null)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${AppLocalizations.of(context)!.yourMinimumScore} '),
                    TextSpan(
                      text: '$minScore',
                      style: TextStyle(color: Styles.colorYellow, fontSize: 32.0),
                    ),
                  ],
                ),
                style: Styles.fontStyle.copyWith(fontSize: 24.0),
              ),
            ),
        ],
      ),
    );
  }
}
