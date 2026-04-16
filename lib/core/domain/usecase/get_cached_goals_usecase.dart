import 'package:opennutritracker/core/data/repository/config_repository.dart';

class CachedGoals {
  final double? kcalGoal;
  final double? carbsGoal;
  final double? fatsGoal;
  final double? proteinsGoal;

  const CachedGoals({
    this.kcalGoal,
    this.carbsGoal,
    this.fatsGoal,
    this.proteinsGoal,
  });

  bool get hasGoals => kcalGoal != null;
}

class GetCachedGoalsUsecase {
  final ConfigRepository _configRepository;

  GetCachedGoalsUsecase(this._configRepository);

  Future<CachedGoals> getCachedGoals() async {
    final config = await _configRepository.getConfig();
    return CachedGoals(
      kcalGoal: config.cachedKcalGoal,
      carbsGoal: config.cachedCarbsGoal,
      fatsGoal: config.cachedFatsGoal,
      proteinsGoal: config.cachedProteinsGoal,
    );
  }

  Future<double?> getCachedKcalGoal() async {
    final config = await _configRepository.getConfig();
    return config.cachedKcalGoal;
  }

  Future<double?> getCachedCarbsGoal() async {
    final config = await _configRepository.getConfig();
    return config.cachedCarbsGoal;
  }

  Future<double?> getCachedFatsGoal() async {
    final config = await _configRepository.getConfig();
    return config.cachedFatsGoal;
  }

  Future<double?> getCachedProteinsGoal() async {
    final config = await _configRepository.getConfig();
    return config.cachedProteinsGoal;
  }
}

