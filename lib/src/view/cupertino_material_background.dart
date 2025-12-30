import 'dart:ui';

import 'package:flutter/cupertino.dart';

///高仿iOS 毛玻璃背景
class CupertinoMaterialBackground extends StatelessWidget {
  const CupertinoMaterialBackground({
    super.key,
    this.materialStyle = MaterialStyle.ultraThinMaterial,
    this.child = const SizedBox.shrink(),
    this.borderRadius = const BorderRadius.all(Radius.circular(50)),
    this.clipBehavior = Clip.antiAlias,
  });

  final MaterialStyle materialStyle;
  final BorderRadiusGeometry borderRadius;
  final Clip clipBehavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double blurSigma;
    Color overlayColor;
    Color systemBackgroundColor =
        CupertinoColors.tertiarySystemBackground.resolveFrom(context);

    switch (materialStyle) {
      case MaterialStyle.ultraThinMaterial:
        blurSigma = 10;
        overlayColor = systemBackgroundColor.withAlpha((255.0 * 0.3).round());
        break;
      case MaterialStyle.thinMaterial:
        blurSigma = 15;
        overlayColor = systemBackgroundColor.withAlpha((255.0 * 0.5).round());
        break;
      case MaterialStyle.regularMaterial:
        blurSigma = 20;
        overlayColor = systemBackgroundColor.withAlpha((255.0 * 0.7).round());
        break;
      case MaterialStyle.thickMaterial:
        blurSigma = 25;
        overlayColor = systemBackgroundColor.withAlpha((255.0 * 0.8).round());
        break;
      case MaterialStyle.ultraThickMaterial:
        blurSigma = 30;
        overlayColor = systemBackgroundColor.withAlpha((255.0 * 0.9).round());
        break;
    }

    return ClipRSuperellipse(
      clipBehavior: clipBehavior,
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(color: overlayColor, child: child),
      ),
    );
  }
}

enum MaterialStyle {
  ultraThinMaterial, //最高透明度
  thinMaterial, //较高透明度
  regularMaterial, //中等透明度
  thickMaterial, //较低透明度
  ultraThickMaterial, //最低透明度（最不透明）
}
