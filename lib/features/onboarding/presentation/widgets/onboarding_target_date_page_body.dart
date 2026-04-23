import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingTargetDatePageBody extends StatefulWidget {
  final UserGoalSelectionEntity goal;
  final double currentWeightKG;
  final double? targetWeightKG;
  final bool usesImperialUnits;
  final DateTime? initialTargetDate;
  final Function(bool active, DateTime? targetDate) setButtonContent;

  const OnboardingTargetDatePageBody({
    super.key,
    required this.goal,
    required this.currentWeightKG,
    this.targetWeightKG,
    required this.usesImperialUnits,
    this.initialTargetDate,
    required this.setButtonContent,
  });

  @override
  State<OnboardingTargetDatePageBody> createState() =>
      _OnboardingTargetDatePageBodyState();
}

class _OnboardingTargetDatePageBodyState
    extends State<OnboardingTargetDatePageBody> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialTargetDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyParent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 34,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.of(context).onboardingStepTargetDate,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).targetDateSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          _buildDatePickerCard(context, colorScheme),
          if (_selectedDate != null) ...[
            const SizedBox(height: 16),
            _buildSummaryCard(context, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePickerCard(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _selectedDate != null
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: _selectedDate != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.edit_calendar_rounded,
              size: 48,
              color: _selectedDate != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedDate != null
                  ? DateFormat.yMMMd().format(_selectedDate!)
                  : S.of(context).targetDateHint,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: _selectedDate != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _selectedDate != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 4),
              Text(
                S.of(context).targetDateWeeksAway(
                      _weeksUntilTarget.toStringAsFixed(0),
                    ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ColorScheme colorScheme) {
    final weightDiff = (widget.targetWeightKG ?? widget.currentWeightKG) -
        widget.currentWeightKG;
    final absDiff = weightDiff.abs();
    final weeksUntil = _weeksUntilTarget;
    final impliedRateKg = weeksUntil > 0 ? (absDiff / weeksUntil) : 0.0;
    final impliedRateDisplay = widget.usesImperialUnits
        ? '${(impliedRateKg * 2.20462).toStringAsFixed(1)} lbs'
        : '${impliedRateKg.toStringAsFixed(2)} kg';

    final isTooFast = impliedRateKg > 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTooFast
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTooFast
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTooFast ? Icons.warning_amber_rounded : Icons.speed_rounded,
            color: isTooFast ? colorScheme.error : colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).targetDateImpliedRate(impliedRateDisplay),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isTooFast ? colorScheme.error : colorScheme.primary,
                      ),
                ),
                if (isTooFast)
                  Text(
                    S.of(context).targetDateValidationTooSoon,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double get _weeksUntilTarget {
    if (_selectedDate == null) return 0;
    final days = _selectedDate!.difference(DateTime.now()).inDays;
    return days / 7.0;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 84)),
      firstDate: now.add(const Duration(days: 14)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _notifyParent();
    }
  }

  void _notifyParent() {
    widget.setButtonContent(_selectedDate != null, _selectedDate);
  }
}
