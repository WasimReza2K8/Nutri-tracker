import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';

class TDEECalc {
  /// Activity multipliers used by most popular calorie tracking apps
  /// (Yazio, MyFitnessPal, Lose It!, etc.)
  ///
  /// Based on Mifflin-St. Jeor BMR × activity factor.
  static const Map<UserPALEntity, double> _activityMultipliers = {
    UserPALEntity.sedentary: 1.2,   // Little or no exercise
    UserPALEntity.lowActive: 1.375, // Light exercise 1-3 days/week
    UserPALEntity.active: 1.55,     // Moderate exercise 3-5 days/week
    UserPALEntity.veryActive: 1.725, // Hard exercise 6-7 days/week
  };

  /// Calculates TDEE using the Mifflin-St. Jeor equation (1990) with
  /// standard activity multipliers.
  ///
  /// This is the most widely used and validated approach in modern
  /// calorie tracking applications.
  ///
  /// Mifflin MD, St Jeor ST, et al. "A new predictive equation for resting
  /// energy expenditure in healthy individuals."
  /// Am J Clin Nutr. 1990;51(2):241-247.
  /// https://pubmed.ncbi.nlm.nih.gov/2305711/
  static double getTDEEKcalMifflinStJeor(UserEntity userEntity) {
    final bmr = _getBMRMifflinStJeor(userEntity);
    final multiplier = _activityMultipliers[userEntity.pal] ?? 1.2;
    return bmr * multiplier;
  }

  /// Mifflin-St. Jeor BMR calculation.
  ///
  /// Male:   10 × weight(kg) + 6.25 × height(cm) − 5 × age(y) + 5
  /// Female: 10 × weight(kg) + 6.25 × height(cm) − 5 × age(y) − 161
  static double _getBMRMifflinStJeor(UserEntity userEntity) {
    final base = 10 * userEntity.weightKG +
        6.25 * userEntity.heightCM -
        5 * userEntity.age;

    if (userEntity.gender == UserGenderEntity.male) {
      return base + 5;
    } else {
      return base - 161;
    }
  }

  /// Public wrapper for BMR calculation (used by calorie safety limits)
  static double getBmrMifflinStJeor(UserEntity userEntity) =>
      _getBMRMifflinStJeor(userEntity);

  // ── Legacy methods kept for reference / potential settings toggle ──

  /// IOM 2005 EER equation (previous default — tends to over-estimate).
  static double getTDEEKcalIOM2005(UserEntity userEntity) {
    double tdeeKcal;
    if (userEntity.gender == UserGenderEntity.male) {
      tdeeKcal = 864 -
          9.72 * userEntity.age +
          _getPAValueIOM2005(userEntity) *
              14.2 *
              userEntity.weightKG +
          503 * (userEntity.heightCM / 100);
    } else {
      tdeeKcal = 387 -
          7.31 * userEntity.age +
          _getPAValueIOM2005(userEntity) *
              10.9 *
              userEntity.weightKG +
          660.7 * (userEntity.heightCM / 100);
    }
    return tdeeKcal;
  }

  /// IOM 2005 PA coefficient look-up.
  static double _getPAValueIOM2005(UserEntity userEntity) {
    final isMale = userEntity.gender == UserGenderEntity.male;
    switch (userEntity.pal) {
      case UserPALEntity.sedentary:
        return 1.0;
      case UserPALEntity.lowActive:
        return isMale ? 1.12 : 1.14;
      case UserPALEntity.active:
        return 1.27;
      case UserPALEntity.veryActive:
        return isMale ? 1.54 : 1.45;
    }
  }
}
