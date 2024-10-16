import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  final bool isExpanded;
  final VoidCallback onTap; // 添加 onTap 回调

  const TodoItemWidget({
    Key? key,
    required this.todoItem,
    required this.isExpanded,
    required this.onTap, // 接收 onTap 回调
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 当点击时调用 onTap 回调
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(isExpanded ? 6.0 : 4.0), // 根据 expanded 状态调整间距
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context), // 显示标题
        if (isExpanded) ...[
          const SizedBox(height: 5),
          _buildDetail(), // 展开时显示详细内容
        ],
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      todoItem.title,
      softWrap: true,
      maxLines: 1, // 限制标题显示一行
      overflow: TextOverflow.ellipsis, // 如果内容过长，显示省略号
      style: TextStyle(
        fontSize: 16.0,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetail() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 48),
      child: Text(
        style: TextStyle(fontSize: 12.0),
        todoItem.detail,
        softWrap: true,
        maxLines: 5, // 限制详情最多显示两行
        overflow: TextOverflow.ellipsis, // 如果内容过长，显示省略号
      ),
    );
  }
}
