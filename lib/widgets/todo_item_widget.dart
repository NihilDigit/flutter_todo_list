import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(TodoItem) onEdit;
  final Function(int) onDelete;

  const TodoItemWidget({
    Key? key,
    required this.todoItem,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          int titleWidthFactor =
              (todoItem.title.length < 4) ? todoItem.title.length : 4;
          titleWidthFactor = (titleWidthFactor > 7) ? 7 : titleWidthFactor;
          titleWidthFactor = (titleWidthFactor < 4) ? 4 : titleWidthFactor;
          double wordsize = screenWidth * 0.5 / 10;
          double cardWidth = wordsize * titleWidthFactor * 1.8;
          double expandedCardWidth = cardWidth * 1.4;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(isExpanded ? 6.0 : 4.0),
            constraints: BoxConstraints(
              minWidth: 100,
              maxWidth: isExpanded ? expandedCardWidth : cardWidth,
            ),
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Stack(
      children: [
        Card(
          elevation: isExpanded ? 16.0 : 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: isExpanded
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                SizedBox(height: 5),
                if (todoItem.dueDate != null && isExpanded) _buildDueDate(),
                _buildDetail(),
              ],
            ),
          ),
        ),
        _buildPopupMenu(),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: Text(
        todoItem.title,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontSize: isExpanded ? 17.0 : 16.0,
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueDate() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: isExpanded ? 13 : 12,
          color: _getDueDateColor(todoItem.dueDate!),
        ),
        Text(
          ' ${todoItem.dueDate}',
          style: TextStyle(
            fontSize: isExpanded ? 11 : 10,
            color: _getDueDateColor(todoItem.dueDate!),
          ),
        ),
      ],
    );
  }

  Widget _buildDetail() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Text(
        isExpanded ? '  ${todoItem.detail}' : todoItem.detail,
        softWrap: true,
        maxLines: isExpanded ? 5 : 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isExpanded ? 13.0 : 12.0,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return Positioned(
      right: 0,
      top: 0,
      child: PopupMenuButton<String>(
        iconSize: isExpanded ? 20 : 0,
        onSelected: (value) {
          if (value == 'Edit') {
            onEdit(todoItem);
          } else if (value == 'Delete') {
            onDelete(todoItem.id!);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(value: 'Edit', child: Text('编辑')),
            PopupMenuItem(value: 'Delete', child: Text('删除')),
          ];
        },
      ),
    );
  }

  Color _getDueDateColor(String dueDate) {
    DateTime dueDateTime = DateTime.parse(dueDate);
    return dueDateTime.isBefore(DateTime.now())
        ? Colors.red
        : Colors.lightGreen;
  }
}
