import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opennutritracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';

class MealItemCard extends StatefulWidget {
  final DateTime day;
  final AddMealType addMealType;
  final MealEntity mealEntity;
  final bool usesImperialUnits;
  final VoidCallback onAddPressed;

  const MealItemCard(
      {super.key,
      required this.day,
      required this.mealEntity,
      required this.addMealType,
      required this.usesImperialUnits,
      required this.onAddPressed});

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        child: SizedBox(
          height: 100,
          child: Center(
              child: ListTile(
            leading: widget.mealEntity.thumbnailImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      cacheManager: locator<CacheManager>(),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageUrl: widget.mealEntity.thumbnailImageUrl ?? "",
                    ))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                        width: 60,
                        height: 60,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.restaurant_outlined)),
                  ),
            title: AutoSizeText.rich(
                TextSpan(
                    text: widget.mealEntity.name ?? "?",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                    children: [
                      TextSpan(
                          text: ' ${widget.mealEntity.brands ?? ""}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8))),
                    ]),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            subtitle: widget.mealEntity.mealQuantity != null
                ? MealValueUnitText(
                    value: double.parse(widget.mealEntity.mealQuantity ?? "0"),
                    meal: widget.mealEntity,
                    usesImperialUnits: widget.usesImperialUnits)
                : const SizedBox(),
            trailing: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.8).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
              ),
              child: IconButton(
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                icon: AnimatedIcon(
                  icon: AnimatedIcons.add_event,
                  progress: _animationController,
                  size: 24,
                ),
                onPressed: _isAdded ? null : _onAddPressed,
              ),
            ),
          )),
        ),
        onTap: () => _onItemPressed(context),
      ),
    );
  }

  void _onItemPressed(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(
            widget.mealEntity, widget.addMealType.getIntakeType(), widget.day, widget.usesImperialUnits));
  }
}
