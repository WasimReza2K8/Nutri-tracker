import 'package:flutter/material.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingFourthPageBody extends StatefulWidget {
  final Function(bool active, UserGoalSelectionEntity? selectedGoal)
      setButtonContent;
  final UserGoalSelectionEntity? initialGoal;

  const OnboardingFourthPageBody(
      {super.key, required this.setButtonContent, this.initialGoal});

  @override
  State<OnboardingFourthPageBody> createState() =>
      _OnboardingFourthPageBodyState();
}

class _OnboardingFourthPageBodyState extends State<OnboardingFourthPageBody> {
  bool _looseWeightSelected = false;
  bool _maintainWeightSelected = false;
  bool _gainWeightSelected = false;

  @override
  void initState() {
    super.initState();
    switch (widget.initialGoal) {
      case UserGoalSelectionEntity.loseWeight:
        _setSelectedChoiceChip(looseWeight: true);
        break;
      case UserGoalSelectionEntity.maintainWeight:
        _setSelectedChoiceChip(maintainWeigh: true);
        break;
      case UserGoalSelectionEntity.gainWeigh:
        _setSelectedChoiceChip(gainWeight: true);
        break;
      case null:
        break;
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingStepGoal,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).goalLabel,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  S.of(context).onboardingGoalQuestionSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                _buildGoalOption(
                  context,
                  selected: _looseWeightSelected,
                  icon: Icons.trending_down_rounded,
                  label: S.of(context).goalLoseWeight,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(looseWeight: true);
                      _checkCorrectInput();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildGoalOption(
                  context,
                  selected: _maintainWeightSelected,
                  icon: Icons.balance_rounded,
                  label: S.of(context).goalMaintainWeight,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(maintainWeigh: true);
                      _checkCorrectInput();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildGoalOption(
                  context,
                  selected: _gainWeightSelected,
                  icon: Icons.trending_up_rounded,
                  label: S.of(context).goalGainWeight,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(gainWeight: true);
                      _checkCorrectInput();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(BuildContext context,
      {required bool selected,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  void _setSelectedChoiceChip(
      {looseWeight = false, maintainWeigh = false, gainWeight = false}) {
    _looseWeightSelected = looseWeight;
    _maintainWeightSelected = maintainWeigh;
    _gainWeightSelected = gainWeight;
  }

  void _checkCorrectInput() {
    UserGoalSelectionEntity? selectedGoal;
    if (_looseWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.loseWeight;
    } else if (_maintainWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.maintainWeight;
    } else if (_gainWeightSelected) {
      selectedGoal = UserGoalSelectionEntity.gainWeigh;
    }

    if (selectedGoal != null) {
      widget.setButtonContent(true, selectedGoal);
    } else {
      widget.setButtonContent(false, null);
    }
  }
}
