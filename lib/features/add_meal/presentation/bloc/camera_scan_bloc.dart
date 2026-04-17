import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/usecase/search_food_usecase.dart';

part 'camera_scan_event.dart';
part 'camera_scan_state.dart';

class CameraScanBloc extends Bloc<CameraScanEvent, CameraScanState> {
  final SearchFoodUseCase _searchFoodUseCase;

  CameraScanBloc(this._searchFoodUseCase) : super(const CameraScanInitialState()) {
    on<AnalyzeImageEvent>((event, emit) async {
      emit(const CameraScanLoadingState());
      try {
        final results = await _searchFoodUseCase.estimateCaloriesFromImage(event.imageBytes);
        emit(CameraScanLoadedState(results: results));
      } catch (e) {
        emit(CameraScanErrorState(error: e.toString()));
      }
    });

    on<ResetCameraScanEvent>((event, emit) {
      emit(const CameraScanInitialState());
    });
  }
}

