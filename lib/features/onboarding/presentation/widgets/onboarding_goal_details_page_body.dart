import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingGoalDetailsPageBody extends StatefulWidget {
  final UserGoalSelectionEntity goal;
  final double currentWeightKG;
  final bool usesImperialUnits;
  final double? initialTargetWeightKG;
  final double? initialWeightChangeRateKgPerWeek;
  final Function(bool active, double? targetWeight,
      double? weightChangeRateKgPerWeek) setButtonContent;

  const OnboardingGoalDetailsPageBody({
    super.key,
    required this.goal,
    required this.currentWeightKG,
    required this.usesImperialUnits,
    this.initialTargetWeightKG,
    this.initialWeightChangeRateKgPerWeek,
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
  int _selectedRateIndex = -1;

  // Rates in kg/week
  static const List<double> _ratesKgPerWeek = [0.25, 0.5, 1.0];

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

    if (widget.initialWeightChangeRateKgPerWeek != null) {
      final idx = _ratesKgPerWeek.indexWhere(
          (e) => (e - widget.initialWeightChangeRateKgPerWeek!).abs() < 0.0001);
      if (idx >= 0) {
        _selectedRateIndex = idx;
      }
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section icon + title
          Icon(
            _isLoseWeight
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(S.of(context).onboardingStepGoalDetails,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Target weight input
          Text(S.of(context).targetWeightLabel,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(S.of(context).targetWeightSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          Form(
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
                prefixIcon:
                    const Icon(Icons.monitor_weight_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),

          const SizedBox(height: 32),

          // Weight change rate selection
          Text(S.of(context).weightChangeRateLabel,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
              _isLoseWeight
                  ? S.of(context).weightLossRateSubtitle
                  : S.of(context).weightGainRateSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          _buildRateCards(context),
        ],
      ),
    );
  }

  Widget _buildRateCards(BuildContext context) {
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
    final icons = [
      Icons.directions_walk_rounded,
      Icons.directions_run_rounded,
      Icons.bolt_rounded,
    ];

    return Row(
      children: List.generate(3, (index) {
        final isSelected = _selectedRateIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedRateIndex = index;
                _checkCorrectInput();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 4, right: index == 2 ? 0 : 4),
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icons[index],
                      size: 28,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(labels[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          )),
                  const SizedBox(height: 4),
                  Text(descriptions[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }),
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
    final targetKg =
        widget.usesImperialUnits ? parsed * 0.453592 : parsed;

    if (_isLoseWeight && targetKg >= widget.currentWeightKG) {
      return S.of(context).onboardingTargetWeightValidationLose;
    }
    if (!_isLoseWeight && targetKg <= widget.currentWeightKG) {
      return S.of(context).onboardingTargetWeightValidationGain;
    }
    return null;
  }

  void _checkCorrectInput() {
    if (_parsedTargetWeight != null && _selectedRateIndex >= 0) {
      widget.setButtonContent(
          true, _parsedTargetWeight, _ratesKgPerWeek[_selectedRateIndex]);
    } else {
      widget.setButtonContent(false, null, null);
    }
  }
}

