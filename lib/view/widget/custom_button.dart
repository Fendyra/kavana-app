import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

class ButtonPrimary extends _CustomButton {
  const ButtonPrimary({
    super.key,
    required super.onPressed,
    required super.title,
  }) : super(color: AppColor.primary);
}


class AuthButton extends _CustomButton {
  const AuthButton({
    super.key,
    required super.onPressed,
    required super.title,
  }) : super(color: const Color(0xFFFF5A80));
}

class ButtonSecondary extends _CustomButton {
  const ButtonSecondary({
    super.key,
    required super.onPressed,
    required super.title,
  }) : super(color: Colors.white, titleColor: AppColor.primary);
}

class ButtonDelete extends _CustomButton {
  const ButtonDelete({
    super.key,
    required super.onPressed,
    required super.title,
  }) : super(color: AppColor.error);
}

class _CustomButton extends StatelessWidget {
  const _CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.color,
    this.titleColor = Colors.white,
  });
  final void Function() onPressed;
  final String title;
  final Color color;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        fixedSize: const WidgetStatePropertyAll(
          Size(double.infinity, 54),
        ),
        overlayColor: const WidgetStatePropertyAll(
          AppColor.secondary,
        ),
        backgroundColor: WidgetStatePropertyAll(
          color,
        ),
        foregroundColor: WidgetStatePropertyAll(
          titleColor,
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
