import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

class SetWeightChangeRateDialog extends StatefulWidget {
  final bool usesImperialUnits;
  final bool isLoseWeight;
  final double? currentRateKgPerWeek;

  const SetWeightChangeRateDialog({
    super.key,
    required this.usesImperialUnits,
    required this.isLoseWeight,
    this.currentRateKgPerWeek,
  });

  @override
  State<SetWeightChangeRateDialog> createState() =>
      _SetWeightChangeRateDialogState();
}

class _SetWeightChangeRateDialogState extends State<SetWeightChangeRateDialog> {
  static const List<double> _ratesKgPerWeek = [0.25, 0.5, 1.0];
  late int _selectedRateIndex;

  @override
  void initState() {
    super.initState();
    final current = widget.currentRateKgPerWeek ?? 0.5;
    final index =
        _ratesKgPerWeek.indexWhere((r) => (r - current).abs() < 0.001);
    _selectedRateIndex = index >= 0 ? index : 1;
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      S.of(context).weightChangeRateSlow,
      S.of(context).weightChangeRateNormal,
      S.of(context).weightChangeRateFast,
    ];
    final descriptions = widget.usesImperialUnits
        ? [
            S.of(context).weightChangeRateSlowDescLbs,
            S.of(context).weightChangeRateNormalDescLbs,
            S.of(context).weightChangeRateFastDescLbs,
          ]
        : [
            S.of(context).weightChangeRateSlowDesc,
            S.of(context).weightChangeRateNormalDesc,
            S.of(context).weightChangeRateFastDesc,
          ];

    return AlertDialog(
      title: Text(S.of(context).weightChangeRateLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.isLoseWeight
              ? S.of(context).weightLossRateSubtitle
              : S.of(context).weightGainRateSubtitle),
          const SizedBox(height: 12),
          ...List.generate(_ratesKgPerWeek.length, (index) {
            final selected = _selectedRateIndex == index;
            return RadioListTile<int>(
              value: index,
              groupValue: _selectedRateIndex,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedRateIndex = value);
              },
              title: Text(labels[index]),
              subtitle: Text(descriptions[index]),
              dense: true,
              contentPadding: EdgeInsets.zero,
              selected: selected,
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_ratesKgPerWeek[_selectedRateIndex]),
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }
}
