import 'package:flutter/material.dart';
import 'package:nexstep/theme/main_theme.dart';

class NexStepButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final double? height;

  const NexStepButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 50,
      child: ElevatedButton(
        style: theme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.all(MainTheme.primaryColor),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
