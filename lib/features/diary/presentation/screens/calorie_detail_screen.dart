import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_activity_entity.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:opennutritracker/core/presentation/widgets/delete_dialog.dart';
import 'package:opennutritracker/core/presentation/widgets/edit_dialog.dart';
import 'package:opennutritracker/core/utils/calc/macro_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_activity/presentation/add_activity_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class CalorieDetailScreenArguments {
  final String title;
  final IconData icon;
  final List<IntakeEntity> intakeList;
  final List<UserActivityEntity> activityList;
  final DateTime selectedDay;
  final TrackedDayEntity? trackedDayEntity;
  final bool usesImperialUnits;
  final AddMealType? addMealType; // null means it's activity

  const CalorieDetailScreenArguments({
    required this.title,
    required this.icon,
    required this.selectedDay,
    required this.usesImperialUnits,
    this.intakeList = const [],
    this.activityList = const [],
    this.trackedDayEntity,
    this.addMealType,
  });

  bool get isActivity => addMealType == null;
}

class CalorieDetailScreen extends StatefulWidget {
  const CalorieDetailScreen({super.key});

  @override
  State<CalorieDetailScreen> createState() => _CalorieDetailScreenState();
}

class _CalorieDetailScreenState extends State<CalorieDetailScreen> {
  late CalorieDetailScreenArguments _args;
  late List<IntakeEntity> _intakeList;
  late List<UserActivityEntity> _activityList;

  late DeleteIntakeUsecase _deleteIntakeUsecase;
  late DeleteUserActivityUsecase _deleteUserActivityUsecase;
  late UpdateIntakeUsecase _updateIntakeUsecase;
  late GetIntakeUsecase _getIntakeUsecase;
  late AddTrackedDayUsecase _addTrackedDayUsecase;

  bool _initialized = false;

