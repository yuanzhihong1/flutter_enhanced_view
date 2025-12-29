import 'package:flutter/cupertino.dart';

/// Cupertino风格的水平分隔线
class CupertinoDivider extends StatelessWidget {
  const CupertinoDivider({
    super.key,
    this.height = 0.5,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.thickness,
    this.margin,
    this.padding,
  });

  /// 分隔线高度（粗细）
  final double height;

  /// 分隔线颜色，默认为 CupertinoColors.separator
  final Color? color;

  /// 左侧缩进距离
  final double indent;

  /// 右侧缩进距离
  final double endIndent;

  /// 分隔线厚度（替代height，更语义化）
  final double? thickness;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final double actualThickness = thickness ?? height;
    final Color effectiveColor =
        color ?? CupertinoColors.separator.resolveFrom(context);

    Widget divider = Container(
      height: actualThickness,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: effectiveColor,
    );

    if (padding != null) {
      divider = Padding(
        padding: padding!,
        child: divider,
      );
    }

    if (margin != null) {
      divider = Padding(
        padding: margin!,
        child: divider,
      );
    }

    return divider;
  }
}

/// Cupertino风格的垂直分隔线
class CupertinoVerticalDivider extends StatelessWidget {
  const CupertinoVerticalDivider({
    super.key,
    this.width = 0.5,
    this.color,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.thickness,
    this.margin,
    this.padding,
  });

  /// 分隔线宽度（粗细）
  final double width;

  /// 分隔线颜色，默认为 CupertinoColors.separator
  final Color? color;

  /// 顶部缩进距离
  final double indent;

  /// 底部缩进距离
  final double endIndent;

  /// 分隔线厚度（替代width，更语义化）
  final double? thickness;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final double actualThickness = thickness ?? width;
    final Color effectiveColor =
        color ?? CupertinoColors.separator.resolveFrom(context);

    Widget divider = Container(
      width: actualThickness,
      margin: EdgeInsets.only(top: indent, bottom: endIndent),
      color: effectiveColor,
    );

    if (padding != null) {
      divider = Padding(
        padding: padding!,
        child: divider,
      );
    }

    if (margin != null) {
      divider = Padding(
        padding: margin!,
        child: divider,
      );
    }

    return divider;
  }
}
