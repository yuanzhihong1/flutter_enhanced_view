import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// iOS风格毛玻璃背景组件
///
/// 仿照iOS的UIVisualEffectView实现，提供不同强度的毛玻璃效果
/// 适用于卡片、对话框、底部导航栏等需要背景模糊的场景
class CupertinoMaterialBackground extends StatelessWidget {
  /// 创建毛玻璃背景组件
  ///
  /// [materialStyle] - 毛玻璃效果强度，默认为超薄材质
  /// [child] - 子组件，默认为空组件
  /// [borderRadius] - 圆角边框，默认为20px圆角
  /// [clipBehavior] - 裁剪行为，默认为抗锯齿裁剪
  const CupertinoMaterialBackground({
    super.key,
    this.materialStyle = MaterialStyle.ultraThinMaterial,
    this.child = const SizedBox.shrink(),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.clipBehavior = Clip.antiAlias,
  });

  /// 毛玻璃效果强度
  final MaterialStyle materialStyle;

  /// 子组件
  final Widget child;

  /// 圆角边框几何形状
  final BorderRadiusGeometry borderRadius;

  /// 裁剪行为
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的iOS系统背景色
    final Color systemBackgroundColor =
        CupertinoColors.tertiarySystemBackground.resolveFrom(context);

    // 根据材质样式计算模糊强度和覆盖颜色
    final (double blurSigma, Color overlayColor) = _calculateMaterialProperties(
      materialStyle,
      systemBackgroundColor,
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey
                .resolveFrom(context)
                .withAlpha((255.0 * 0.2).round()),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
        borderRadius: borderRadius,
      ),
      child: ClipRSuperellipse(
        clipBehavior: clipBehavior,
        borderRadius: borderRadius,
        child: _buildBlurContent(blurSigma, overlayColor),
      ),
    );
  }

  /// 构建毛玻璃内容
  Widget _buildBlurContent(double blurSigma, Color overlayColor) {
    return Stack(
      children: [
        // 背景模糊层
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: const SizedBox.expand(),
        ),
        // 颜色覆盖层（控制透明度）
        Container(color: overlayColor),
        // 子组件层
        child,
      ],
    );
  }

  /// 根据材质样式计算模糊参数
  (double blurSigma, Color overlayColor) _calculateMaterialProperties(
    MaterialStyle style,
    Color systemBackgroundColor,
  ) {
    switch (style) {
      case MaterialStyle.ultraThinMaterial:
        return (10.0, systemBackgroundColor.withAlpha(76)); // 30% 透明度
      case MaterialStyle.thinMaterial:
        return (15.0, systemBackgroundColor.withAlpha(128)); // 50% 透明度
      case MaterialStyle.regularMaterial:
        return (20.0, systemBackgroundColor.withAlpha(179)); // 70% 透明度
      case MaterialStyle.thickMaterial:
        return (25.0, systemBackgroundColor.withAlpha(204)); // 80% 透明度
      case MaterialStyle.ultraThickMaterial:
        return (30.0, systemBackgroundColor.withAlpha(230)); // 90% 透明度
    }
  }
}

/// 毛玻璃材质强度枚举
///
/// 对应Apple Design System中的材质效果级别
enum MaterialStyle {
  /// 超薄材质 - 最高透明度，最轻的模糊效果
  /// 适用于悬浮按钮、小范围强调等场景
  ultraThinMaterial,

  /// 薄材质 - 较高透明度，轻度模糊
  /// 适用于工具栏、小卡片等场景
  thinMaterial,

  /// 常规材质 - 中等透明度，标准模糊
  /// 适用于对话框、中等大小卡片等场景
  regularMaterial,

  /// 厚材质 - 较低透明度，重度模糊
  /// 适用于底部导航栏、大卡片等场景
  thickMaterial,

  /// 超厚材质 - 最低透明度（最不透明），最重度模糊
  /// 适用于侧边栏、全屏模糊等场景
  ultraThickMaterial,
}
