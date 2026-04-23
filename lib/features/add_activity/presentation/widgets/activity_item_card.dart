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
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Icon(physicalActivityEntity.displayIcon,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 2),
                      AutoSizeText(
                        physicalActivityEntity.getDescription(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                                      : Icons.directions_walk,
                              size: 12,
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
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _onItemPressed(context),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
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
