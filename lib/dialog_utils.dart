import 'package:flutter/material.dart';
import 'folha_dialog.dart';

void mostrarFolhaDialog(
  BuildContext context, {
  String? titulo,
  required String texto,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Fechar",
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation1, animation2) {
      return FolhaDialog(titulo: titulo, texto: texto);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scaleIn = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

      final scaleOut = Tween<double>(begin: 1.0, end: 0.8).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );
      final fadeOut = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(secondaryAnimation);

      return FadeTransition(
        opacity: animation.status == AnimationStatus.reverse ? fadeOut : fadeIn,
        child: ScaleTransition(
          scale: animation.status == AnimationStatus.reverse
              ? scaleOut
              : scaleIn,
          child: child,
        ),
      );
    },
  );
}
