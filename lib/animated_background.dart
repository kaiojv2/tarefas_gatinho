import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final double height; // altura disponível para a animação
  final Duration stepDuration;

  const AnimatedBackground({
    super.key,
    required this.height,
    this.stepDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  final List<_PawPrint> _pawPrints = [];
  late Timer _timer;
  double _lastOffset = 0;
  bool _left = true;

  static const double pawPrintSize = 28; // tamanho do ícone

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(widget.stepDuration, (_) {
      setState(() {
        _pawPrints.add(
          _PawPrint(
            x: _left ? 100 : 140,
            offsetFromBottom: _lastOffset,
            rotation: _left ? -0.2 : 0.2,
          ),
        );

        _lastOffset += 50;
        _left = !_left;

        // Reset quando ultrapassa a altura da tela + o tamanho da pegada (para sumir completamente)
        if (_lastOffset >= widget.height + pawPrintSize) {
          _pawPrints.clear();
          _lastOffset = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _pawPrints
          .map(
            (paw) => Positioned(
              left: paw.x,
              bottom: paw.offsetFromBottom,
              child: Transform.rotate(
                angle: paw.rotation,
                child: Icon(
                  Icons.pets,
                  color: Colors.black.withOpacity(0.15),
                  size: pawPrintSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PawPrint {
  final double x;
  final double offsetFromBottom;
  final double rotation;

  _PawPrint({
    required this.x,
    required this.offsetFromBottom,
    required this.rotation,
  });
}
