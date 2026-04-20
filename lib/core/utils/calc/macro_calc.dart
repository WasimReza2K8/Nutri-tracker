class MacroCalc {
  /// Atwater energy density factors (kcal per gram)
  static const _carbsKcalPerGram = 4.0;
  static const _fatKcalPerGram = 9.0;
  static const _proteinKcalPerGram = 4.0;

  /// Modern default macro split — aligned with USDA Dietary Guidelines
  /// 2020-2025 and popular apps (Yazio, MyFitnessPal).
  ///
  /// Carbs  : 50 %
  /// Fat    : 30 %
  /// Protein: 20 %
  static const _defaultCarbsPercentageGoal = 0.50;
  static const _defaultFatsPercentageGoal = 0.30;
  static const _defaultProteinsPercentageGoal = 0.20;

  /// Calculate the total carbs goal based on the total calorie goal
  /// Uses the default percentage if the user has not set a goal
  static double getTotalCarbsGoal(
          double totalCalorieGoal, {double? userCarbsGoal}) =>
      (totalCalorieGoal * (userCarbsGoal ?? _defaultCarbsPercentageGoal)) /
      _carbsKcalPerGram;

  /// Calculate the total fats goal based on the total calorie goal
  /// Uses the default percentage if the user has not set a goal
  static double getTotalFatsGoal(
          double totalCalorieGoal, {double? userFatsGoal}) =>
      (totalCalorieGoal * (userFatsGoal ?? _defaultFatsPercentageGoal)) /
      _fatKcalPerGram;

  /// Calculate the total proteins goal based on the total calorie goal
  /// Uses the default percentage if the user has not set a goal
  static double getTotalProteinsGoal(
          double totalCalorieGoal, {double? userProteinsGoal}) =>
      (totalCalorieGoal *
          (userProteinsGoal ?? _defaultProteinsPercentageGoal)) /
      _proteinKcalPerGram;
}
