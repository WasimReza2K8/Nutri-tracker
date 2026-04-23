import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/utils/calc/tdee_calc.dart';

/// Daily calorie goal calculation aligned with industry standards (Yazio, MyFitnessPal, Cronometer)
///
/// Formula:
/// Daily Calorie Goal = TDEE + KcalAdjustment + UserAdjustment + ActivityKcal
///
/// With safety constraints:
/// - Minimum: BMR (basal metabolic rate, never go below for health and safety)
/// - Maximum: TDEE + 1000 kcal (when gaining weight)
///
/// Where:
/// - TDEE = Basal Metabolic Rate (Mifflin-St Jeor) × Activity Level (PAL)
/// - KcalAdjustment = ±(weekly_change_rate × 7700 kcal/kg) ÷ 7 days
/// - UserAdjustment = Manual offset set by user
/// - ActivityKcal = Burned calories from exercises/activities
class CalorieGoalCalc {
  /// 1 kg of body fat ≈ 7700 kcal (scientific standard)
  static const double _kcalPerKg = 7700;

  /// Legacy defaults when no rate is stored (backward-compat)
  static const double _defaultWeeklyRateKg = 0.5;

  /// Default planning horizon when no target date is provided.
  static const double _defaultGoalHorizonWeeks = 12;

  /// Maximum sustainable weekly rate (safety limit - healthy limit is 1 kg/week)
  static const double _maxWeeklyRateKg = 1.0;

  /// Practical minimum intake floors used by many mainstream apps.
  static const double _minCaloriesFemale = 1200.0;
  static const double _minCaloriesMale = 1500.0;

  static double getDailyKcalLeft(
          double totalKcalGoal, double totalKcalIntake) =>
      totalKcalGoal - totalKcalIntake;

  static double getTdee(UserEntity userEntity) =>
      TDEECalc.getTDEEKcalMifflinStJeor(userEntity);

  /// Returns the daily calorie goal with safety limits applied.
  ///
  /// Industry standard formula:
  /// Base = TDEE + KcalAdjustment + UserAdjustment + ActivityKcal
  ///
  /// Then applies:
  /// - Minimum: BMR (never go below)
  /// - For lose weight: Maximum deficit = BMR (at least 1200 kcal safeguard)
  static double getTotalKcalGoal(
      UserEntity userEntity, double totalKcalActivities,
      {double? kcalUserAdjustment}) {
    final tdee = getTdee(userEntity);
    final adjustment =
        getKcalGoalAdjustment(userEntity.goal, userEntity: userEntity);
    final userAdj = kcalUserAdjustment ?? 0;
    final activityAdj = totalKcalActivities;

    double totalGoal = tdee + adjustment + userAdj + activityAdj;

    // Apply safety limits
    final minSafeIntake = userEntity.gender == UserGenderEntity.male
        ? _minCaloriesMale
        : _minCaloriesFemale;

    // For weight loss: ensure a minimum calorie floor (prevent extreme deficits)
    if (userEntity.goal == UserWeightGoalEntity.loseWeight) {
      totalGoal = totalGoal.clamp(minSafeIntake, double.infinity);
    }
    // For weight gain: allow reasonable surplus
    else if (userEntity.goal == UserWeightGoalEntity.gainWeight) {
      const maxSafeIntake = 5000.0; // Sanity cap
      totalGoal = totalGoal.clamp(tdee, maxSafeIntake);
    }
    // For maintain: keep at TDEE
    else {
      totalGoal = tdee + userAdj + activityAdj;
    }

    return totalGoal;
  }

  /// Resolves weekly change rate with this precedence:
  /// 1) target weight + target date → date-derived implied rate (most specific)
  /// 2) target weight without date → explicit rate (if present) or default horizon
  /// 3) explicit user-selected rate
  /// 4) default rate
  static double _getEffectiveWeeklyRate(UserEntity userEntity) {
    if (userEntity.targetWeightKG != null) {
      final weightDiff =
          (userEntity.targetWeightKG! - userEntity.weightKG).abs();

      // If both target weight and target date are set, calculate implied rate by date.
      if (userEntity.targetDateForWeightGoal != null) {
        final daysUntilTarget = userEntity.targetDateForWeightGoal!
            .difference(DateTime.now())
            .inDays;

        // Only use date-derived rate if target date is in the future
        if (daysUntilTarget > 0) {
          final weeksUntilTarget = daysUntilTarget / 7.0;
          final impliedRate = weightDiff / weeksUntilTarget;
          return impliedRate.clamp(0.0, _maxWeeklyRateKg);
        }
        // If target date is in past, ignore it and fall through
      }

      // Without a valid target date, use explicit rate if available
      if (userEntity.weightChangeRateKgPerWeek != null) {
        return userEntity.weightChangeRateKgPerWeek!
            .clamp(0.0, _maxWeeklyRateKg);
      }

      // Otherwise infer from target delta over default horizon
      final impliedRate = weightDiff / _defaultGoalHorizonWeeks;
      return impliedRate.clamp(0.0, _maxWeeklyRateKg);
    }

    // No target weight: fall back to explicit rate or default
    if (userEntity.weightChangeRateKgPerWeek != null) {
      return userEntity.weightChangeRateKgPerWeek!.clamp(0.0, _maxWeeklyRateKg);
    }

    return _defaultWeeklyRateKg;
  }

  /// Returns the daily kcal adjustment based on goal and calculated weekly rate.
  ///
  /// For lose weight: negative adjustment (calorie deficit)
  /// For gain weight: positive adjustment (calorie surplus)
  /// For maintain:    0
  ///
  /// Formula: (rate_kg_per_week × 7700 kcal/kg) ÷ 7 days
  static double getKcalGoalAdjustment(UserWeightGoalEntity goal,
      {UserEntity? userEntity, double? weightChangeRateKgPerWeek}) {
    // Prefer calculating from userEntity if available (more context-aware)
    final rate = userEntity != null
        ? _getEffectiveWeeklyRate(userEntity)
        : (weightChangeRateKgPerWeek ?? _defaultWeeklyRateKg)
            .clamp(0.0, _maxWeeklyRateKg);

    // daily adjustment = (rate_kg_per_week * 7700 kcal/kg) / 7 days
    final dailyAdjustment = (rate * _kcalPerKg) / 7;

    if (goal == UserWeightGoalEntity.loseWeight) {
      return -dailyAdjustment;
    } else if (goal == UserWeightGoalEntity.gainWeight) {
      return dailyAdjustment;
    } else {
      return 0;
    }
  }
}
