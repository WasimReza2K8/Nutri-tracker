import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/utils/calc/calorie_goal_calc.dart';

import '../fixture/user_entity_fixtures.dart';

void main() {
  group('Calorie Goal Calc Test', () {
    late UserEntity youngSedentaryMaleWantingToMaintainWeight;
    late UserEntity middleAgedActiveFemaleWantingToLoseWeight;

    setUp(() {
      youngSedentaryMaleWantingToMaintainWeight =
          UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      middleAgedActiveFemaleWantingToLoseWeight =
          UserEntityFixtures.middleAgedActiveFemaleWantingToLoseWeight;
    });

    test(
        'Total Kcal Goal calculation for a young sedentary male wanting to maintain weight',
        () {
      final user = youngSedentaryMaleWantingToMaintainWeight;

      double resultCalorieGoal = CalorieGoalCalc.getTotalKcalGoal(user, 200.0);

      // Mifflin-St. Jeor BMR: 10*80 + 6.25*180 - 5*25 + 5 = 800+1125-125+5 = 1805
      // TDEE (sedentary ×1.2): 1805 * 1.2 = 2166
      // Activities: 200, Adjustment: 0 (maintain)
      // 2166 + 200 + 0 = 2366
      int expectedKcal = 2366;

      expect(resultCalorieGoal.toInt(), expectedKcal);
    });

    test(
        'Total Kcal Goal calculation for a middle aged active female wanting to lose weight',
        () {
      final user = middleAgedActiveFemaleWantingToLoseWeight;

      double resultCalorieGoal = CalorieGoalCalc.getTotalKcalGoal(user, 550.0);

      // Mifflin-St. Jeor BMR: 10*75 + 6.25*160 - 5*54 - 161 = 750+1000-270-161 = 1319
      // TDEE (active ×1.55): 1319 * 1.55 = 2044.45
      // Activities: 550, Adjustment: -550 (default 0.5 kg/week lose)
      // 2044 + 550 - 550 = 2044
      int expectedKcal = 2044;

      expect(resultCalorieGoal.toInt(), expectedKcal);
    });
  });
}
