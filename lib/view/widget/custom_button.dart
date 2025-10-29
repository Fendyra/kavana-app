// lib/view/widget/custom_button.dart
import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

// Base class accepting nullable onPressed
class _CustomButton extends StatelessWidget {
  const _CustomButton({
    super.key,
    required this.onPressed, // Accepts null now
    required this.title,
    required this.color,
    this.titleColor = Colors.white,
  });
  final void Function()? onPressed; // Type is nullable
  final String title;
  final Color color;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed, // Pass the potentially null function
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        fixedSize: const WidgetStatePropertyAll(
          Size(double.infinity, 54),
        ),
        // Add overlay color only if onPressed is not null
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (onPressed == null) return Colors.transparent; // No overlay if disabled
            if (states.contains(WidgetState.pressed)) {
              return AppColor.secondary.withOpacity(0.5); // Example pressed overlay
            }
            return null; // Defer to default overlay otherwise
          },
        ),
        // Adjust background/foreground based on disabled state (onPressed == null)
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
             if (states.contains(WidgetState.disabled)) {
               // Use a greyed-out color when disabled
               return color.withOpacity(0.5);
             }
             return color; // Use normal color otherwise
           },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
         (Set<WidgetState> states) {
             if (states.contains(WidgetState.disabled)) {
               return titleColor.withOpacity(0.7); // Dim text color when disabled
             }
             return titleColor;
           },
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}


// Concrete Button Classes - Ensure constructors accept nullable onPressed
class ButtonPrimary extends _CustomButton {
  const ButtonPrimary({
    super.key,
    required void Function()? onPressed, // Accept nullable
    required super.title,
  }) : super(onPressed: onPressed, color: AppColor.primary); // Pass nullable to super
}

class ButtonSecondary extends _CustomButton {
  const ButtonSecondary({
    super.key,
    required void Function()? onPressed, // Accept nullable
    required super.title,
  }) : super(onPressed: onPressed, color: Colors.white, titleColor: AppColor.primary); // Pass nullable to super
}

class ButtonDelete extends _CustomButton {
  const ButtonDelete({
    super.key,
    required void Function()? onPressed, // Accept nullable
    required super.title,
  }) : super(onPressed: onPressed, color: AppColor.error); // Pass nullable to super
}