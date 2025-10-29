// lib/view/widget/custom_input.dart
import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.controller,
    required this.hint,
    this.minLines,
    this.maxLines,
    this.suffixIcon,
    this.suffixOnTap,
    this.readOnly = false, // Add readOnly parameter
    this.onTap,           // Add onTap parameter
    this.textInputAction, // Add textInputAction parameter
  });
  final TextEditingController controller;
  final String hint;
  final int? minLines;
  final int? maxLines;
  final String? suffixIcon;
  final void Function()? suffixOnTap;
  final bool readOnly;         // Add readOnly field
  final VoidCallback? onTap;   // Add onTap field
  final TextInputAction? textInputAction; // Add textInputAction field


  @override
  Widget build(BuildContext context) {
    return TextFormField( // Use TextFormField directly or ensure your custom implementation passes these down
      controller: controller,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: AppColor.textBody,
      ),
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly, // Use readOnly
      onTap: onTap,       // Use onTap
      textInputAction: textInputAction, // Use textInputAction
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: suffixOnTap, // This remains for the icon tap
                child: UnconstrainedBox(
                  alignment: const Alignment(-0.5, 0),
                  child: ImageIcon(
                    AssetImage(suffixIcon!),
                    size: 24,
                    color: AppColor.primary,
                  ),
                ),
              ),
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.all(20),
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: AppColor.textBody,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColor.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColor.primary, width: 2),
        ),
         // Added focusedBorder for consistency
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColor.primary.withOpacity(0.8), width: 2),
        ),
      ),
    );
  }
}
