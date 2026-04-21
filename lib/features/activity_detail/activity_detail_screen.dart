import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/utils/calc/met_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:opennutritracker/features/activity_detail/presentation/widget/activity_title_expanded.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  static const _containerSize = 170.0;

  final log = Logger('ItemDetailScreen');
  final _scrollController = ScrollController();

  late PhysicalActivityEntity activityEntity;
  late DateTime _day;
  late TextEditingController quantityTextController;

  late ActivityDetailBloc _activityDetailBloc;

  late double totalDurationMin;
  late double totalKcal;
  UserEntity? _userEntity;
  String _durationUnit = 'min';
  ActivityIntensity _intensity = ActivityIntensity.moderate;

  @override
  void initState() {
    _activityDetailBloc = locator<ActivityDetailBloc>();
    quantityTextController = TextEditingController();
    quantityTextController.text = '60';
    totalDurationMin = 60;
    totalKcal = 0;
    quantityTextController.addListener(_recalculateFromInputs);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments
        as ActivityDetailScreenArguments;
    activityEntity = args.activityEntity;
    _day = args.day;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    quantityTextController.removeListener(_recalculateFromInputs);
    quantityTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ActivityDetailBloc, ActivityDetailState>(
        bloc: _activityDetailBloc,
        builder: (context, state) {
          if (state is ActivityDetailInitial) {
            _activityDetailBloc
                .add(LoadActivityDetailEvent(context, activityEntity));
            return getLoadingContent();
          } else if (state is ActivityDetailLoadingState) {
            return getLoadingContent();
          } else if (state is ActivityDetailLoadedState) {
            _syncInitialUserValues(state.userEntity);
            return Column(
              children: [
                Expanded(child: getLoadedContent(state.userEntity)),
                _buildInputPanel(context),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget getLoadedContent(UserEntity userEntity) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                final barsHeight =
                    MediaQuery.of(context).padding.top + kToolbarHeight;
                const offset = 10;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1, // don't scale title
                  background: ActivityTitleExpanded(activity: activityEntity),
                  title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(activityEntity.getName(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                            : const SizedBox(),
                  ),
                );
              },
            )),
        SliverList(
            delegate: SliverChildListDelegate([
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Container(
                width: _containerSize,
                height: _containerSize,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.65)
                ])),
                child: Icon(
                  activityEntity.displayIcon,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).caloriesLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '~${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                          ),
                          Text(
                            '${S.of(context).burnedLabel} • ${totalDurationMin.toStringAsFixed(0)} ${S.of(context).minutesUnitLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(S.of(context).caloriesLabel),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                /*  Text(
                  activityEntity.getDescription(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),*/
                const SizedBox(height: 8),
                const SizedBox(height: 120.0)
              ],
            ),
          )
        ]))
      ],
    );
  }

  void _syncInitialUserValues(UserEntity userEntity) {
    if (_userEntity != null) {
      return;
    }
    _userEntity = userEntity;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _recalculateFromInputs();
    });
  }

  void _onUnitChanged(String unit) {
    if (_durationUnit == unit) {
      return;
    }

    final previousValue = _parsePositiveDouble(quantityTextController.text);
    if (previousValue != null) {
      final convertedValue =
          _durationUnit == 'min' ? previousValue / 60 : previousValue * 60;
      quantityTextController.text = unit == 'hr'
          ? convertedValue.toStringAsFixed(2)
          : convertedValue.toStringAsFixed(0);
    }

    _durationUnit = unit;
    _recalculateFromInputs();
  }

  void _onIntensityChanged(ActivityIntensity intensity) {
    _intensity = intensity;
    _recalculateFromInputs();
  }

  void _recalculateFromInputs() {
    if (_userEntity == null) {
      return;
    }

    final durationInput = _parsePositiveDouble(quantityTextController.text);
    if (durationInput == null) {
      return;
    }

    final durationMin =
        _durationUnit == 'hr' ? durationInput * 60 : durationInput;
    final newTotalKcal = _activityDetailBloc.getTotalKcalBurned(
      _userEntity!,
      activityEntity,
      durationMin,
      intensity: _intensity,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      totalDurationMin = durationMin;
      totalKcal = newTotalKcal;
    });
  }

  double? _parsePositiveDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      log.warning('Invalid number entered: "$value"');
      return null;
    }
    return parsed;
  }

  void onAddButtonPressed(BuildContext context) {
    if (totalDurationMin <= 0 || totalKcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).invalidInputLabel)),
      );
      return;
    }

    _activityDetailBloc.persistActivity(context,
        totalDurationMin.toStringAsFixed(1), totalKcal, activityEntity, _day);

    // Refresh Home Page
    locator<HomeBloc>().add(const LoadItemsEvent());

    // Refresh Diary Page
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    // Show snackbar and return to add activity screen
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).infoAddedActivityLabel)));
    Navigator.of(context)
        .popUntil(ModalRoute.withName(NavigationOptions.addActivityRoute));
  }

  Widget _buildInputPanel(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityTextController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: S.of(context).quantityLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _durationUnit,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: S.of(context).unitLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'min',
                          child: Text(S.of(context).minutesUnitLabel)),
                      DropdownMenuItem(
                          value: 'hr',
                          child: Text(S.of(context).hoursUnitLabel)),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      _onUnitChanged(value);
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            SegmentedButton<ActivityIntensity>(
              showSelectedIcon: false,
              selected: {_intensity},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) {
                  return;
                }
                _onIntensityChanged(selection.first);
              },
              segments: [
                ButtonSegment(
                    value: ActivityIntensity.light,
                    label: Text(S.of(context).intensityLightLabel)),
                ButtonSegment(
                    value: ActivityIntensity.moderate,
                    label: Text(S.of(context).intensityModerateLabel)),
                ButtonSegment(
                    value: ActivityIntensity.vigorous,
                    label: Text(S.of(context).intensityVigorousLabel)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onAddButtonPressed(context),
                icon: const Icon(Icons.check_rounded),
                label: Text(S.of(context).addLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityDetailScreenArguments {
  final PhysicalActivityEntity activityEntity;
  final DateTime day;

  ActivityDetailScreenArguments(this.activityEntity, this.day);
}
