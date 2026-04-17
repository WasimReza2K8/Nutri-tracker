part of 'camera_scan_bloc.dart';

abstract class CameraScanState extends Equatable {
  const CameraScanState();
}

class CameraScanInitialState extends CameraScanState {
  const CameraScanInitialState();

  @override
  List<Object?> get props => [];
}

class CameraScanLoadingState extends CameraScanState {
  const CameraScanLoadingState();

  @override
  List<Object?> get props => [];
}

class CameraScanLoadedState extends CameraScanState {
  final List<MealEntity> results;

  const CameraScanLoadedState({required this.results});

  @override
  List<Object?> get props => [results];
}

class CameraScanErrorState extends CameraScanState {
  final String error;

  const CameraScanErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

