import 'package:flutter/material.dart';

class HighlightButton extends StatelessWidget {
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final bool buttonActive;

  const HighlightButton(
      {super.key,
      required this.buttonLabel,
      required this.onButtonPressed,
      required this.buttonActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: buttonActive ? onButtonPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            disabledBackgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            disabledForegroundColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              buttonActive
                  ? Icons.arrow_forward_rounded
                  : Icons.lock_outline_rounded,
              key: ValueKey(buttonActive),
            ),
          ),
          label: Text(
            buttonLabel,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
