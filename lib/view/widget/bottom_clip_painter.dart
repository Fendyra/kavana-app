import 'package:flutter/material.dart';
import 'package:kavana_app/common/app_color.dart';

class BottomClipPainter extends StatelessWidget {
  const BottomClipPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(250, 450),
      painter: _ClipPainter(),
    );
  }
}

class _ClipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    paint.color = AppColor.primary;
    path = Path();
    path.lineTo(size.width * 0.68, size.height * 0.55);
    path.cubicTo(size.width * 1.06, size.height * 0.73, size.width,
        size.height * 0.9, size.width * 0.98, size.height);
    path.cubicTo(
        size.width * 0.98, size.height, 0, size.height, 0, size.height);
    path.cubicTo(0, size.height, 0, 0, 0, 0);
    path.cubicTo(size.width * 0.24, -0.02, size.width / 3, size.height * 0.14,
        size.width * 0.31, size.height / 5);
    path.cubicTo(size.width * 0.26, size.height * 0.42, size.width * 0.58,
        size.height / 2, size.width * 0.68, size.height * 0.55);
    path.cubicTo(size.width * 0.68, size.height * 0.55, size.width * 0.68,
        size.height * 0.55, size.width * 0.68, size.height * 0.55);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
