import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_coyote/l10n/app_localizations.dart';
import 'package:save_coyote/styles/styles.dart';

class SaveNameDialog extends StatefulWidget {
  const SaveNameDialog({super.key, this.lastRecordedName, this.onSave, this.recordWidget});

  final Function? onSave;
  final String? lastRecordedName;
  final Widget? recordWidget;

  @override
  State<SaveNameDialog> createState() => _SaveNameDialogState();
}

class _SaveNameDialogState extends State<SaveNameDialog> {
  late TextEditingController _nameController;
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lastRecordedName);
    canSave = widget.lastRecordedName?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.recordWidget != null)
            widget.recordWidget!,
          Text(AppLocalizations.of(context)!.enterYourName, style: Styles.fontStyle.copyWith(fontSize: 24.0)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: TextField(
              controller: _nameController,
              onChanged: (value) {
                setState(() {
                  canSave = value.isNotEmpty;
                });
              },
              maxLength: 20,
              autofocus: true,
              style: Styles.fontStyle.copyWith(fontSize: 28),
              cursorColor: Colors.white,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: InputDecoration(
                counter: const SizedBox(),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Styles.colorBrown, width: 2.0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Styles.colorBrown, width: 2.0)),
              ),
            ),
          ),
          Visibility(
            visible: canSave,
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => widget.onSave?.call(_nameController.text),
                style: TextButton.styleFrom(
                  backgroundColor: Styles.colorBrown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Adjust radius as needed
                    //side: BorderSide(color: Styles.colorYellow, width: 2.0)
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.save, style: Styles.fontStyle.copyWith(fontSize: 28, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}