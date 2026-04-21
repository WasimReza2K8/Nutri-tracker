import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/utils/calc/met_calc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ActivityDetailBottomSheet extends StatefulWidget {
  final Function(BuildContext) onAddButtonPressed;
  final TextEditingController quantityTextController;
  final TextEditingController weightTextController;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<ActivityIntensity> onIntensityChanged;

  const ActivityDetailBottomSheet(
      {super.key,
      required this.onAddButtonPressed,
      required this.quantityTextController,
      required this.weightTextController,
      required this.onUnitChanged,
      required this.onIntensityChanged});

  @override
  State<ActivityDetailBottomSheet> createState() =>
      _ActivityDetailBottomSheetState();
}

class _ActivityDetailBottomSheetState extends State<ActivityDetailBottomSheet> {
  String _selectedUnit = 'min';
  ActivityIntensity _selectedIntensity = ActivityIntensity.moderate;

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      elevation: 10,
      onClosing: () {},
      enableDrag: false,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.quantityTextController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.replaceAll(',', '.'),
                                ),
                              ),
                            ],
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: S.of(context).quantityLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                            child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: S.of(context).unitLabel),
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem(value: 'min', child: Text('min')),
                            DropdownMenuItem(value: 'hr', child: Text('hr')),
                          ],
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _selectedUnit = value);
                            widget.onUnitChanged(value);
                          },
                        ))
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: widget.weightTextController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.replaceAll(',', '.'),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            '${S.of(context).weightLabel} (${S.of(context).kgLabel})',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).intensityLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ActivityIntensity>(
                      showSelectedIcon: false,
                      selected: {_selectedIntensity},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) {
                          return;
                        }
                        setState(() => _selectedIntensity = selection.first);
                        widget.onIntensityChanged(selection.first);
                      },
                      segments: [
                        ButtonSegment(
                            value: ActivityIntensity.light,
                            label: Text(S.of(context).intensityLightLabel)),
                        ButtonSegment(
                            value: ActivityIntensity.moderate,
                            label: Text(S.of(context).intensityModerateLabel)),
                        ButtonSegment(
                            value: ActivityIntensity.vigorous,
                            label: Text(S.of(context).intensityVigorousLabel)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onAddButtonPressed(context);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ).copyWith(
                              elevation: ButtonStyleButton.allOrNull(0.0)),
                          icon: const Icon(Icons.add_outlined),
                          label: Text(S.of(context).addLabel)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
