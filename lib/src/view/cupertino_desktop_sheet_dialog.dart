import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// 高仿macOS sheet窗口打开
class CupertinoDesktopSheetDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const CupertinoDesktopSheetDialog({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<BoxShadow> boxShadow = [
      BoxShadow(
        color: CupertinoColors.systemGrey
            .resolveFrom(context)
            .withAlpha((255.0 * 0.2).round()),
        offset: const Offset(0, 2),
        blurRadius: 4,
      )
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth / 2.5;
        double height = constraints.maxHeight / 2;
        if (backgroundColor.a == 0.0) {
          return Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                boxShadow: boxShadow,
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRSuperellipse(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: CupertinoColors.tertiarySystemBackground
                        .resolveFrom(context)
                        .withAlpha((255.0 * 0.3).round()),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                boxShadow: boxShadow,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRSuperellipse(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.circular(25),
                child: Container(color: backgroundColor, child: child),
              ),
            ),
          );
        }
      },
    );
  }
}
