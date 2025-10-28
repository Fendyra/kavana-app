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
  });
  final TextEditingController controller;
  final String hint;
  final int? minLines;
  final int? maxLines;
  final String? suffixIcon;
  final void Function()? suffixOnTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: AppColor.textBody,
      ),
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: suffixOnTap,
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
      ),
    );
  }
}
