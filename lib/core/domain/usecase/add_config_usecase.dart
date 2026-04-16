import 'package:opennutritracker/core/data/repository/config_repository.dart';
import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';
import 'package:opennutritracker/core/domain/entity/config_entity.dart';

class AddConfigUsecase {
  final ConfigRepository _configRepository;

  AddConfigUsecase(this._configRepository);

  Future<void> addConfig(ConfigEntity configEntity) async {
    _configRepository.updateConfig(configEntity);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _configRepository.setConfigDisclaimer(hasAcceptedDisclaimer);
  }

  Future<void> setConfigHasAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _configRepository
        .setConfigHasAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  Future<void> setConfigAppTheme(AppThemeEntity appTheme) async {
    await _configRepository.setConfigAppTheme(appTheme);
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _configRepository.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _configRepository.setConfigKcalAdjustment(kcalAdjustment);
  }

  Future<void> setConfigMacroGoalPct(
      double carbGoalPct, double proteinGoalPct, double fatPctGoal) async {
    _configRepository.setUserMacroPct(carbGoalPct, proteinGoalPct, fatPctGoal);
  }

  Future<void> setCachedGoals({
    required double kcalGoal,
    required double carbsGoal,
    required double fatsGoal,
    required double proteinsGoal,
  }) async {
    await _configRepository.setCachedGoals(
      kcalGoal: kcalGoal,
      carbsGoal: carbsGoal,
      fatsGoal: fatsGoal,
      proteinsGoal: proteinsGoal,
    );
  }
}
