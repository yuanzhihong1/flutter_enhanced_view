import 'package:flutter/cupertino.dart';

import '../../enhanced_view.dart';

class TableHead {
  String dataKey; // 对应传入的List<Map> 的Key
  String title; // 标题
  bool isDisplay; // 是否显示该列
  dynamic Function(dynamic)? valueDisplayRule; // 显示内容如果外部需要再处理就调用这个

  TableHead({
    required this.dataKey,
    required this.title,
    required this.isDisplay,
    this.valueDisplayRule,
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

  // 计算表头总宽度
  double get _headerWidth => _displayedColumns.length * widget.columnWidth;

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
    // 当数据源变化时，重新初始化选择状态
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
    // 只在multipleSelections为true时初始化_selectedRows
    if (widget.multipleSelections) {
      _selectedRows = List<bool>.filled(widget.list.length, false);
    } else {
      _selectedRows = []; // 不允许多选时，不需要维护选中状态
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
        // 取消全选
        _selectedRows = List<bool>.filled(widget.list.length, false);
        _selectedIndexes.clear();
      } else {
        // 全选
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

  // 处理单元格显示内容
  String _processCellValue(TableHead column, dynamic rawValue) {
    if (column.valueDisplayRule != null) {
      final processedValue = column.valueDisplayRule!(rawValue);
      return processedValue?.toString() ?? '';
    }
    return rawValue?.toString() ?? '';
  }

  // 构建操作列
  Widget _buildActionColumn(Map<String, dynamic> item) {
    return SizedBox(
      width: widget.columnWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Spacer(),
          if (widget.showEdit == true)
            CupertinoButton(
              onPressed: () {
                if (widget.editCall != null) {
                  widget.editCall!(item);
                }
              },
              minimumSize: const Size(0, 0),
              child: const Icon(
                CupertinoIcons.pencil,
                size: 20,
                color: CupertinoColors.activeBlue,
              ),
            ),
          if (widget.showEdit == true && widget.showRemove == true)
            const Spacer(),
          if (widget.showRemove == true)
            CupertinoButton(
              minimumSize: const Size(0, 0),
              onPressed: () {
                if (widget.removeCall != null) {
                  widget.removeCall!(item);
                }
              },
              child: const Icon(
                CupertinoIcons.delete,
                size: 20,
                color: CupertinoColors.destructiveRed,
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Color _getSelectColor() {
    if (widget.selectedColor != null) {
      return widget.selectedColor!;
    } else {
      return CupertinoTheme.of(context).primaryColor;
    }
  }

  Widget _buildHeader() {
    return SizedBox(
      height: widget.rowHeight,
      child: Row(
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
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _selectedIndexes.length == widget.list.length
                            ? _getSelectColor()
                            : CupertinoColors.tertiaryLabel.resolveFrom(
                                context,
                              ),
                        width: 1.5,
                      ),
                      color: _selectedIndexes.length == widget.list.length
                          ? widget.selectedColor
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
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _headerWidth,
                child: Row(
                  children: _displayedColumns.map((column) {
                    return Container(
                      width: widget.columnWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: CupertinoColors.separator.resolveFrom(
                              context,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  }).toList(),
                ),
              ),
            ),
          ),

          // 操作列表头（固定在最右侧）
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
    // 安全地获取选中状态
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
                    : CupertinoColors.secondarySystemBackground.resolveFrom(
                        context,
                      ))
                .resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
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
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? _getSelectColor()
                            : CupertinoColors.tertiaryLabel.resolveFrom(
                                context,
                              ),
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalScrollController,
              child: SizedBox(
                width: _headerWidth,
                child: Row(
                  children: _displayedColumns.map((column) {
                    final rawValue = item[column.dataKey];
                    final displayValue = _processCellValue(column, rawValue);

                    return Container(
                      width: widget.columnWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: CupertinoColors.separator.resolveFrom(
                              context,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayValue,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? widget.selectedColor
                                  : CupertinoColors.label.resolveFrom(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // 操作列（固定在最右侧）
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
      mainAxisSize: MainAxisSize.max,
      children: [
        // 表头
        _buildHeader(),

        // 分割线
        const CupertinoDivider(),

        // 表格内容
        Expanded(
          child: widget.list.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: widget.list.length,
                  itemBuilder: (context, index) {
                    return _buildRow(index);
                  },
                ),
        ),
      ],
    );
  }
}
