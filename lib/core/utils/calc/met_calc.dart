import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';

enum ActivityIntensity {
  light,
  moderate,
  vigorous,
}

class METCalc {
  /// Calculates total kcal with formula by the
  /// '2011 Compendium of Physical Activities'
  /// https://pubmed.ncbi.nlm.nih.gov/21681120/
  /// by Ainsworth et al.
  /// kcal = MET x weight in kg x duration in hours
  static double getTotalBurnedKcal(UserEntity userEntity,
      PhysicalActivityEntity physicalActivityEntity, double durationMin) {
    return getTotalBurnedKcalAdvanced(
      userWeightKg: userEntity.weightKG,
      physicalActivityEntity: physicalActivityEntity,
      durationMin: durationMin,
      intensity: ActivityIntensity.moderate,
    );
  }

  /// Uses the ACSM oxygen-consumption based conversion with a light
  /// intensity adjustment and a small EPOC bonus for sustained vigorous work.
  static double getTotalBurnedKcalAdvanced({
    required double userWeightKg,
    required PhysicalActivityEntity physicalActivityEntity,
    required double durationMin,
    required ActivityIntensity intensity,
  }) {
    if (userWeightKg <= 0 || durationMin <= 0) {
      return 0;
    }

    final intensityMultiplier = switch (intensity) {
      ActivityIntensity.light => 0.9,
      ActivityIntensity.moderate => 1.0,
      ActivityIntensity.vigorous => 1.12,
    };

    // kcal/min = MET * 3.5 * body weight (kg) / 200
    final kcalPerMin = physicalActivityEntity.mets * 3.5 * userWeightKg / 200;
    final baseBurn = kcalPerMin * durationMin * intensityMultiplier;

    final epocBonus = intensity == ActivityIntensity.vigorous &&
            durationMin >= 20 &&
            physicalActivityEntity.mets >= 6
        ? baseBurn * 0.06
        : 0.0;

    return baseBurn + epocBonus;
  }
}
