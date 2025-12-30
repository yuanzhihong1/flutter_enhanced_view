import 'dart:math';

import 'package:flutter/cupertino.dart';

/// 炫彩动态背景组件
///
/// 创建一个带有渐变背景和移动光点的动态背景效果
class DazzlingBackground extends StatefulWidget {
  /// 渐变背景颜色列表，至少需要2个颜色
  final List<Color> gradientColors;

  /// 基础背景颜色（渐变层下方的纯色背景）
  final Color backgroundColor;

  /// 光点数量，默认为5个
  final int dotCount;

  /// 光点移动速度，值越大移动越快，默认为2.2
  final double speed;

  /// 光点颜色，默认为半透明的紫色
  final Color? dotColor;

  /// 光点最小尺寸，默认为150
  final double minDotSize;

  /// 光点最大尺寸，默认为300
  final double maxDotSize;

  /// 光点模糊半径，默认为50
  final double blurRadius;

  /// 动画帧率（每秒帧数），默认为60fps
  final int frameRate;

  /// 渐变方向，默认为左上到右下
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  /// 子组件
  final Widget? child;

  const DazzlingBackground({
    super.key,
    required this.gradientColors,
    this.backgroundColor = const Color(0xFF0A0A0F),
    this.dotCount = 5,
    this.speed = 2.2,
    this.dotColor,
    this.minDotSize = 150,
    this.maxDotSize = 300,
    this.blurRadius = 50,
    this.frameRate = 60,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.child,
  })  : assert(gradientColors.length >= 2, '至少需要提供2个渐变颜色'),
        assert(dotCount > 0, '光点数量必须大于0'),
        assert(speed > 0, '速度必须大于0'),
        assert(minDotSize > 0 && maxDotSize > minDotSize,
            '尺寸范围无效，maxDotSize必须大于minDotSize'),
        assert(frameRate > 0 && frameRate <= 120, '帧率必须在1-120之间');

  /// 快速创建一个蓝色主题的背景
  const DazzlingBackground.blue({
    super.key,
    this.dotCount = 5,
    this.speed = 2.2,
    this.child,
  })  : gradientColors = const [
          Color(0xFF001848),
          Color(0xFF301860),
          Color(0xFF483090),
        ],
        backgroundColor = const Color(0xFF0A0A0F),
        dotColor = const Color(0x6633A1FF),
        minDotSize = 150,
        maxDotSize = 300,
        blurRadius = 50,
        frameRate = 60,
        gradientBegin = Alignment.topLeft,
        gradientEnd = Alignment.bottomRight;

  /// 快速创建一个紫色主题的背景
  const DazzlingBackground.purple({
    super.key,
    this.dotCount = 5,
    this.speed = 2.2,
    this.child,
  })  : gradientColors = const [
          Color(0xFF3A1C71),
          Color(0xFFD76D77),
          Color(0xFFFFAF7B),
        ],
        backgroundColor = const Color(0xFF0A0A0F),
        dotColor = const Color(0x66FF6BCB),
        minDotSize = 150,
        maxDotSize = 300,
        blurRadius = 50,
        frameRate = 60,
        gradientBegin = Alignment.topLeft,
        gradientEnd = Alignment.bottomRight;

  @override
  State<StatefulWidget> createState() => _DazzlingBackgroundState();
}

class _DazzlingBackgroundState extends State<DazzlingBackground>
    with SingleTickerProviderStateMixin {
  /// 存储所有光点实例
  final List<_Dot> _dots = [];

  /// 动画控制器
  late final AnimationController _controller;

  /// 记录上次的组件尺寸
  Size _lastSize = Size.zero;

  /// 随机数生成器
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器，根据帧率计算每帧持续时间
    final frameDuration = Duration(milliseconds: 1000 ~/ widget.frameRate);
    _controller = AnimationController(
      vsync: this,
      duration: frameDuration,
    )
      ..addListener(_tick) // 添加动画监听
      ..repeat(); // 循环播放动画
  }

  @override
  void dispose() {
    // 释放动画控制器资源
    _controller.dispose();
    super.dispose();
  }

  /// 初始化光点
  /// [size] 组件尺寸
  void _initDots(Size size) {
    _dots.clear();

    for (int i = 0; i < widget.dotCount; i++) {
      // 随机生成光点位置
      final position = Offset(
        _rand.nextDouble() * size.width,
        _rand.nextDouble() * size.height,
      );

      // 随机生成目标位置
      final target = Offset(
        _rand.nextDouble() * size.width,
        _rand.nextDouble() * size.height,
      );

      // 随机生成光点尺寸
      final dotSize = widget.minDotSize +
          _rand.nextDouble() * (widget.maxDotSize - widget.minDotSize);

      _dots.add(_Dot(
        position: position,
        target: target,
        dotSize: dotSize,
      ));
    }
  }

  /// 动画每帧的回调函数
  void _tick() {
    // 如果尺寸未初始化，则跳过
    if (_lastSize == Size.zero) return;

    for (int i = 0; i < _dots.length; i++) {
      final dot = _dots[i];
      final dx = dot.target.dx - dot.position.dx;
      final dy = dot.target.dy - dot.position.dy;
      final distance = sqrt(dx * dx + dy * dy);

      // 如果光点接近目标位置，则重新设置目标位置
      if (distance < widget.speed) {
        dot.target = Offset(
          _rand.nextDouble() * _lastSize.width,
          _rand.nextDouble() * _lastSize.height,
        );
      } else {
        // 否则向目标位置移动
        dot.position = Offset(
          dot.position.dx + dx / distance * widget.speed,
          dot.position.dy + dy / distance * widget.speed,
        );
      }
    }

    // 触发重绘
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // 当尺寸变化时重新初始化光点
        if (size != _lastSize && size.width > 0 && size.height > 0) {
          _lastSize = size;
          _initDots(size);
        }

        return CustomPaint(
          painter: _DazzlingPainter(
            dots: _dots,
            gradientColors: widget.gradientColors,
            backgroundColor: widget.backgroundColor,
            dotColor: widget.dotColor ??
                CupertinoColors.systemPurple
                    .resolveFrom(context)
                    .withAlpha((255.0 * 0.4).round()),
            blurRadius: widget.blurRadius,
            gradientBegin: widget.gradientBegin,
            gradientEnd: widget.gradientEnd,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 自定义绘画器，负责绘制背景和光点
class _DazzlingPainter extends CustomPainter {
  /// 光点列表
  final List<_Dot> dots;

  /// 渐变颜色列表
  final List<Color> gradientColors;

  /// 基础背景颜色
  final Color backgroundColor;

  /// 光点颜色
  final Color dotColor;

  /// 模糊半径
  final double blurRadius;

  /// 渐变开始和结束位置
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;

  _DazzlingPainter({
    required this.dots,
    required this.gradientColors,
    required this.backgroundColor,
    required this.dotColor,
    required this.blurRadius,
    required this.gradientBegin,
    required this.gradientEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 绘制基础背景
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(rect, bgPaint);

    // 绘制渐变背景
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: gradientBegin,
        end: gradientEnd,
        colors: gradientColors,
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // 设置光点画笔属性
    final dotPaint = Paint()
      ..color = dotColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    // 绘制所有光点
    for (final dot in dots) {
      canvas.drawCircle(dot.position, dot.dotSize / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 光点数据类
class _Dot {
  /// 当前位置
  Offset position;

  /// 目标位置
  Offset target;

  /// 光点尺寸
  final double dotSize;

  _Dot({
    required this.position,
    required this.target,
    required this.dotSize,
  });
}
