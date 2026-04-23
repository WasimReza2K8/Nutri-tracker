import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/domain/entity/user_bmi_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_pal_entity.dart';
import 'package:opennutritracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_gender_dialog.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_goal_dialog.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_height_dialog.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_pal_category_dialog.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_target_weight_dialog.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_weight_dialog.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late ProfileBloc _profileBloc;
  late AnimationController _headerAnimController;
  late AnimationController _listAnimController;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  @override
  void initState() {
    _profileBloc = locator<ProfileBloc>();

    _headerAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _listAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _headerFadeAnim =
        CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut);
    _headerSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _headerAnimController, curve: Curves.easeOutCubic));

    super.initState();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _headerAnimController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200),
        () => _listAnimController.forward(from: 0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _profileBloc,
      builder: (context, state) {
        if (state is ProfileInitial) {
          _profileBloc.add(LoadProfileEvent());
          return _getLoadingContent();
        } else if (state is ProfileLoadingState) {
          return _getLoadingContent();
        } else if (state is ProfileLoadedState) {
          _startAnimations();
          return _getLoadedContent(context, state.userBMI, state.userEntity,
              state.usesImperialUnits);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  Widget _getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _getLoadedContent(BuildContext context, UserBMIEntity userBMIEntity,
      UserEntity user, bool usesImperialUnits) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SlideTransition(
            position: _headerSlideAnim,
            child: FadeTransition(
              opacity: _headerFadeAnim,
              child: _buildHeader(
                  context, userBMIEntity, user, usesImperialUnits, colorScheme),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 0,
                child: _buildSectionHeader(context, S.of(context).goalLabel,
                    Icons.track_changes_rounded),
              ),
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 1,
                child: _buildGoalCard(
                    context, user, usesImperialUnits, colorScheme),
              ),
              const SizedBox(height: 16),
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 2,
                child: _buildSectionHeader(context, S.of(context).activityLabel,
                    Icons.directions_run_rounded),
              ),
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 3,
                child: _buildActivityCard(context, user, colorScheme),
              ),
              const SizedBox(height: 16),
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 4,
                child: _buildSectionHeader(context, S.of(context).bodyInfoLabel,
                    Icons.accessibility_new_rounded),
              ),
              _AnimatedProfileCard(
                animController: _listAnimController,
                index: 5,
                child: _buildBodyInfoCard(
                    context, user, usesImperialUnits, colorScheme),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserBMIEntity userBMIEntity,
      UserEntity user, bool usesImperialUnits, ColorScheme colorScheme) {
    final bmiColor = _getBmiColor(context, userBMIEntity.nutritionalStatus);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildBmiCircle(context, userBMIEntity, bmiColor, colorScheme),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userBMIEntity.nutritionalStatus.getName(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userBMIEntity.nutritionalStatus.getRiskStatus(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickStat(
                          context,
                          '${_profileBloc.getDisplayWeight(user, usesImperialUnits)}',
                          usesImperialUnits
                              ? S.of(context).lbsLabel
                              : S.of(context).kgLabel,
                          Icons.monitor_weight_outlined,
                          colorScheme,
                        ),
                        const SizedBox(width: 12),
                        _buildQuickStat(
                          context,
                          '${_profileBloc.getDisplayHeight(user, usesImperialUnits)}',
                          usesImperialUnits
                              ? S.of(context).ftLabel
                              : S.of(context).cmLabel,
                          Icons.height_outlined,
                          colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user.targetWeightKG != null) ...[
            const SizedBox(height: 20),
            _buildWeightProgressBar(
                context, user, usesImperialUnits, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildBmiCircle(BuildContext context, UserBMIEntity entity,
      Color bmiColor, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bmiColor.withValues(alpha: 0.2),
          border: Border.all(color: bmiColor, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entity.bmiValue.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            Text(
              S.of(context).bmiLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String unit,
      IconData icon, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          '$value $unit',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildWeightProgressBar(BuildContext context, UserEntity user,
      bool usesImperialUnits, ColorScheme colorScheme) {
    final current = user.weightKG;
    final target = user.targetWeightKG!;
    // Determine start weight (assume ±15kg or lbs range for visualization)
    final isLosingWeight = user.goal == UserWeightGoalEntity.loseWeight;
    double progress;
    if (isLosingWeight) {
      // start is higher, target is lower
      final start = target + 15;
      progress = ((start - current) / (start - target)).clamp(0.0, 1.0);
    } else {
      final start = target - 15;
      progress = ((current - start) / (target - start)).clamp(0.0, 1.0);
    }

    final targetDisplay = usesImperialUnits
        ? '${UnitCalc.kgToLbs(target).toStringAsFixed(0)} ${S.of(context).lbsLabel}'
        : '${target.toStringAsFixed(0)} ${S.of(context).kgLabel}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).targetLabel(targetDisplay),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              S.of(context).weightProgressPercentLabel(
                  (progress * 100).toStringAsFixed(0)),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color:
                        colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor:
                  colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, UserEntity user,
      bool usesImperialUnits, ColorScheme colorScheme) {
    final shouldShowTargetDate =
        user.goal != UserWeightGoalEntity.maintainWeight;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        children: [
          _buildTappableRow(
            context: context,
            icon: Icons.flag_rounded,
            iconColor: colorScheme.tertiary,
            title: S.of(context).goalLabel,
            subtitle: user.goal.getName(context),
            onTap: () => _showSetGoalDialog(context, user),
          ),
          _buildDivider(colorScheme),
          _buildTappableRow(
            context: context,
            icon: Icons.scale_rounded,
            iconColor: colorScheme.secondary,
            title: S.of(context).weightLabel,
            subtitle:
                '${_profileBloc.getDisplayWeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}',
            onTap: () => _showSetWeightDialog(context, user, usesImperialUnits),
          ),
          if (user.targetWeightKG != null) ...[
            _buildDivider(colorScheme),
            _buildTappableRow(
              context: context,
              icon: Icons.gps_fixed_rounded,
              iconColor: colorScheme.primary,
              title: S.of(context).targetWeightLabel,
              subtitle:
                  '${usesImperialUnits ? UnitCalc.kgToLbs(user.targetWeightKG!).toStringAsFixed(0) : user.targetWeightKG!.toStringAsFixed(0)} ${usesImperialUnits ? S.of(context).lbsLabel : S.of(context).kgLabel}',
              onTap: () =>
                  _showSetTargetWeightDialog(context, user, usesImperialUnits),
            ),
          ],
          if (shouldShowTargetDate) ...[
            _buildDivider(colorScheme),
            _buildTappableRow(
              context: context,
              icon: Icons.calendar_month_rounded,
              iconColor: colorScheme.tertiary,
              title: S.of(context).targetDateLabel,
              subtitle: _getTargetDateDisplayLabel(context, user),
              onTap: () => _showSetTargetDateDialog(
                context,
                user,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTargetDateDisplayLabel(BuildContext context, UserEntity user) {
    final targetDate = user.targetDateForWeightGoal;
    if (targetDate == null) {
      return S.of(context).targetDateHint;
    }
    return MaterialLocalizations.of(context).formatMediumDate(targetDate);
  }

  Widget _buildActivityCard(
      BuildContext context, UserEntity user, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: _buildTappableRow(
        context: context,
        icon: Icons.directions_walk_outlined,
        iconColor: colorScheme.secondary,
        title: S.of(context).activityLabel,
        subtitle: user.pal.getName(context),
        onTap: () => _showSetPALCategoryDialog(context, user),
      ),
    );
  }

  Widget _buildBodyInfoCard(BuildContext context, UserEntity user,
      bool usesImperialUnits, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        children: [
          _buildTappableRow(
            context: context,
            icon: Icons.height_outlined,
            iconColor: colorScheme.tertiary,
            title: S.of(context).heightLabel,
            subtitle:
                '${_profileBloc.getDisplayHeight(user, usesImperialUnits)} ${usesImperialUnits ? S.of(context).ftLabel : S.of(context).cmLabel}',
            onTap: () => _showSetHeightDialog(context, user, usesImperialUnits),
          ),
          _buildDivider(colorScheme),
          _buildTappableRow(
            context: context,
            icon: Icons.cake_outlined,
            iconColor: colorScheme.error,
            title: S.of(context).ageLabel,
            subtitle: S.of(context).yearsLabel(user.age),
            onTap: () => _showSetBirthdayDialog(context, user),
          ),
          _buildDivider(colorScheme),
          _buildTappableRow(
            context: context,
            icon: user.gender.getIcon(),
            iconColor: colorScheme.secondary,
            title: S.of(context).genderLabel,
            subtitle: user.gender.getName(context),
            onTap: () => _showSetGenderDialog(context, user),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 62,
      endIndent: 16,
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Color _getBmiColor(BuildContext context, UserNutritionalStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case UserNutritionalStatus.normalWeight:
        return colorScheme.primary;
      case UserNutritionalStatus.underWeight:
        return Colors.orange;
      default:
        return colorScheme.error;
    }
  }

  Future<void> _showSetPALCategoryDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedPalCategory = await showDialog<UserPALEntity>(
        context: context,
        builder: (BuildContext context) => const SetPALCategoryDialog());
    if (selectedPalCategory != null) {
      userEntity.pal = selectedPalCategory;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetGoalDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedGoal = await showDialog<UserWeightGoalEntity>(
        context: context,
        builder: (BuildContext context) => const SetWeightGoalDialog());
    if (selectedGoal != null) {
      userEntity.goal = selectedGoal;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetHeightDialog(BuildContext context, UserEntity userEntity,
      bool usesImperialUnits) async {
    final selectedHeight = await showDialog<double>(
        context: context,
        builder: (context) => SetHeightDialog(
              userHeight: usesImperialUnits
                  ? UnitCalc.cmToFeet(userEntity.heightCM)
                  : userEntity.heightCM,
              usesImperialUnits: usesImperialUnits,
            ));
    if (selectedHeight != null) {
      if (usesImperialUnits) {
        userEntity.heightCM = UnitCalc.feetToCm(selectedHeight);
      } else {
        userEntity.heightCM = selectedHeight;
      }
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetWeightDialog(BuildContext context, UserEntity userEntity,
      bool usesImperialSystem) async {
    final selectedWeight = await showDialog<double>(
        context: context,
        builder: (context) => SetWeightDialog(
              userWeight: usesImperialSystem
                  ? UnitCalc.kgToLbs(userEntity.weightKG)
                  : userEntity.weightKG,
              usesImperialUnits: usesImperialSystem,
            ));
    if (selectedWeight != null) {
      if (usesImperialSystem) {
        userEntity.weightKG = UnitCalc.lbsToKg(selectedWeight);
      } else {
        userEntity.weightKG = selectedWeight;
      }
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetBirthdayDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedDate = await showDatePicker(
        context: context,
        initialDate: userEntity.birthday,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (selectedDate != null) {
      userEntity.birthday = selectedDate;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetGenderDialog(
      BuildContext context, UserEntity userEntity) async {
    final selectedGender = await showDialog<UserGenderEntity>(
        context: context,
        builder: (BuildContext context) => const SetGenderDialog());
    if (selectedGender != null) {
      userEntity.gender = selectedGender;
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetTargetWeightDialog(BuildContext context,
      UserEntity userEntity, bool usesImperialUnits) async {
    final currentTargetDisplay = userEntity.targetWeightKG != null
        ? (usesImperialUnits
            ? UnitCalc.kgToLbs(userEntity.targetWeightKG!)
            : userEntity.targetWeightKG!)
        : null;
    /* final currentWeightDisplay = usesImperialUnits
        ? UnitCalc.kgToLbs(userEntity.weightKG)
        : userEntity.weightKG;*/

    final selectedTarget = await showDialog<double>(
        context: context,
        builder: (context) => SetTargetWeightDialog(
              currentWeight: currentTargetDisplay!,
              currentTargetWeight: currentTargetDisplay,
              usesImperialUnits: usesImperialUnits,
            ));

    if (selectedTarget != null) {
      if (usesImperialUnits) {
        userEntity.targetWeightKG = UnitCalc.lbsToKg(selectedTarget);
      } else {
        userEntity.targetWeightKG = selectedTarget;
      }
      _profileBloc.updateUser(userEntity);
    }
  }

  Future<void> _showSetTargetDateDialog(
      BuildContext context, UserEntity userEntity) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: userEntity.targetDateForWeightGoal ??
          now.add(const Duration(days: 84)),
      firstDate: now.add(const Duration(days: 14)),
      lastDate: now.add(const Duration(days: 730)),
    );

    if (selectedDate != null) {
      userEntity.targetDateForWeightGoal = selectedDate;
      userEntity.weightChangeRateKgPerWeek = null;
      _profileBloc.updateUser(userEntity);
    }
  }
}

class _AnimatedProfileCard extends StatelessWidget {
  final AnimationController animController;
  final int index;
  final Widget child;

  const _AnimatedProfileCard({
    required this.animController,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
