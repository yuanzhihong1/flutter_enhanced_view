import 'package:flutter/cupertino.dart';

import '../../enhanced_view.dart';

class TableHead {
  String dataKey;
  String title;
  bool isDisplay;
  Widget Function(BuildContext context, dynamic value)? customBuilder;
  double? width;

  TableHead({
    required this.dataKey,
    required this.title,
    required this.isDisplay,
    this.customBuilder,
    this.width,
  });
}

class DataTable extends StatefulWidget {
  const DataTable({
    super.key,
    required this.list,
    required this.multipleSelections,
    required this.multipleSelectionsCall,
    required this.tableHeadList,
    this.rowHeight = 50,
    this.columnWidth = 200.0,
    this.selectedColor,
    this.showCheckboxColumn = true,
    this.checkboxColumnWidth = 60.0,
    this.showRemove = true,
    this.showEdit = true,
    this.removeCall,
    this.editCall,
  });

  final List<Map<String, dynamic>> list;
  final List<TableHead> tableHeadList;
  final bool multipleSelections;
  final Function(List<Map<String, dynamic>>) multipleSelectionsCall;
  final double rowHeight;
  final double columnWidth;
  final Color? selectedColor;
  final bool showCheckboxColumn;
  final double checkboxColumnWidth;
  final bool showRemove;
  final bool showEdit;

  final Function(Map<String, dynamic>)? removeCall;
  final Function(Map<String, dynamic>)? editCall;

  @override
  State<StatefulWidget> createState() => _DataTableState();
}

class _DataTableState extends State<DataTable> {
  late List<bool> _selectedRows;
  Set<int> _selectedIndexes = {};
  final ScrollController _horizontalScrollController = ScrollController();

  // 获取要显示的列
  List<TableHead> get _displayedColumns =>
      widget.tableHeadList.where((col) => col.isDisplay).toList();

  // 获取列的实际宽度
  double _getColumnWidth(TableHead column) {
    return column.width ?? widget.columnWidth;
  }

  // 计算表格总宽度
  double get _totalTableWidth {
    var totalWidth = 0.0;

    // 复选框列宽度
    if (_shouldShowCheckboxColumn) {
      totalWidth += widget.checkboxColumnWidth;
    }

    // 数据列宽度
    for (var column in _displayedColumns) {
      totalWidth += _getColumnWidth(column);
    }

    // 操作列宽度
    if (_shouldShowActionColumn) {
      totalWidth += widget.columnWidth;
    }

    return totalWidth;
  }

  // 是否显示复选框列
  bool get _shouldShowCheckboxColumn =>
      widget.showCheckboxColumn && widget.multipleSelections;

