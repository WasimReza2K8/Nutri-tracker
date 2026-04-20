import 'package:flutter/material.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingOverviewPageBody extends StatelessWidget {
  final String calorieGoalDayString;
  final String carbsGoalString;
  final String fatGoalString;
  final String proteinGoalString;
  final Function(bool active) setButtonActive;
  final double? totalKcalCalculated;

  const OnboardingOverviewPageBody(
      {super.key,
      required this.setButtonActive,
      this.totalKcalCalculated,
      required this.calorieGoalDayString,
      required this.carbsGoalString,
      required this.fatGoalString,
      required this.proteinGoalString});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setButtonActive(true);
    });

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).onboardingStepOverview,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            _buildCalorieCard(context),
            const SizedBox(height: 14),
            _buildMacroCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingYourGoalLabel,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calorieGoalDayString,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  S.of(context).onboardingKcalPerDayLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingYourMacrosGoalLabel,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _buildMacroTile(
            context,
            label: S.of(context).carbsLabel,
            grams: carbsGoalString,
            color: Colors.orange,
            icon: Icons.grain_rounded,
          ),
          const SizedBox(height: 10),
          _buildMacroTile(
            context,
            label: S.of(context).fatLabel,
            grams: fatGoalString,
            color: Colors.blue,
            icon: Icons.opacity_rounded,
          ),
          const SizedBox(height: 10),
          _buildMacroTile(
            context,
            label: S.of(context).proteinLabel,
            grams: proteinGoalString,
            color: Colors.green,
            icon: Icons.fitness_center_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTile(BuildContext context,
      {required String label,
      required String grams,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Text(
            '$grams g',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          )
        ],
      ),
    );
  }
}
