part of 'calendar_day_bloc.dart';

abstract class CalendarDayState extends Equatable {
  const CalendarDayState();
}

class CalendarDayInitial extends CalendarDayState {
  @override
  List<Object> get props => [];
}

class CalendarDayLoading extends CalendarDayState {
  @override
  List<Object?> get props => [];
}

class CalendarDayLoaded extends CalendarDayState {
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivityList;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final double totalKcalGoal;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;

  const CalendarDayLoaded(
      this.trackedDayEntity,
      this.userActivityList,
      this.breakfastIntakeList,
      this.lunchIntakeList,
      this.dinnerIntakeList,
      this.snackIntakeList, {
      required this.totalKcalGoal,
      required this.totalKcalLeft,
      required this.totalKcalSupplied,
      required this.totalKcalBurned,
      required this.totalCarbsIntake,
      required this.totalFatsIntake,
      required this.totalProteinsIntake,
      required this.totalCarbsGoal,
      required this.totalFatsGoal,
      required this.totalProteinsGoal,
      });

  @override
  List<Object?> get props => [trackedDayEntity];
}
