import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DayInfoWidget extends StatelessWidget {
  final DateTime selectedDay;
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivities;
  final List<IntakeEntity> breakfastIntake;
  final List<IntakeEntity> lunchIntake;
  final List<IntakeEntity> dinnerIntake;
  final List<IntakeEntity> snackIntake;

  final bool usesImperialUnits;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
      onDeleteIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onDeleteActivity;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
      AddMealType? type) onCopyIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onCopyActivity;

  const DayInfoWidget({
    super.key,
    required this.selectedDay,
    required this.trackedDayEntity,
    required this.userActivities,
    required this.breakfastIntake,
    required this.lunchIntake,
    required this.dinnerIntake,
    required this.snackIntake,
    required this.usesImperialUnits,
    required this.onDeleteIntake,
    required this.onDeleteActivity,
    required this.onCopyIntake,
    required this.onCopyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final allIntakes = [
      ...breakfastIntake,
      ...lunchIntake,
      ...dinnerIntake,
      ...snackIntake
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            S.of(context).calorieTrackerLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              _buildTrackerItem(
                context,
                title: S.of(context).breakfastLabel,
                icon: Icons.bakery_dining_outlined,
                calories: breakfastIntake.fold(
                    0.0, (sum, item) => sum + item.totalKcal),
                names: _joinMealNames(breakfastIntake),
                onAddTap: () =>
                    _openAddMeal(context, AddMealType.breakfastType),
              ),
              _buildDivider(context),
              _buildTrackerItem(
                context,
                title: S.of(context).lunchLabel,
                icon: Icons.lunch_dining_outlined,
                calories:
                    lunchIntake.fold(0.0, (sum, item) => sum + item.totalKcal),
                names: _joinMealNames(lunchIntake),
                onAddTap: () => _openAddMeal(context, AddMealType.lunchType),
              ),
              _buildDivider(context),
              _buildTrackerItem(
                context,
                title: S.of(context).dinnerLabel,
                icon: Icons.dinner_dining_outlined,
                calories:
                    dinnerIntake.fold(0.0, (sum, item) => sum + item.totalKcal),
                names: _joinMealNames(dinnerIntake),
                onAddTap: () => _openAddMeal(context, AddMealType.dinnerType),
              ),
              _buildDivider(context),
              _buildTrackerItem(
                context,
                title: S.of(context).snackLabel,
                icon: CustomIcons.food_apple_outline,
                calories:
                    snackIntake.fold(0.0, (sum, item) => sum + item.totalKcal),
                names: _joinMealNames(snackIntake),
                onAddTap: () => _openAddMeal(context, AddMealType.snackType),
              ),
              _buildDivider(context),
              _buildTrackerItem(
                context,
                title: S.of(context).activityLabel,
                icon: UserActivityEntity.getIconData(),
                calories: userActivities.fold(
                    0.0, (sum, item) => sum + item.burnedKcal),
                names: _joinActivityNames(context, userActivities),
                onAddTap: () => _openAddActivity(context),
                isBurned: true,
              ),
            ],
          ),
        ),
        if (allIntakes.isEmpty && userActivities.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              S.of(context).nothingAddedLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
    );
  }

  Widget _buildTrackerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required double calories,
    required String names,
    required VoidCallback onAddTap,
    bool isBurned = false,
  }) {
    final hasValues = calories > 0;
    final iconColor = hasValues
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 6),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${calories.toInt()} ${S.of(context).kcalLabel}${isBurned ? ' ${S.of(context).burnedLabel}' : ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (names.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    names,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onAddTap,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _joinMealNames(List<IntakeEntity> intakes) {
    final names = intakes
        .map((e) => e.meal.name)
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) {
      return '';
    }
    return names.join(', ');
  }

  String _joinActivityNames(
      BuildContext context, List<UserActivityEntity> activities) {
    final names = activities
        .map((e) => e.physicalActivityEntity.getName(context))
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) {
      return '';
    }
    return names.join(', ');
  }

  void _openAddMeal(BuildContext context, AddMealType type) {
    Navigator.pushNamed(
      context,
      NavigationOptions.addMealRoute,
      arguments: AddMealScreenArguments(type, selectedDay),
    );
  }

  void _openAddActivity(BuildContext context) {
    Navigator.of(context).pushNamed(
      NavigationOptions.addActivityRoute,
      arguments: AddActivityScreenArguments(day: selectedDay),
    );
  }
}
