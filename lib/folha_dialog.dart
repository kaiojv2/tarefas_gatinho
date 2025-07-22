import 'package:flutter/material.dart';

class FolhaDialog extends StatelessWidget {
  final String? titulo; // título opcional
  final String texto;

  const FolhaDialog({super.key, this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 16,
      height: 1.4,
      color: Colors.brown,
      fontFamily: 'ComicNeue',
    );

    final displayTitle = (titulo?.isNotEmpty == true)
        ? '📋 ${titulo!}'
        : '📝 Sem título';

    return Dialog(
      backgroundColor: const Color(0xFFFFF8E1), // cor de papel
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown[700],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final span = TextSpan(text: texto, style: textStyle);
                  final tp = TextPainter(
                    text: span,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    maxLines: null,
                  );
                  tp.layout(maxWidth: constraints.maxWidth);
                  final textHeight = tp.height;

                  return SingleChildScrollView(
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(constraints.maxWidth, textHeight),
                          painter: NotebookLinesPainter(
                            textHeight: textHeight,
                            lineHeight: tp.preferredLineHeight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            texto,
                            style: textStyle.copyWith(color: Colors.brown[900]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Fechar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotebookLinesPainter extends CustomPainter {
  final double textHeight;
  final double lineHeight;

  NotebookLinesPainter({required this.textHeight, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.3)
      ..strokeWidth = 1;

    final count = (textHeight / lineHeight).ceil();

    for (int i = 0; i < count; i++) {
      // Ajuste a linha para ficar um pouco abaixo da linha de base do texto
      final y = lineHeight * (i + 1) - 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
