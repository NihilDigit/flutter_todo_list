import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../helpers/database_helper.dart';
import '../widgets/todo_item_timeline_widget.dart';

class TimelineView extends StatefulWidget {
  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  List<TodoItem> _todoItems = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<int, bool> _expandedStates = {}; // 用于保存每个待办事项的展开状态

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  void _loadTodoItems() async {
    List<TodoItem> items = await _dbHelper.getTodoItems();
    setState(() {
      _todoItems = items;
    });
  }

  void _toggleExpanded(int id) {
    setState(() {
      _expandedStates[id] = !(_expandedStates[id] ?? false); // 切换 isExpanded 状态
    });
  }

  // 获取过期时间的颜色
  Color _getDueDateColor(String dueDate) {
    DateTime dueDateTime = DateTime.parse(dueDate);
    return dueDateTime.isBefore(DateTime.now()) ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimeLine(context);
  }

  Widget _buildTimeLine(BuildContext context) {
    final filteredTodoItems =
        _todoItems.where((todoItem) => todoItem.dueDate != null).toList();

    // 按照 dueDate 进行排序
    filteredTodoItems.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 48.0, top: 16.0), // 调整整体布局的左边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(filteredTodoItems.length, (index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：时间和竖线 + 箭头
                Column(
                  children: [
                    const SizedBox(height: 5),
                    // 时间文本
                    Text(
                      filteredTodoItems[index].dueDate!,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _getDueDateColor(filteredTodoItems[index].dueDate!),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // 自定义绘制的竖线和箭头
                    CustomPaint(
                      size: const Size(30, 40), // 控制箭头和竖线的绘制区域大小
                      painter: TimelinePainter(
                          isLast: index == filteredTodoItems.length - 1),
                    ),
                  ],
                ),
                const SizedBox(width: 16), // 左右两部分之间的间距

                // 右侧：TodoItemWidget 卡片
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodoItemWidget(
                        todoItem: filteredTodoItems[index],
                        isExpanded:
                            _expandedStates[filteredTodoItems[index].id] ??
                                false,
                        onTap: () =>
                            _toggleExpanded(filteredTodoItems[index].id!),
                      ),
                      const SizedBox(height: 20), // 每个卡片之间的间距
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final bool isLast;

  TimelinePainter({required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double lineStartY = 0;
    final double lineEndY = size.height - 10; // 让箭头占据一些空间

    // 1. 绘制竖线
    if (!isLast) {
      canvas.drawLine(Offset(size.width / 2, lineStartY),
          Offset(size.width / 2, lineEndY), paint);
    }

    // 2. 绘制箭头
    if (!isLast) {
      final Path arrowPath = Path();
      arrowPath.moveTo(size.width / 2 - 4, size.height - 10); // 左边
      arrowPath.lineTo(size.width / 2, size.height); // 顶部
      arrowPath.lineTo(size.width / 2 + 4, size.height - 10); // 右边

      canvas.drawPath(arrowPath, paint);
    }
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) {
    return oldDelegate.isLast != isLast;
  }
}
