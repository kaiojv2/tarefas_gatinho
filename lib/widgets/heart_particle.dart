import 'dart:math';
import 'package:flutter/material.dart';

class HeartParticle extends StatefulWidget {
  final double baseLeft;
  final double baseBottom;
  final double baseTopOffset; // NOVA variável para ajustar o eixo Y inicial
  final VoidCallback onComplete;

  const HeartParticle({
    super.key,
    required this.baseLeft,
    required this.baseBottom,
    this.baseTopOffset = 120, // default 0 para manter compatibilidade
    required this.onComplete,
  });

  @override
  State<HeartParticle> createState() => _HeartParticleState();
}

class _HeartParticleState extends State<HeartParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionY;
  late final Animation<double> _positionX;
  late final Animation<double> _opacity;
  late final double _startX;
  late final double _size;
  late final double _horizontalAmplitude;

  @override
  void initState() {
    super.initState();
    final rand = Random();

    _startX = widget.baseLeft;
    _size = rand.nextDouble() * 20 + 20;

    _horizontalAmplitude =
        (rand.nextDouble() * 30 + 20) * (rand.nextBool() ? 1 : -1);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _positionY = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _positionX = Tween<double>(
      begin: 0,
      end: _horizontalAmplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: _startX + _positionX.value,
          top: widget.baseBottom - _positionY.value - widget.baseTopOffset,
          child: Opacity(
            opacity: _opacity.value,
            child: Icon(Icons.favorite, color: Colors.pinkAccent, size: _size),
          ),
        );
      },
    );
  }
}
