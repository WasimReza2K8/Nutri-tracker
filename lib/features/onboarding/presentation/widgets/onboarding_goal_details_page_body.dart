import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingGoalDetailsPageBody extends StatefulWidget {
  final UserGoalSelectionEntity goal;
  final double currentWeightKG;
  final bool usesImperialUnits;
  final double? initialTargetWeightKG;
  final Function(bool active, double? targetWeight) setButtonContent;

  const OnboardingGoalDetailsPageBody({
    super.key,
    required this.goal,
    required this.currentWeightKG,
    required this.usesImperialUnits,
    this.initialTargetWeightKG,
    required this.setButtonContent,
  });

  @override
  State<OnboardingGoalDetailsPageBody> createState() =>
      _OnboardingGoalDetailsPageBodyState();
}

class _OnboardingGoalDetailsPageBodyState
    extends State<OnboardingGoalDetailsPageBody> {
  final _targetWeightFormKey = GlobalKey<FormState>();
  final _targetWeightController = TextEditingController();
  double? _parsedTargetWeight;

  bool get _isLoseWeight => widget.goal == UserGoalSelectionEntity.loseWeight;

  @override
  void initState() {
    super.initState();

    if (widget.initialTargetWeightKG != null) {
      _parsedTargetWeight = widget.initialTargetWeightKG;
      final displayWeight = widget.usesImperialUnits
          ? widget.initialTargetWeightKG! * 2.20462
          : widget.initialTargetWeightKG!;
      _targetWeightController.text = displayWeight.toStringAsFixed(0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkCorrectInput();
      }
    });
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isLoseWeight
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(S.of(context).onboardingStepGoalDetails,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: S.of(context).targetWeightLabel,
            subtitle: S.of(context).targetWeightSubtitle,
            child: Form(
              key: _targetWeightFormKey,
              child: TextFormField(
                controller: _targetWeightController,
                onChanged: (text) {
                  if (_targetWeightFormKey.currentState!.validate()) {
                    final parsed = double.tryParse(text.replaceAll(',', '.'));
                    if (parsed != null && widget.usesImperialUnits) {
                      _parsedTargetWeight = parsed * 0.453592; // lbs → kg
                    } else {
                      _parsedTargetWeight = parsed;
                    }
                    _checkCorrectInput();
                  } else {
                    _parsedTargetWeight = null;
                    _checkCorrectInput();
                  }
                },
                validator: _validateTargetWeight,
                decoration: InputDecoration(
                  labelText: widget.usesImperialUnits
                      ? S.of(context).lbsLabel
                      : S.of(context).kgLabel,
                  hintText: widget.usesImperialUnits
                      ? S.of(context).targetWeightExampleHintLbs
                      : S.of(context).targetWeightExampleHintKg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ),
        ],
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

  String? _validateTargetWeight(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).onboardingWrongTargetWeightLabel;
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return S.of(context).onboardingWrongTargetWeightLabel;
    }

    // Convert to kg for comparison
    final targetKg = widget.usesImperialUnits ? parsed * 0.453592 : parsed;

    if (_isLoseWeight && targetKg >= widget.currentWeightKG) {
      return S.of(context).onboardingTargetWeightValidationLose;
    }
    if (!_isLoseWeight && targetKg <= widget.currentWeightKG) {
      return S.of(context).onboardingTargetWeightValidationGain;
    }
    return null;
  }

  void _checkCorrectInput() {
    if (_parsedTargetWeight != null) {
      widget.setButtonContent(true, _parsedTargetWeight);
    } else {
      widget.setButtonContent(false, null);
    }
  }
}
