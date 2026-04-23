import 'package:flutter/material.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:opennutritracker/generated/l10n.dart';

class SetTargetWeightDialog extends StatelessWidget {
  static const weightRangeKg = 80.0;
  static const weightRangeLbs = 176.0;

  final double currentWeight;
  final double? currentTargetWeight;
  final bool usesImperialUnits;

  const SetTargetWeightDialog({
    super.key,
    required this.currentWeight,
    this.currentTargetWeight,
    required this.usesImperialUnits,
  });

  @override
  Widget build(BuildContext context) {
    final initialValue = currentTargetWeight ?? currentWeight;
    double selectedWeight = initialValue;

    return AlertDialog(
      title: Text(S.of(context).selectTargetWeightDialogLabel),
      content: Wrap(children: [
        Column(
          children: [
            HorizontalPicker(
              height: 100,
              backgroundColor: Colors.transparent,
              minValue: usesImperialUnits
                  ? currentWeight - weightRangeLbs
                  : currentWeight - weightRangeKg,
              maxValue: usesImperialUnits
                  ? currentWeight + weightRangeLbs
                  : currentWeight + weightRangeKg,
              initialPosition: InitialPosition.center,
              divisions: 1000,
              suffix: usesImperialUnits
                  ? S.of(context).lbsLabel
                  : S.of(context).kgLabel,
              onChanged: (value) {
                selectedWeight = value;
              },
            ),
          ],
        ),
      ]),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedWeight),
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }
}

