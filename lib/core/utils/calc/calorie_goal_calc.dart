import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/utils/calc/tdee_calc.dart';

class CalorieGoalCalc {
  /// 1 kg of body fat ≈ 7700 kcal
  static const double _kcalPerKg = 7700;

  /// Legacy defaults when no rate is stored (backward-compat)
  static const double _defaultWeeklyRateKg = 0.5;

  static double getDailyKcalLeft(
          double totalKcalGoal, double totalKcalIntake) =>
      totalKcalGoal - totalKcalIntake;

  static double getTdee(UserEntity userEntity) =>
      TDEECalc.getTDEEKcalMifflinStJeor(userEntity);

  static double getTotalKcalGoal(
          UserEntity userEntity, double totalKcalActivities,
          {double? kcalUserAdjustment}) =>
      getTdee(userEntity) +
      getKcalGoalAdjustment(userEntity.goal,
          weightChangeRateKgPerWeek: userEntity.weightChangeRateKgPerWeek) +
      (kcalUserAdjustment ?? 0) +
      totalKcalActivities;

  /// Returns the daily kcal adjustment based on goal and weekly rate.
  ///
  /// For lose weight: negative adjustment (calorie deficit)
  /// For gain weight: positive adjustment (calorie surplus)
  /// For maintain:    0
  static double getKcalGoalAdjustment(UserWeightGoalEntity goal,
      {double? weightChangeRateKgPerWeek}) {
    final rate = weightChangeRateKgPerWeek ?? _defaultWeeklyRateKg;
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
