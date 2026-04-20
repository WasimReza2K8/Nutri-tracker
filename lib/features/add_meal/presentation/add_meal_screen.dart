import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/presentation/widgets/error_dialog.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/add_meal_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/camera_scan_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/food_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:opennutritracker/features/add_meal/presentation/widgets/meal_item_card.dart';
import 'package:opennutritracker/features/add_meal/presentation/widgets/meal_search_bar.dart';
import 'package:opennutritracker/features/add_meal/presentation/widgets/no_results_widget.dart';
import 'package:opennutritracker/features/add_meal/presentation/widgets/recent_separator.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/scanner/scanner_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

enum _AddMealMode { search, camera, barcode, manual }

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final ValueNotifier<String> _searchStringListener = ValueNotifier('');

  late AddMealType _mealType;
  late DateTime _day;

  late ProductsBloc _productsBloc;
  late FoodBloc _foodBloc;
  late RecentMealBloc _recentMealBloc;
  late CameraScanBloc _cameraScanBloc;
  late AddIntakeUsecase _addIntakeUsecase;
  late AddTrackedDayUsecase _addTrackedDayUsecase;
  late GetKcalGoalUsecase _getKcalGoalUsecase;
  late GetMacroGoalUsecase _getMacroGoalUsecase;

  _AddMealMode _selectedMode = _AddMealMode.search;
  bool _usesImperialUnits = false;

  @override
  void initState() {
    _productsBloc = locator<ProductsBloc>();
    _foodBloc = locator<FoodBloc>();
    _recentMealBloc = locator<RecentMealBloc>();
    _cameraScanBloc = locator<CameraScanBloc>();
    _addIntakeUsecase = locator<AddIntakeUsecase>();
    _addTrackedDayUsecase = locator<AddTrackedDayUsecase>();
    _getKcalGoalUsecase = locator<GetKcalGoalUsecase>();
    _getMacroGoalUsecase = locator<GetMacroGoalUsecase>();
    // Load recent meals on init
    _recentMealBloc.add(const LoadRecentMealEvent(searchString: ""));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as AddMealScreenArguments;
    _mealType = args.mealType;
    _day = args.day;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_mealType.getTypeName(context)),
      ),
      body: BlocBuilder<AddMealBloc, AddMealState>(
        bloc: locator<AddMealBloc>()..add(const InitializeAddMealEvent()),
        builder: (context, addMealState) {
          if (addMealState is AddMealLoadedState) {
            _usesImperialUnits = addMealState.usesImperialUnits;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _buildModeSelector(context),
                const SizedBox(height: 12),
                Expanded(child: _buildBodyForMode(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    final modes = [
      (_AddMealMode.search, Icons.search, S.of(context).searchModeLabel),
      (_AddMealMode.camera, Icons.camera_alt, S.of(context).cameraModeLabel),
      (_AddMealMode.barcode, CustomIcons.barcode_scan, S.of(context).barcodeModeLabel),
      (_AddMealMode.manual, Icons.keyboard, S.of(context).manualModeLabel),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: modes.map((entry) {
        final (mode, icon, label) = entry;
        final isSelected = _selectedMode == mode;
        return GestureDetector(
          onTap: () => _onModeSelected(mode),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _onModeSelected(_AddMealMode mode) {
    if (mode == _AddMealMode.barcode) {
      _onBarcodeIconPressed();
      return;
    }
    if (mode == _AddMealMode.manual) {
      _openEditMealScreen(_usesImperialUnits);
      return;
    }
    if (mode == _AddMealMode.camera) {
      setState(() => _selectedMode = mode);
      _onCameraPressed();
      return;
    }
    setState(() => _selectedMode = mode);
  }

  Widget _buildBodyForMode(BuildContext context) {
    switch (_selectedMode) {
      case _AddMealMode.search:
        return _buildSearchBody(context);
      case _AddMealMode.camera:
        return _buildCameraBody(context);
      case _AddMealMode.barcode:
      case _AddMealMode.manual:
        return const SizedBox();
    }
  }

  Widget _buildSearchBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: MealSearchBar(
            searchStringListener: _searchStringListener,
            onSearchSubmit: _onSearchSubmit,
            onBarcodePressed: _onBarcodeIconPressed,
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: _buildCombinedSearchAndRecentList(context),
        ),
      ],
    );
  }

  Widget _buildCombinedSearchAndRecentList(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      bloc: _productsBloc,
      builder: (context, productsState) {
        return BlocBuilder<FoodBloc, FoodState>(
          bloc: _foodBloc,
          builder: (context, foodState) {
            return BlocBuilder<RecentMealBloc, RecentMealState>(
              bloc: _recentMealBloc,
              builder: (context, recentState) {
                // Combine search results
                final searchResults = <MealEntity>[];
                if (productsState is ProductsLoadedState) {
                  searchResults.addAll(productsState.products);
                }
                if (foodState is FoodLoadedState) {
                  searchResults.addAll(foodState.food);
                }

                // Get recent items
                final recentItems = <MealEntity>[];
                if (recentState is RecentMealLoadedState) {
                  recentItems.addAll(recentState.recentMeals);
                }

                // Check for loading states. Keep recent loading behavior as-is.
                if (productsState is ProductsLoadingState ||
                    foodState is FoodLoadingState ||
                    recentState is RecentMealLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Only show an error when search was attempted and no search source succeeded.
                final hasSearchError =
                    productsState is ProductsFailedState ||
                    foodState is FoodFailedState;
                final hasSearched = _searchStringListener.value.isNotEmpty;
                if (hasSearched && hasSearchError && searchResults.isEmpty) {
                  return ErrorDialog(
                    errorText: S.of(context).errorFetchingProductData,
                    onRefreshPressed: () {
                      _productsBloc.add(const RefreshProductsEvent());
                      _foodBloc.add(const RefreshFoodEvent());
                    },
                  );
                }

                // Build combined list
                if (searchResults.isEmpty && recentItems.isEmpty) {
                  return const NoResultsWidget();
                }

                return ListView.builder(
                  itemCount: searchResults.length +
                      (recentItems.isNotEmpty ? 1 + recentItems.length : 0),
                  itemBuilder: (context, index) {
                    // Show search results first
                    if (index < searchResults.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: MealItemCard(
                          day: _day,
                          mealEntity: searchResults[index],
                          addMealType: _mealType,
                          usesImperialUnits: _usesImperialUnits,
                          onAddPressed: () {
                            _addMealToDay(searchResults[index]);
                          },
                        ),
                      );
                    }

                    // After search results, show recent separator and items
                    final recentStartIndex = searchResults.length;
                    final itemIndexAfterSearch = index - recentStartIndex;

                    if (itemIndexAfterSearch == 0 && recentItems.isNotEmpty) {
                      return RecentSeparator(
                        label: S.of(context).recentlyAddedLabel,
                      );
                    }

                    if (recentItems.isNotEmpty && itemIndexAfterSearch > 0) {
                      final recentItemIndex = itemIndexAfterSearch - 1;
                      if (recentItemIndex < recentItems.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: MealItemCard(
                            day: _day,
                            mealEntity: recentItems[recentItemIndex],
                            addMealType: _mealType,
                            usesImperialUnits: _usesImperialUnits,
                            onAddPressed: () {
                              _addMealToDay(recentItems[recentItemIndex]);
                            },
                          ),
                        );
                      }
                    }

                    return const SizedBox();
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCameraBody(BuildContext context) {
    return BlocBuilder<CameraScanBloc, CameraScanState>(
      bloc: _cameraScanBloc,
      builder: (context, state) {
        if (state is CameraScanInitialState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(S.of(context).cameraTakePhotoLabel,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _onCameraPressed,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(S.of(context).cameraModeLabel),
                ),
              ],
            ),
          );
        } else if (state is CameraScanLoadingState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(S.of(context).cameraAnalyzingLabel),
              ],
            ),
          );
        } else if (state is CameraScanLoadedState) {
          if (state.results.isEmpty) {
            return const NoResultsWidget();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              return MealItemCard(
                day: _day,
                mealEntity: state.results[index],
                addMealType: _mealType,
                usesImperialUnits: _usesImperialUnits,
                onAddPressed: () {
                  _addMealToDay(state.results[index]);
                },
              );
            },
          );
        } else if (state is CameraScanErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(S.of(context).cameraErrorLabel),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _onCameraPressed,
                  icon: const Icon(Icons.refresh),
                  label: Text(S.of(context).cameraModeLabel),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<void> _addMealToDay(MealEntity meal) async {
    final quickAddAmount = _resolveQuickAddAmount(meal);
    final intakeEntity = IntakeEntity(
      id: IdGenerator.getUniqueID(),
      unit: meal.mealUnit ?? 'g/ml',
      amount: quickAddAmount,
      type: _mealType.getIntakeType(),
      meal: meal,
      dateTime: _day,
    );

    try {
      await _addIntakeUsecase.addIntake(intakeEntity);
      await _updateTrackedDay(intakeEntity, _day);

      // Refresh screens relying on intake/tracked-day aggregates.
      locator<HomeBloc>().add(const LoadItemsEvent());
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
      _recentMealBloc.add(const LoadRecentMealEvent(searchString: ""));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).infoAddedIntakeLabel)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorFetchingProductData)),
      );
    }
  }

  double _resolveQuickAddAmount(MealEntity meal) {
    if ((meal.servingQuantity ?? 0) > 0) {
      return meal.servingQuantity!;
    }

    final parsedMealQuantity =
        double.tryParse((meal.mealQuantity ?? '').replaceAll(',', '.'));
    if ((parsedMealQuantity ?? 0) > 0) {
      return parsedMealQuantity!;
    }

    return 100;
  }

  Future<void> _updateTrackedDay(IntakeEntity intakeEntity, DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
      final totalCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      await _addTrackedDayUsecase.addNewTrackedDay(
        day,
        totalKcalGoal,
        totalCarbsGoal,
        totalFatGoal,
        totalProteinGoal,
      );
    }

    await _addTrackedDayUsecase.addDayCaloriesTracked(day, intakeEntity.totalKcal);
    await _addTrackedDayUsecase.addDayMacrosTracked(
      day,
      carbsTracked: intakeEntity.totalCarbsGram,
      fatTracked: intakeEntity.totalFatsGram,
      proteinTracked: intakeEntity.totalProteinsGram,
    );
  }

  void _onSearchSubmit(String inputText) {
    _productsBloc.add(LoadFoodSearchProductsEvent(searchString: inputText));
    _foodBloc.add(LoadFoodEvent(searchString: inputText));
  }

  void _onBarcodeIconPressed() {
    Navigator.of(context).pushNamed(NavigationOptions.scannerRoute,
        arguments: ScannerScreenArguments(_day, _mealType.getIntakeType()));
  }

  Future<void> _onCameraPressed() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).cameraPermissionDeniedLabel)),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final imageBytes = await File(pickedFile.path).readAsBytes();
      _cameraScanBloc.add(AnalyzeImageEvent(imageBytes: imageBytes));
    }
  }

  void _openEditMealScreen(bool usesImperialUnits) {
    Navigator.of(context).pushNamed(NavigationOptions.editMealRoute,
        arguments: EditMealScreenArguments(
          _day,
          MealEntity.empty(),
          _mealType.getIntakeType(),
          usesImperialUnits,
        ));
  }
}

class AddMealScreenArguments {
  final AddMealType mealType;
  final DateTime day;

  AddMealScreenArguments(this.mealType, this.day);
}

