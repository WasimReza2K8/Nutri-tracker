import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingSecondPageBody extends StatefulWidget {
  final Function(bool active, double? selectedHeight, double? selectedWeight,
      bool usesImperialUnits) setButtonContent;
  final double? initialHeightCm;
  final double? initialWeightKg;
  final bool initialUsesImperialUnits;

  const OnboardingSecondPageBody(
      {super.key,
      required this.setButtonContent,
      this.initialHeightCm,
      this.initialWeightKg,
      this.initialUsesImperialUnits = false});

  @override
  State<OnboardingSecondPageBody> createState() =>
      _OnboardingSecondPageBodyState();
}

class _OnboardingSecondPageBodyState extends State<OnboardingSecondPageBody> {
  final _heightFormKey = GlobalKey<FormState>();
  final _weightFormKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _isUnitSelected = [true, false];
  double? _parsedHeight;
  double? _parsedWeight;

  bool get _isImperialSelected => _isUnitSelected[1];

  @override
  void initState() {
    super.initState();

    _isUnitSelected[0] = !widget.initialUsesImperialUnits;
    _isUnitSelected[1] = widget.initialUsesImperialUnits;

    if (widget.initialHeightCm != null) {
      _parsedHeight = widget.initialUsesImperialUnits
          ? UnitCalc.cmToFeet(widget.initialHeightCm!)
          : widget.initialHeightCm;
      _heightController.text = _parsedHeight!.toStringAsFixed(
          widget.initialUsesImperialUnits ? 1 : 0);
    }

    if (widget.initialWeightKg != null) {
      _parsedWeight = widget.initialUsesImperialUnits
          ? UnitCalc.kgToLbs(widget.initialWeightKg!)
          : widget.initialWeightKg;
      _weightController.text = _parsedWeight!.toStringAsFixed(0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkCorrectInput();
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).heightLabel,
              style: Theme.of(context).textTheme.headlineSmall),
          Text(S.of(context).onboardingHeightQuestionSubtitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16.0),
          Form(
            key: _heightFormKey,
            child: TextFormField(
                controller: _heightController,
                onChanged: (text) {
                  if (_heightFormKey.currentState!.validate()) {
                    _parsedHeight = double.tryParse(text.replaceAll(',', '.'));
                    checkCorrectInput();
                  } else {
                    _parsedHeight = null;
                    checkCorrectInput();
                  }
                },
                validator: validateHeight,
                decoration: InputDecoration(
                  labelText: _isImperialSelected ? 'ft' : 'cm',
                  hintText: _isImperialSelected
                      ? S.of(context).onboardingHeightExampleHintFt
                      : S.of(context).onboardingHeightExampleHintCm,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  !_isImperialSelected
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+([.,]\d{0,1})?$'))
                ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isSelected: _isUnitSelected,
              onPressed: (int index) {
                setState(() {
                  // Toggle height unit
                  for (int i = 0; i < _isUnitSelected.length; i++) {
                    _isUnitSelected[i] = i == index;
                  }
                  _heightFormKey.currentState!.validate();
                  checkCorrectInput();
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).cmLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).ftLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
          Text(S.of(context).weightLabel,
              style: Theme.of(context).textTheme.headlineSmall),
          Text(S.of(context).onboardingWeightQuestionSubtitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16.0),
          Form(
            key: _weightFormKey,
            child: TextFormField(
                controller: _weightController,
                onChanged: (text) {
                  if (_weightFormKey.currentState!.validate()) {
                    _parsedWeight = double.tryParse(text.replaceAll(',', '.'));
                    checkCorrectInput();
                  } else {
                    _parsedWeight = null;
                    checkCorrectInput();
                  }
                },
                validator: validateWeight,
                decoration: InputDecoration(
                  labelText: _isImperialSelected
                      ? S.of(context).lbsLabel
                      : S.of(context).kgLabel,
                  hintText: _isImperialSelected
                      ? S.of(context).onboardingWeightExampleHintLbs
                      : S.of(context).onboardingWeightExampleHintKg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isSelected: _isUnitSelected,
              onPressed: (int index) {
                setState(() {
                  // Toggle height unit
                  for (int i = 0; i < _isUnitSelected.length; i++) {
                    _isUnitSelected[i] = i == index;
                  }
                  _weightFormKey.currentState!.validate();
                  checkCorrectInput();
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).kgLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).lbsLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? validateHeight(String? value) {
    if (value == null) return S.of(context).onboardingWrongHeightLabel;

    if (_isImperialSelected) {
      // Regex for feet and inches
      if (value.isEmpty || !RegExp(r'^[0-9]+([.,][0-9])?$').hasMatch(value)) {
        return S.of(context).onboardingWrongHeightLabel;
      } else {
        return null;
      }
    } else {
      // Regex for cm
      if (value.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) {
        return S.of(context).onboardingWrongHeightLabel;
      } else {
        return null;
      }
    }
  }

  String? validateWeight(String? value) {
    if (value == null) return S.of(context).onboardingWrongWeightLabel;
    if (value.isEmpty || !RegExp(r'^[0-9]').hasMatch(value)) {
      return S.of(context).onboardingWrongHeightLabel;
    } else {
      return null;
    }
  }

  /// Check if the input is correct and update the button content
  void checkCorrectInput() {
    final isHeightValid = _heightFormKey.currentState?.validate() ?? false;
    final isWeightValid = _weightFormKey.currentState?.validate() ?? false;

    if (isHeightValid && isWeightValid) {
      if (_parsedHeight != null && _parsedWeight != null) {
        final heightCm = _isImperialSelected
            ? UnitCalc.feetToCm(_parsedHeight!)
            : _parsedHeight!;
        final weightKg = _isImperialSelected
            ? UnitCalc.lbsToKg(_parsedWeight!)
            : _parsedWeight!;

        widget.setButtonContent(true, heightCm, weightKg, _isImperialSelected);
      } else {
        widget.setButtonContent(false, null, null, _isImperialSelected);
      }
    } else {
      widget.setButtonContent(false, null, null, _isImperialSelected);
    }
  }
}
