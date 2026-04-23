import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
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

    test('Changing target weight changes total kcal goal', () {
      final baseUser = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        weightChangeRateKgPerWeek: 0.25,
      );

      final moreAggressiveUser = UserEntity(
        birthday: baseUser.birthday,
        heightCM: baseUser.heightCM,
        weightKG: baseUser.weightKG,
        gender: baseUser.gender,
        goal: baseUser.goal,
        pal: baseUser.pal,
        weightChangeRateKgPerWeek: 0.75,
      );

      final mildGoal = CalorieGoalCalc.getTotalKcalGoal(baseUser, 0);
      final aggressiveGoal =
          CalorieGoalCalc.getTotalKcalGoal(moreAggressiveUser, 0);

      // More aggressive rate (0.75 vs 0.25) should create larger deficit
      expect(aggressiveGoal, lessThan(mildGoal));
    });

    test('Safety limit: calorie goal never goes below practical floor', () {
      final user = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        weightChangeRateKgPerWeek: 0.5,
      );

      final totalGoal = CalorieGoalCalc.getTotalKcalGoal(user, 0);

      // Male floor is 1500 kcal/day
      expect(totalGoal, greaterThanOrEqualTo(1500));
    });

    test('Deficit calculation with safe floor applied', () {
      final user = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        weightChangeRateKgPerWeek: 0.5,
      );

      final tdee = CalorieGoalCalc.getTdee(user);
      final totalGoal = CalorieGoalCalc.getTotalKcalGoal(user, 0);
      // Goal should be between practical floor and TDEE for lose weight
      expect(totalGoal, greaterThanOrEqualTo(1500));
      expect(totalGoal, lessThanOrEqualTo(tdee));
    });

    test('Changing explicit weekly rate changes total kcal goal', () {
      final base = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        weightChangeRateKgPerWeek: 0.25,
      );

      final faster = UserEntity(
        birthday: base.birthday,
        heightCM: base.heightCM,
        weightKG: base.weightKG,
        gender: base.gender,
        goal: base.goal,
        pal: base.pal,
        weightChangeRateKgPerWeek: 1.0,
      );

      final baseGoal = CalorieGoalCalc.getTotalKcalGoal(base, 0);
      final fasterGoal = CalorieGoalCalc.getTotalKcalGoal(faster, 0);

      expect(fasterGoal, lessThan(baseGoal));
    });

    test('Explicit weekly rate applies with safety floor', () {
      final withTargetAndRate = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        targetWeightKG: 70,
        weightChangeRateKgPerWeek: 0.25,
      );

      final tdee = CalorieGoalCalc.getTdee(withTargetAndRate);
      final totalGoal = CalorieGoalCalc.getTotalKcalGoal(withTargetAndRate, 0);

      // Goal should be between practical floor and TDEE (safety applied)
      expect(totalGoal, greaterThanOrEqualTo(1500));
      expect(totalGoal, lessThanOrEqualTo(tdee));
    });

    test('Target date overrides explicit weekly rate when both are set', () {
      // 10 kg to lose over ~20 weeks ≈ 0.5 kg/week implied
      final withDate = UserEntity(
        birthday: DateTime(DateTime.now().year - 30, DateTime.now().month,
            DateTime.now().day - 1),
        heightCM: 175,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
        targetWeightKG: 70,
        weightChangeRateKgPerWeek: 0.25,
        targetDateForWeightGoal: DateTime.now().add(const Duration(days: 140)),
      );

      // Without date, same user uses explicit 0.25 rate
      final withoutDate = UserEntity(
        birthday: withDate.birthday,
        heightCM: withDate.heightCM,
        weightKG: withDate.weightKG,
        gender: withDate.gender,
        goal: withDate.goal,
        pal: withDate.pal,
        targetWeightKG: withDate.targetWeightKG,
        weightChangeRateKgPerWeek: 0.25,
      );

      final goalWithDate = CalorieGoalCalc.getTotalKcalGoal(withDate, 0);
      final goalWithoutDate = CalorieGoalCalc.getTotalKcalGoal(withoutDate, 0);

      // Date-derived rate (~0.5 kg/week) creates a larger deficit than explicit 0.25
      expect(goalWithDate, lessThan(goalWithoutDate));
    });
  });
}
