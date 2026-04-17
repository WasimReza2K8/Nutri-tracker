import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MacroNutrientsView extends StatefulWidget {
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const MacroNutrientsView(
      {super.key,
      required this.totalCarbsIntake,
      required this.totalFatsIntake,
      required this.totalProteinsIntake,
      required this.totalCarbsGoal,
      required this.totalFatsGoal,
      required this.totalProteinsGoal});

  @override
  State<MacroNutrientsView> createState() => _MacroNutrientsViewState();
}

class _MacroNutrientsViewState extends State<MacroNutrientsView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildMacroItem(
            label: S.of(context).carbsLabel,
            intake: widget.totalCarbsIntake,
            goal: widget.totalCarbsGoal,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMacroItem(
            label: S.of(context).proteinLabel,
            intake: widget.totalProteinsIntake,
            goal: widget.totalProteinsGoal,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMacroItem(
            label: S.of(context).fatLabel,
            intake: widget.totalFatsIntake,
            goal: widget.totalFatsGoal,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required String label,
    required double intake,
    required double goal,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: getGoalPercentage(goal, intake),
              backgroundColor: colorScheme.primary.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${intake.toInt()}/${goal.toInt()} g',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  double getGoalPercentage(double goal, double supplied) {
    if (supplied <= 0 || goal <= 0) {
      return 0;
    } else if (supplied > goal) {
      return 1;
    } else {
      return supplied / goal;
    }
  }
}
