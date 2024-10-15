import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../helpers/database_helper.dart';
import '../widgets/todo_item_widget.dart';

class CardView extends StatefulWidget {
  @override
  _CardViewState createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  List<TodoItem> _todoItems = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<int, bool> _expandedStates = {};

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

  void _addTodoItem(String title, String detail, String? dueDate) async {
    TodoItem newItem = TodoItem(
      title: title,
      detail: detail,
      dueDate: dueDate,
    );
    await _dbHelper.insertTodoItem(newItem);
    _loadTodoItems();
  }

  void _deleteTodoItem(int id) async {
    await _dbHelper.deleteTodoItem(id);
    _loadTodoItems();
  }

  void _editTodoItem(TodoItem todoItem) {
    TextEditingController controller_title =
        TextEditingController(text: todoItem.title);
    TextEditingController controller_detail =
        TextEditingController(text: todoItem.detail);

    // 用于存储用户选择的日期，如果用户没有选择新日期，则使用原来的 dueDate
    DateTime? selectedDate = todoItem.dueDate != null
        ? DateTime.parse(todoItem.dueDate!) // 如果有 dueDate，将其解析为 DateTime
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('编辑待办'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller_title,
                decoration: InputDecoration(
                  hintText: '输入新标题',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller_detail,
                decoration: InputDecoration(
                  hintText: '输入新描述',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    selectedDate != null
                        ? '截止日期: ${selectedDate!.toLocal()}'.split(' ')[0]
                        : '选择截止日期',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      // 弹出日期选择器
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        // 用户选择了新日期，更新 selectedDate
                        selectedDate = pickedDate;
                      }
                    },
                    child: Text('选择日期'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newTitle = controller_title.text;
                String newDetail = controller_detail.text;

                // 更新标题
                if (newTitle.isNotEmpty) {
                  todoItem.title = newTitle;
                }

                // 更新描述
                if (newDetail.isNotEmpty) {
                  todoItem.detail = newDetail;
                }

                // 更新截止日期
                if (selectedDate != null) {
                  todoItem.dueDate = selectedDate!
                      .toIso8601String()
                      .split('T')[0]; // 存储为 'YYYY-MM-DD' 格式
                }

                // 更新数据库中的值
                await _dbHelper.updateTodoItem(todoItem);
                _loadTodoItems(); // 刷新任务列表

                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: '添加待办',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _todoItems
              .map((todoItem) => TodoItemWidget(
                    todoItem: todoItem,
                    isExpanded: _expandedStates[todoItem.id] ?? false,
                    onTap: () {
                      setState(() {
                        _expandedStates[todoItem.id!] =
                            !(_expandedStates[todoItem.id] ?? false);
                      });
                    },
                    onEdit: _editTodoItem,
                    onDelete: _deleteTodoItem,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _pushAddTodoScreen() {
    TextEditingController controllerTitle = TextEditingController();
    TextEditingController controllerDetail = TextEditingController();

    String? dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('添加新待办'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllerTitle,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: '输入待办标题', prefixIcon: Icon(Icons.title)),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controllerDetail,
                decoration: InputDecoration(
                    hintText: '输入待办描述', prefixIcon: Icon(Icons.description)),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now());
                    if (pickedDate != null) {
                      setState(() {
                        dueDate = pickedDate.toIso8601String().split('T').first;
                      });
                    }
                  },
                  child: Text(dueDate == null ? '选择截止日期' : '截止日期：$dueDate'))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String title = controllerTitle.text;
                String detail = controllerDetail.text;

                if (title.isNotEmpty) {
                  // 添加新的 TodoItem
                  _addTodoItem(title, detail, dueDate);
                }

                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('保存'),
            ),
          ],
        );
      },
    );
  }
}
