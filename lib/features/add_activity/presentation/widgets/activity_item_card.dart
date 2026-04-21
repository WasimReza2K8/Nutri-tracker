import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/physical_activity_entity.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/activity_detail/activity_detail_screen.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ActivityItemCard extends StatelessWidget {
  final PhysicalActivityEntity physicalActivityEntity;
  final DateTime day;

  const ActivityItemCard(
      {super.key, required this.physicalActivityEntity, required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(physicalActivityEntity.displayIcon,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        physicalActivityEntity.getName(context),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      AutoSizeText(
                        physicalActivityEntity.getDescription(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              physicalActivityEntity.mets >= 8
                                  ? Icons.local_fire_department
                                  : physicalActivityEntity.mets >= 5
                                      ? Icons.local_fire_department_outlined
                                      : Icons.whatshot_outlined,
                              size: 14,
                              color: physicalActivityEntity.mets >= 8
                                  ? Colors.red
                                  : physicalActivityEntity.mets >= 5
                                      ? Colors.orange
                                      : Colors.yellow[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              physicalActivityEntity.mets >= 8
                                  ? S.of(context).burnIntensityHighLabel
                                  : physicalActivityEntity.mets >= 5
                                      ? S.of(context).burnIntensityMediumLabel
                                      : S.of(context).burnIntensityLightLabel,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _onItemPressed(context),
                  icon: const Icon(Icons.add),
                  label: Text(S.of(context).addLabel),
                ),
              ],
            ),
          ),
        ),
        onTap: () => _onItemPressed(context),
      ),
    );
  }

  void _onItemPressed(BuildContext context) {
    Navigator.of(context).pushNamed(NavigationOptions.activityDetailRoute,
        arguments: ActivityDetailScreenArguments(physicalActivityEntity, day));
  }
}
