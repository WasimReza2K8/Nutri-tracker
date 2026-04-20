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
      _heightController.text = _parsedHeight!
          .toStringAsFixed(widget.initialUsesImperialUnits ? 1 : 0);
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingStepBodyMetrics,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _buildUnitToggle(context),
          const SizedBox(height: 12),
          _buildSectionCard(
            context,
            title: S.of(context).heightLabel,
            subtitle: S.of(context).onboardingHeightQuestionSubtitle,
            child: Form(
              key: _heightFormKey,
              child: TextFormField(
                  controller: _heightController,
                  onChanged: (text) {
                    if (_heightFormKey.currentState!.validate()) {
                      _parsedHeight = double.tryParse(text.replaceAll(',', '.'));
                    } else {
                      _parsedHeight = null;
                    }
                    checkCorrectInput();
                  },
                  validator: validateHeight,
                  decoration: InputDecoration(
                    labelText: _isImperialSelected ? 'ft' : 'cm',
                    hintText: _isImperialSelected
                        ? S.of(context).onboardingHeightExampleHintFt
                        : S.of(context).onboardingHeightExampleHintCm,
                    prefixIcon: const Icon(Icons.height_rounded),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    !_isImperialSelected
                        ? FilteringTextInputFormatter.digitsOnly
                        : FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+([.,]\d{0,1})?$'))
                  ]),
            ),
          ),
          const SizedBox(height: 14),
          _buildSectionCard(
            context,
            title: S.of(context).weightLabel,
            subtitle: S.of(context).onboardingWeightQuestionSubtitle,
            child: Form(
              key: _weightFormKey,
              child: TextFormField(
                  controller: _weightController,
                  onChanged: (text) {
                    if (_weightFormKey.currentState!.validate()) {
                      _parsedWeight =
                          double.tryParse(text.replaceAll(',', '.'));
                    } else {
                      _parsedWeight = null;
                    }
                    checkCorrectInput();
                  },
                  validator: validateWeight,
                  decoration: InputDecoration(
                    labelText: _isImperialSelected
                        ? S.of(context).lbsLabel
                        : S.of(context).kgLabel,
                    hintText: _isImperialSelected
                        ? S.of(context).onboardingWeightExampleHintLbs
                        : S.of(context).onboardingWeightExampleHintKg,
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,1})?$'))
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildUnitButton(
              context,
              selected: !_isImperialSelected,
              label: '${S.of(context).kgLabel}/${S.of(context).cmLabel}',
              onTap: () => _onUnitChanged(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildUnitButton(
              context,
              selected: _isImperialSelected,
              label: '${S.of(context).lbsLabel}/${S.of(context).ftLabel}',
              onTap: () => _onUnitChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(BuildContext context,
      {required bool selected,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  void _onUnitChanged(bool useImperial) {
    if (_isImperialSelected == useImperial) return;

    setState(() {
      _isUnitSelected[0] = !useImperial;
      _isUnitSelected[1] = useImperial;

      // Convert already entered values for better UX
      if (_parsedHeight != null) {
        _parsedHeight = useImperial
            ? UnitCalc.cmToFeet(_parsedHeight!)
            : UnitCalc.feetToCm(_parsedHeight!);
        _heightController.text =
            _parsedHeight!.toStringAsFixed(useImperial ? 1 : 0);
      }

      if (_parsedWeight != null) {
        _parsedWeight = useImperial
            ? UnitCalc.kgToLbs(_parsedWeight!)
            : UnitCalc.lbsToKg(_parsedWeight!);
        _weightController.text = _parsedWeight!.toStringAsFixed(0);
      }

      _heightFormKey.currentState?.validate();
      _weightFormKey.currentState?.validate();
      checkCorrectInput();
    });
  }

  String? validateHeight(String? value) {
    if (value == null) return S.of(context).onboardingWrongHeightLabel;

    if (_isImperialSelected) {
      if (value.isEmpty || !RegExp(r'^[0-9]+([.,][0-9])?$').hasMatch(value)) {
        return S.of(context).onboardingWrongHeightLabel;
      }
    } else {
      if (value.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) {
        return S.of(context).onboardingWrongHeightLabel;
      }
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).onboardingWrongWeightLabel;
    }
    if (!RegExp(r'^[0-9]+([.,][0-9])?$').hasMatch(value)) {
      return S.of(context).onboardingWrongWeightLabel;
    }
    return null;
  }

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
