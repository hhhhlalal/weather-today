import 'package:flutter/material.dart';

class CloudyBackground extends StatelessWidget {
  final Widget child;
  const CloudyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _CloudyPainterWidget(),
        child,
      ],
    );
  }
}

class _CloudyPainterWidget extends StatelessWidget {
  const _CloudyPainterWidget();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CloudyPainter(),
        ),
      ),
    );
  }
}

class _CloudyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    // Vẽ vài đám mây mờ
    canvas.drawOval(Rect.fromLTWH(size.width * 0.12, size.height * 0.12, 160, 60), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.6, size.height * 0.2, 110, 40), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.65, 200, 60), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.65, 100, 35), paint);
    // Có thể thêm nhiều đám mây hơn ở các vị trí khác nhau cho đẹp
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
