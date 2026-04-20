import 'package:flutter/material.dart';

class RecentSeparator extends StatelessWidget {
  final String label;

  const RecentSeparator({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 16),
         /* Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: 1,
            ),
          ),*/
        ],
      ),
    );
  }
}

