import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

class InputAuth extends StatelessWidget {
  const InputAuth({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
  });
  final TextEditingController controller;
  final String hint;
  final String icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColor.primary,
        ),
        decoration: InputDecoration(
          fillColor: AppColor.primary.withOpacity(0.1),
          filled: true,
          prefixIcon: UnconstrainedBox(
            alignment: const Alignment(0.3, 0),
            child: ImageIcon(
              AssetImage(icon),
              size: 24,
              color: AppColor.primary,
            ),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: AppColor.textBody,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
