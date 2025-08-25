import 'package:flutter/material.dart';
import 'package:save_coyote/screens/screens.dart';
import 'package:save_coyote/widgets/widgets.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key, this.lastRecordedName, required this.record, this.onSave});

  final Function? onSave;
  final String? lastRecordedName;
  final int record;

  @override
  Widget build(BuildContext context) {
    return SaveNameDialog(
      onSave: onSave,
      lastRecordedName: lastRecordedName,
      recordWidget: NewRecordVerbiage(record: record),
    );
  }
}