  @override
  void initState() {
    _deleteIntakeUsecase = locator<DeleteIntakeUsecase>();
    _deleteUserActivityUsecase = locator<DeleteUserActivityUsecase>();
    _updateIntakeUsecase = locator<UpdateIntakeUsecase>();
    _getIntakeUsecase = locator<GetIntakeUsecase>();
    _addTrackedDayUsecase = locator<AddTrackedDayUsecase>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      _args = ModalRoute.of(context)!.settings.arguments
          as CalorieDetailScreenArguments;
      _intakeList = List.from(_args.intakeList);
      _activityList = List.from(_args.activityList);
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  // ── computed totals ──────────────────────────────────────────────────────────

  double get _totalKcal => _args.isActivity
      ? _activityList.fold(0.0, (s, e) => s + e.burnedKcal)
      : _intakeList.fold(0.0, (s, e) => s + e.totalKcal);

  double get _totalCarbs =>
      _intakeList.fold(0.0, (s, e) => s + e.totalCarbsGram);

  double get _totalFat =>
      _intakeList.fold(0.0, (s, e) => s + e.totalFatsGram);

  double get _totalProtein =>
      _intakeList.fold(0.0, (s, e) => s + e.totalProteinsGram);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).colorScheme.outline, width: 1.5),
            ),
            child: Icon(Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Big icon circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(100),
                  ),
                  child: Icon(
                    _args.icon,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _args.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                // Macro summary card (meals only)
                if (!_args.isActivity)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroCell(context,
                                value: _totalCarbs,
                                label: S.of(context).carbsLabel,
                                unit: 'g'),
                            _buildMacroCell(context,
                                value: _totalProtein,
                                label: S.of(context).proteinLabel,
                                unit: 'g'),
                            _buildMacroCell(context,
                                value: _totalFat,
                                label: S.of(context).fatLabel,
                                unit: 'g'),
                            _buildMacroCell(context,
                                value: _totalKcal,
                                label: S.of(context).caloriesLabel,
                                unit: S.of(context).kcalLabel,
                                isKcal: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      S.of(context).componentsLabel,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(180),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Items list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_args.isActivity) {
                  final item = _activityList[index];
                  return _buildActivityItem(context, item);
                } else {
                  final item = _intakeList[index];
                  return _buildIntakeItem(context, item);
                }
              },
              childCount:
                  _args.isActivity ? _activityList.length : _intakeList.length,
            ),
          ),

          // Add more row
          SliverToBoxAdapter(
            child: Column(
              children: [
                if ((_args.isActivity ? _activityList : _intakeList).isNotEmpty)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withAlpha(80),
                  ),
                InkWell(
                  onTap: _onAddMore,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Icon(Icons.add,
                              color:
                                  Theme.of(context).colorScheme.onPrimary,
                              size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          S.of(context).addMoreLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── item builders ─────────────────────────────────────────────────────────

  Widget _buildIntakeItem(BuildContext context, IntakeEntity item) {
    return Column(
      children: [
        Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.onError, size: 28),
          ),
          onDismissed: (_) => _deleteIntake(item),
          child: InkWell(
            onTap: () => _editIntake(context, item),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildItemThumbnail(context, item),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.meal.name ?? '?',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.totalKcal.toStringAsFixed(1)} ${S.of(context).kcalLabel}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(180),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(100)),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withAlpha(80),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, UserActivityEntity item) {
    return Column(
      children: [
        Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.onError, size: 28),
          ),
          onDismissed: (_) => _deleteActivity(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(80),
                  ),
                  child: Icon(
                    item.physicalActivityEntity.displayIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.physicalActivityEntity.getName(context),
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.burnedKcal.toStringAsFixed(1)} ${S.of(context).kcalLabel} · ${item.duration.toInt()} min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(180),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withAlpha(80),
        ),
      ],
    );
  }

  Widget _buildItemThumbnail(BuildContext context, IntakeEntity item) {
    if (item.meal.thumbnailImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          cacheManager: locator<CacheManager>(),
          imageUrl: item.meal.thumbnailImageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallbackIcon(context, item),
        ),
      );
    }
    return _fallbackIcon(context, item);
  }

  Widget _fallbackIcon(BuildContext context, IntakeEntity item) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
      ),
      child: Icon(
        item.type.getIconData(),
        color: Theme.of(context).colorScheme.primary,
        size: 26,
      ),
    );
  }

  Widget _buildMacroCell(
    BuildContext context, {
    required double value,
    required String label,
    required String unit,
    bool isKcal = false,
  }) {
    return Column(
      children: [
        Text(
          isKcal
              ? '${value.toStringAsFixed(1)} $unit'
              : '${value.toStringAsFixed(1)} $unit',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha(160),
              ),
        ),
      ],
    );
  }

  // ── actions ───────────────────────────────────────────────────────────────

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const DeleteDialog(),
    );
  }

  Future<void> _editIntake(
      BuildContext context, IntakeEntity intakeEntity) async {
    final messenger = ScaffoldMessenger.of(context);
    final updatedMsg = S.of(context).itemUpdatedSnackbar;
    final newAmount = await showDialog<double>(
      context: context,
      builder: (_) => EditDialog(
          intakeEntity: intakeEntity,
          usesImperialUnits: _args.usesImperialUnits),
    );
    if (newAmount == null || !mounted) return;

    // Get old values before update
    final old = await _getIntakeUsecase.getIntakeById(intakeEntity.id);
    await _updateIntakeUsecase.updateIntake(
        intakeEntity.id, {'amount': newAmount});
    final updated = await _getIntakeUsecase.getIntakeById(intakeEntity.id);

    if (old != null && updated != null) {
      final kcalDiff = updated.totalKcal - old.totalKcal;
      final carbsDiff = updated.totalCarbsGram - old.totalCarbsGram;
      final fatDiff = updated.totalFatsGram - old.totalFatsGram;
      final proteinDiff = updated.totalProteinsGram - old.totalProteinsGram;

      if (kcalDiff > 0) {
        await _addTrackedDayUsecase.addDayCaloriesTracked(
            _args.selectedDay, kcalDiff);
        await _addTrackedDayUsecase.addDayMacrosTracked(_args.selectedDay,
            carbsTracked: carbsDiff,
            fatTracked: fatDiff,
            proteinTracked: proteinDiff);
      } else if (kcalDiff < 0) {
        await _addTrackedDayUsecase.removeDayCaloriesTracked(
            _args.selectedDay, kcalDiff.abs());
        await _addTrackedDayUsecase.removeDayMacrosTracked(_args.selectedDay,
            carbsTracked: carbsDiff.abs(),
            fatTracked: fatDiff.abs(),
            proteinTracked: proteinDiff.abs());
      }

      setState(() {
        final idx = _intakeList.indexWhere((e) => e.id == intakeEntity.id);
        if (idx != -1) _intakeList[idx] = updated;
      });
      _refreshBlocs();

      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(updatedMsg)));
      }
    }
  }

  Future<void> _deleteIntake(IntakeEntity item) async {
    await _deleteIntakeUsecase.deleteIntake(item);
    await _addTrackedDayUsecase.removeDayCaloriesTracked(
        _args.selectedDay, item.totalKcal);
    await _addTrackedDayUsecase.removeDayMacrosTracked(_args.selectedDay,
        carbsTracked: item.totalCarbsGram,
        fatTracked: item.totalFatsGram,
        proteinTracked: item.totalProteinsGram);
    setState(() => _intakeList.removeWhere((e) => e.id == item.id));
    _refreshBlocs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
    }
  }

  Future<void> _deleteActivity(UserActivityEntity item) async {
    await _deleteUserActivityUsecase.deleteUserActivity(item);
    // Activities increase the goal, so reduce goal back
    await _addTrackedDayUsecase.reduceDayCalorieGoal(
        _args.selectedDay, item.burnedKcal);
    final carbsAmount = MacroCalc.getTotalCarbsGoal(item.burnedKcal);
    final fatAmount = MacroCalc.getTotalFatsGoal(item.burnedKcal);
    final proteinAmount = MacroCalc.getTotalProteinsGoal(item.burnedKcal);
    await _addTrackedDayUsecase.reduceDayMacroGoals(_args.selectedDay,
        carbsAmount: carbsAmount,
        fatAmount: fatAmount,
        proteinAmount: proteinAmount);
    setState(() => _activityList.removeWhere((e) => e.id == item.id));
    _refreshBlocs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
    }
  }

  void _onAddMore() {
    if (_args.isActivity) {
      Navigator.of(context).pushNamed(
        NavigationOptions.addActivityRoute,
        arguments: AddActivityScreenArguments(day: _args.selectedDay),
      );
    } else {
      Navigator.pushNamed(
        context,
        NavigationOptions.addMealRoute,
        arguments:
            AddMealScreenArguments(_args.addMealType!, _args.selectedDay),
      );
    }
  }

  void _refreshBlocs() {
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<HomeBloc>().add(const LoadItemsEvent());
  }
}




