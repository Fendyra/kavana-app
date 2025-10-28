import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kavana_app/common/app_color.dart';

class ResponseFailed extends StatelessWidget {
  const ResponseFailed({
    super.key,
    required this.message,
    this.margin = const EdgeInsets.all(0),
  });
  final String message;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColor.textBody,
              ),
              const Gap(20),
              Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColor.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
