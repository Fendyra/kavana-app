import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

class InputAuth extends StatelessWidget {
  const InputAuth({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.hintColor,
    this.borderRadius = 20,
  });
  final TextEditingController controller;
  final String hint;
  final String icon;
  final bool obscureText;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? hintColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor ?? AppColor.primary,
        ),
        decoration: InputDecoration(
          fillColor: backgroundColor ?? AppColor.primary.withOpacity(0.1),
          filled: true,
          prefixIcon: UnconstrainedBox(
            alignment: const Alignment(0.3, 0),
            child: ImageIcon(
              AssetImage(icon),
              size: 24,
              color: iconColor ?? AppColor.primary,
            ),
          ),
          hintText: hint,
          hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: hintColor ?? AppColor.textBody,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
