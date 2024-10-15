class TodoItem {
  int? id;
  String title;
  bool isCompleted;
  String detail;
  String? dueDate;

  // 构造函数，根据传入的数据创建对象
  TodoItem({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.detail = '',
    this.dueDate,
  });

  // 将 TodoItem 对象转换成 Map 对象来存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'detail': detail,
      'due_date': dueDate,
    };
  }

  // factory 构造函数，从一个 Map 对象创建并返回 TodoItem 对象
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    // Str -> dynamic
    return TodoItem(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ==
          1, // 由于 SQLite 不存在布尔型，用 isCompleted == 1 来代替 True
      detail: map['detail'] ?? '',
      dueDate: map['due_date'],
    );
  }

  // fromMap 的另一种实现，构造函数会自动返回一个对象，与上面基本等价
  // TodoItem.fromMap(Map<String, dynamic> map)
  //   : id = map['id'],
  //     title = map['title']
  //     isCompleted = map['isCompleted'] == 1;
}
