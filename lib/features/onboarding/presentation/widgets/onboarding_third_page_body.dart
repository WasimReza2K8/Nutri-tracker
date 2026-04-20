import 'package:flutter/material.dart';
import 'package:opennutritracker/core/presentation/widgets/info_dialog.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_activity_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingThirdPageBody extends StatefulWidget {
  final Function(bool active, UserActivitySelectionEntity? selectedActivity)
      setButtonContent;
  final UserActivitySelectionEntity? initialActivity;

  const OnboardingThirdPageBody(
      {super.key, required this.setButtonContent, this.initialActivity});

  @override
  State<OnboardingThirdPageBody> createState() =>
      _OnboardingThirdPageBodyState();
}

class _OnboardingThirdPageBodyState extends State<OnboardingThirdPageBody> {
  bool _sedentarySelected = false;
  bool _lowActiveSelected = false;
  bool _activeSelected = false;
  bool _veryActiveSelected = false;

  @override
  void initState() {
    super.initState();
    switch (widget.initialActivity) {
      case UserActivitySelectionEntity.sedentary:
        _setSelectedChoiceChip(sedentary: true);
        break;
      case UserActivitySelectionEntity.lowActive:
        _setSelectedChoiceChip(lowActive: true);
        break;
      case UserActivitySelectionEntity.active:
        _setSelectedChoiceChip(active: true);
        break;
      case UserActivitySelectionEntity.veryActive:
        _setSelectedChoiceChip(veryActive: true);
        break;
      case null:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkCorrectInput();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).onboardingStepActivity,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).activityLabel,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  S.of(context).onboardingActivityQuestionSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                _buildActivityOption(
                  context,
                  selected: _sedentarySelected,
                  label: S.of(context).palSedentaryLabel,
                  description: S.of(context).palSedentaryDescriptionLabel,
                  icon: Icons.weekend_rounded,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(sedentary: true);
                      checkCorrectInput();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildActivityOption(
                  context,
                  selected: _lowActiveSelected,
                  label: S.of(context).palLowLActiveLabel,
                  description: S.of(context).palLowActiveDescriptionLabel,
                  icon: Icons.directions_walk_rounded,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(lowActive: true);
                      checkCorrectInput();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildActivityOption(
                  context,
                  selected: _activeSelected,
                  label: S.of(context).palActiveLabel,
                  description: S.of(context).palActiveDescriptionLabel,
                  icon: Icons.directions_run_rounded,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(active: true);
                      checkCorrectInput();
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildActivityOption(
                  context,
                  selected: _veryActiveSelected,
                  label: S.of(context).palVeryActiveLabel,
                  description: S.of(context).palVeryActiveDescriptionLabel,
                  icon: Icons.fitness_center_rounded,
                  onTap: () {
                    setState(() {
                      _setSelectedChoiceChip(veryActive: true);
                      checkCorrectInput();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOption(
    BuildContext context, {
    required bool selected,
    required String label,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          )),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => InfoDialog(
                    title: label,
                    body: description,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _setSelectedChoiceChip(
      {sedentary = false,
      lowActive = false,
      active = false,
      veryActive = false}) {
    _sedentarySelected = sedentary;
    _lowActiveSelected = lowActive;
    _activeSelected = active;
    _veryActiveSelected = veryActive;
  }

  void checkCorrectInput() {
    UserActivitySelectionEntity? selectedActivity;
    if (_sedentarySelected) {
      selectedActivity = UserActivitySelectionEntity.sedentary;
    } else if (_lowActiveSelected) {
      selectedActivity = UserActivitySelectionEntity.lowActive;
    } else if (_activeSelected) {
      selectedActivity = UserActivitySelectionEntity.active;
    } else if (_veryActiveSelected) {
      selectedActivity = UserActivitySelectionEntity.veryActive;
    }

    if (selectedActivity != null) {
      widget.setButtonContent(true, selectedActivity);
    } else {
      widget.setButtonContent(false, null);
    }
  }
}
