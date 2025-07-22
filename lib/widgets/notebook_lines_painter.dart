import 'package:flutter/material.dart';

class NotebookLinesPainter extends CustomPainter {
  final double lineHeight;

  NotebookLinesPainter({this.lineHeight = 28});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.3)
      ..strokeWidth = 1;

    // Quantidade de linhas a desenhar, baseado na altura disponível e altura da linha
    final count = (size.height / lineHeight).ceil();

    for (int i = 0; i < count; i++) {
      final y = i * lineHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
