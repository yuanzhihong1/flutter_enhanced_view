import 'dart:async';
import 'package:flutter/cupertino.dart';

enum SidebarType { item, expansion }

// 一个快速实现侧边栏组件
class SidebarData {
  SidebarType type;
  String title;
  Widget? leading;
  Widget? trailing;
  FutureOr<void> Function()? onTap;
  bool? select;
  List<SidebarData>? children;
  dynamic tag;

  SidebarData({
    required this.type,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.select,
    this.children,
    this.tag,
  });
}

class SidebarNavigation extends StatefulWidget {
  const SidebarNavigation({
    super.key,
    required this.children,
    required this.title,
    this.trailing,
  });

  final List<SidebarData> children;
  final String title;
  final Widget? trailing;

  @override
  State<StatefulWidget> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoColors.systemGroupedBackground.resolveFrom(
      context,
    );
    final accentColor = CupertinoTheme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: CupertinoColors.separator
                .resolveFrom(context)
                .withAlpha((255.0 * 0.3).round()),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App/Title
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor,
                            accentColor.withAlpha((255.0 * 0.5).round())
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.sidebar_left,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: CupertinoColors.label.resolveFrom(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
              color: CupertinoColors.separator.resolveFrom(context),
              height: 0.5),
          // Navigation Items with scroll
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SidebarItem(
                          sidebarData: widget.children[index],
                          accentColor: accentColor,
                        ),
                      );
                    }, childCount: widget.children.length),
                  ),
                ),
              ],
            ),
          ),

          // Trailing Section with better styling
          if (widget.trailing != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator
                        .resolveFrom(context)
                        .withAlpha((255.0 * 0.2).round()),
                    width: 0.5,
                  ),
                ),
              ),
              child: widget.trailing,
            ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatefulWidget {
  const SidebarItem({super.key, required this.sidebarData, this.accentColor});

  final SidebarData sidebarData;
  final Color? accentColor;

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    if (widget.sidebarData.onTap != null) {
      widget.sidebarData.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final accentColor = widget.accentColor ?? theme.primaryColor;

    switch (widget.sidebarData.type) {
      case SidebarType.item:
        return _buildRegularItem(context, theme, accentColor);
      case SidebarType.expansion:
        return _buildExpansionItem(context, theme, accentColor);
    }
  }

  Widget _buildRegularItem(
    BuildContext context,
    CupertinoThemeData theme,
    Color accentColor,
  ) {
    final isSelected = widget.sidebarData.select == true;
    const baseColor = CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.black,
      darkColor: CupertinoColors.white,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.sidebarData.onTap != null
            ? () => widget.sidebarData.onTap!()
            : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withAlpha((255.0 * 0.12).round())
                : _isHovered
                    ? CupertinoColors.systemGrey
                        .resolveFrom(context)
                        .withAlpha((255.0 * 0.1).round())
                    : CupertinoColors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Leading icon with fade
              if (widget.sidebarData.leading != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.only(right: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: isSelected
                          ? accentColor
                          : CupertinoColors.secondaryLabel.resolveFrom(context),
                      size: 20,
                    ),
                    child: widget.sidebarData.leading!,
                  ),
                ),

              // Title with animation
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? accentColor
                        : baseColor.resolveFrom(context),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: isSelected ? 0.1 : 0,
                  ),
                  child: Text(
                    widget.sidebarData.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Trailing with subtle animation
              if (widget.sidebarData.trailing != null)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered || isSelected ? 1 : 0.7,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: widget.sidebarData.trailing!,
                  ),
                ),

              // Active indicator
              if (isSelected)
                Icon(
                  CupertinoIcons.circle_filled,
                  color: accentColor,
                  size: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionItem(
    BuildContext context,
    CupertinoThemeData theme,
    Color accentColor,
  ) {
    const baseColor = CupertinoDynamicColor.withBrightness(
      color: CupertinoColors.black,
      darkColor: CupertinoColors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expansion header
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _toggleExpansion,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isHovered
                    ? CupertinoColors.systemGrey
                        .resolveFrom(context)
                        .withAlpha((255.0 * 0.1).round())
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Leading icon
                  if (widget.sidebarData.leading != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconTheme(
                        data: IconThemeData(
                          color: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                          size: 20,
                        ),
                        child: widget.sidebarData.leading!,
                      ),
                    ),

                  // Title
                  Expanded(
                    child: Text(
                      widget.sidebarData.title,
                      style: TextStyle(
                        color: baseColor.resolveFrom(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Expand/collapse chevron with rotation
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 20,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),

                  // Custom trailing
                  if (widget.sidebarData.trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: widget.sidebarData.trailing!,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.sidebarData.children != null)
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Column(
                children: widget.sidebarData.children!
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SidebarItem(
                          sidebarData: child,
                          accentColor: accentColor,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
