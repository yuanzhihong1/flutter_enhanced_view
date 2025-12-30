import 'dart:math';

import 'package:flutter/cupertino.dart';

class DazzlingBackground extends StatefulWidget {
  const DazzlingBackground({
    super.key,
    required this.gradientColors,
    required this.backgroundColor,
    this.dotCount = 5,
    this.speed = 2.2,
    this.blurRadius = 50,
    this.dotColor,
    this.child,
  });

  final List<Color> gradientColors;
  final Color backgroundColor;
  final int dotCount;
  final double speed;
  final double blurRadius;
  final Color? dotColor;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _DazzlingBackgroundState();
}

class _DazzlingBackgroundState extends State<DazzlingBackground>
    with SingleTickerProviderStateMixin {
  final List<_Dot> _dots = [];
  late final AnimationController _controller;
  Size _lastSize = Size.zero;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_tick)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initDots(Size size) {
    _dots.clear();
    for (int i = 0; i < widget.dotCount; i++) {
      final pos = Offset(
        _rand.nextDouble() * size.width,
        _rand.nextDouble() * size.height,
      );
      final target = Offset(
        _rand.nextDouble() * size.width,
        _rand.nextDouble() * size.height,
      );

      final dotSize = 200 + _rand.nextDouble() * 100;
      _dots.add(_Dot(position: pos, target: target, dotSize: dotSize));
    }
  }

  void _tick() {
    if (_lastSize == Size.zero) return;

    for (int i = 0; i < _dots.length; i++) {
      final dot = _dots[i];
      final dx = dot.target.dx - dot.position.dx;
      final dy = dot.target.dy - dot.position.dy;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < widget.speed) {
        dot.target = Offset(
          _rand.nextDouble() * _lastSize.width,
          _rand.nextDouble() * _lastSize.height,
        );
      } else {
        dot.position = Offset(
          dot.position.dx + dx / distance * widget.speed,
          dot.position.dy + dy / distance * widget.speed,
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize && size.width > 0 && size.height > 0) {
          _lastSize = size;
          _initDots(size);
        }

        return CustomPaint(
          painter: _DazzlingPainter(
            dots: _dots,
            backColors: widget.gradientColors,
            backgroundColor: widget.backgroundColor,
            blurRadius: widget.blurRadius,
            dotColor: widget.dotColor ??
                CupertinoColors.systemPurple
                    .resolveFrom(context)
                    .withAlpha((255.0 * 0.4).round()),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _DazzlingPainter extends CustomPainter {
  final List<_Dot> dots;
  final List<Color> backColors;
  final Color backgroundColor;
  final double blurRadius;
  final Color dotColor;

  _DazzlingPainter({
    required this.dots,
    required this.backColors,
    required this.backgroundColor,
    required this.blurRadius,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, bgPaint);

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: backColors,
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    final dotPaint = Paint()
      ..color = dotColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    for (final dot in dots) {
      canvas.drawCircle(dot.position, dot.dotSize / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Dot {
  Offset position;
  Offset target;
  final double dotSize;

  _Dot({required this.position, required this.target, required this.dotSize});
}
