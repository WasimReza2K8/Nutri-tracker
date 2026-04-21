import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MealItemCard extends StatefulWidget {
  final DateTime day;
  final AddMealType addMealType;
  final MealEntity mealEntity;
  final bool usesImperialUnits;
  final VoidCallback onAddPressed;
  final bool isLast;

  const MealItemCard(
      {super.key,
      required this.day,
      required this.mealEntity,
      required this.addMealType,
      required this.usesImperialUnits,
      required this.onAddPressed,
      this.isLast = false});

  @override
  State<MealItemCard> createState() => _MealItemCardState();
}

class _MealItemCardState extends State<MealItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAdded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onAddPressed() async {
    if (_isAdded) return;

    // Animate to tick
    await _animationController.forward();
    setState(() => _isAdded = true);

    // Call the add callback
    widget.onAddPressed();

    // Wait 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    // Animate back to plus
    await _animationController.reverse();
    setState(() => _isAdded = false);
  }

  @override
  Widget build(BuildContext context) {
    final kcal = _totalNutrient(widget.mealEntity.nutriments.energyKcal100);
    final protein = _totalNutrient(widget.mealEntity.nutriments.proteins100);
    final carbs = _totalNutrient(widget.mealEntity.nutriments.carbohydrates100);
    final fat = _totalNutrient(widget.mealEntity.nutriments.fat100);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 8, widget.isLast ? 28 : 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AutoSizeText.rich(
                        TextSpan(
                          text: widget.mealEntity.name ?? "?",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                          children: [
                            if ((widget.mealEntity.brands ?? '').isNotEmpty)
                              TextSpan(
                                text: ' ${widget.mealEntity.brands}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.75),
                                    ),
                              ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                        CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOut),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isAdded ? null : _onAddPressed,
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _isAdded
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.18)
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                              boxShadow: _isAdded
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeIn,
                              child: Icon(
                                _isAdded
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                key: ValueKey(_isAdded),
                                size: 22,
                                color: _isAdded
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.mealEntity.mealQuantity != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: MealValueUnitText(
                      value: _parsedMealQuantity,
                      meal: widget.mealEntity,
                      usesImperialUnits: widget.usesImperialUnits,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _NutrientPill(
                      label: 'kcal',
                      value: kcal,
                      textColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _NutrientPill(
                      label: S.of(context).proteinLabel,
                      value: protein,
                    ),
                    const SizedBox(width: 8),
                    _NutrientPill(
                      label: S.of(context).carbsLabel,
                      value: carbs,
                    ),
                    const SizedBox(width: 8),
                    _NutrientPill(
                      label: S.of(context).fatLabel,
                      value: fat,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () => _onItemPressed(context),
      ),
    );
  }

  double get _parsedMealQuantity =>
      double.tryParse(
          (widget.mealEntity.mealQuantity ?? '').replaceAll(',', '.')) ??
      100;

  String _totalNutrient(double? valuePer100) {
    if (valuePer100 == null) {
      return '-';
    }

    final hasQuantity = widget.mealEntity.mealQuantity != null;
    final quantity = hasQuantity ? _parsedMealQuantity : 100;
    final total = (valuePer100 / 100) * quantity;
    return total.toStringAsFixed(0);
  }

  void _onItemPressed(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
            widget.mealEntity,
            widget.addMealType.getIntakeType(),
            widget.day,
            widget.usesImperialUnits));
  }
}

class _NutrientPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;

  const _NutrientPill({
    required this.label,
    required this.value,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