  // 是否显示操作列
  bool get _shouldShowActionColumn => widget.showEdit || widget.showRemove;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  @override
  void didUpdateWidget(DataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list ||
        oldWidget.multipleSelections != widget.multipleSelections) {
      _initializeSelection();
      _selectedIndexes.clear();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _initializeSelection() {
    if (widget.multipleSelections) {
      _selectedRows = List<bool>.filled(widget.list.length, false);
    } else {
      _selectedRows = [];
    }
  }

  void _handleRowSelection(int index) {
    if (!widget.multipleSelections) return;

    setState(() {
      _selectedRows[index] = !_selectedRows[index];
      if (_selectedRows[index]) {
        _selectedIndexes.add(index);
      } else {
        _selectedIndexes.remove(index);
      }
      _notifySelections();
    });
  }

  void _handleSelectAll() {
    if (!widget.multipleSelections) return;

    setState(() {
      if (_selectedIndexes.length == widget.list.length) {
        _selectedRows = List<bool>.filled(widget.list.length, false);
        _selectedIndexes.clear();
      } else {
        _selectedRows = List<bool>.filled(widget.list.length, true);
        _selectedIndexes = Set<int>.from(Iterable.generate(widget.list.length));
      }
      _notifySelections();
    });
  }

  void _notifySelections() {
    final selectedItems = widget.list
        .asMap()
        .entries
        .where((entry) => _selectedRows[entry.key])
        .map((entry) => entry.value)
        .toList();
    widget.multipleSelectionsCall(selectedItems);
  }

  // 构建操作列
  Widget _buildActionColumn(Map<String, dynamic> item) {
    return Container(
      width: widget.columnWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showEdit == true)
            CupertinoButton(
              padding: const EdgeInsets.all(6),
              onPressed: () => widget.editCall?.call(item),
              child: const Icon(
                CupertinoIcons.pencil,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
            ),
          if (widget.showRemove == true)
            CupertinoButton(
              padding: const EdgeInsets.all(6),
              onPressed: () => widget.removeCall?.call(item),
              child: const Icon(
                CupertinoIcons.delete,
                size: 20,
                color: CupertinoColors.destructiveRed,
              ),
            ),
        ],
      ),
    );
  }

  Color _getSelectColor() {
    return widget.selectedColor ?? CupertinoTheme.of(context).primaryColor;
  }

  Widget _buildHeader() {
    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 选择列
          if (_shouldShowCheckboxColumn)
            Container(
              width: widget.checkboxColumnWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: _handleSelectAll,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _selectedIndexes.length == widget.list.length
                            ? _getSelectColor()
                            : CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                        width: 1.5,
                      ),
                      color: _selectedIndexes.length == widget.list.length
                          ? _getSelectColor()
                          : CupertinoColors.transparent,
                    ),
                    child: _selectedIndexes.length == widget.list.length
                        ? const Center(
                            child: Icon(
                              CupertinoIcons.check_mark,
                              size: 14,
                              color: CupertinoColors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

          // 数据列
          ..._displayedColumns.map((column) {
            final width = _getColumnWidth(column);
            return Container(
              width: width,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    column.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            );
          }),

          // 操作列表头
          if (_shouldShowActionColumn)
            Container(
              width: widget.columnWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '操作',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(int index) {
    final item = widget.list[index];
    final isSelected = widget.multipleSelections &&
        index < _selectedRows.length &&
        _selectedRows[index];

    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: isSelected
            ? _getSelectColor().withAlpha((255.0 * 0.08).round())
            : (index % 2 == 0
                ? CupertinoColors.systemBackground.resolveFrom(context)
                : CupertinoColors.secondarySystemBackground
                    .resolveFrom(context)),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 选择列
          if (_shouldShowCheckboxColumn)
            Container(
              width: widget.checkboxColumnWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () => _handleRowSelection(index),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? _getSelectColor()
                            : CupertinoColors.tertiaryLabel
                                .resolveFrom(context),
                        width: 1.5,
                      ),
                      color: isSelected
                          ? _getSelectColor()
                          : CupertinoColors.transparent,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              CupertinoIcons.check_mark,
                              size: 14,
                              color: CupertinoColors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

          // 数据列
          ..._displayedColumns.map((column) {
            final width = _getColumnWidth(column);
            final rawValue = item[column.dataKey];
            return Container(
              width: width,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: _buildCellContent(column, rawValue, isSelected),
            );
          }),

          // 操作列
          if (_shouldShowActionColumn)
            Container(
              width: widget.columnWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: _buildActionColumn(item),
            ),
        ],
      ),
    );
  }

  Widget _buildCellContent(
      TableHead column, dynamic rawValue, bool isSelected) {
    if (column.customBuilder != null) {
      return column.customBuilder!(context, rawValue);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          rawValue?.toString() ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? _getSelectColor()
                : CupertinoColors.label.resolveFrom(context),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.table,
            size: 48,
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 表格容器 - 包含整个表格（表头 + 数据）
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: SizedBox(
              width: _totalTableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 表头
                  _buildHeader(),

                  // 分割线
                  const CupertinoDivider(height: 0),

                  // 表格内容
                  Expanded(
                    child: widget.list.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: false,
                            itemCount: widget.list.length,
                            itemBuilder: (context, index) => _buildRow(index),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
