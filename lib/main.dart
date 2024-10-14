import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path; // 对 path 包使用别名

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        fontFamily: 'LXGWWenKaiMono',
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// 定义 TodoItem 类
class TodoItem {
  int? id;
  String title;
  bool isCompleted;
  String detail;

  // 构造函数，根据传入的数据创建对象
  TodoItem(
      {this.id,
      required this.title,
      this.isCompleted = false,
      this.detail = ''});

  // 将 TodoItem 对象转换成 Map 对象来存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'detail': detail,
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
    );
  }

  // fromMap 的另一种实现，构造函数会自动返回一个对象，与上面基本等价
  // TodoItem.fromMap(Map<String, dynamic> map)
  //   : id = map['id'],
  //     title = map['title']
  //     isCompleted = map['isCompleted'] == 1;
}

// 用来处理数据库操作
class DatabaseHelper {
  // 从 Class 创建出来的 Object 称为 Instance （实例）
  // 单例模式，确保在整个应用中只存在一个 DatabaseHelper 实例，该实例不会被销毁
  static final DatabaseHelper _instance = DatabaseHelper
      ._internal(); // 声明一个 _instance 变量存储这个实例，调用 _internal 构造函数，禁用了默认的无参构造函数，仅可以使用 _internal 进行初始化
  factory DatabaseHelper() =>
      _instance; // 与普通构造函数不同， factory 构造函数可以返回一个已经存在的对象而不重新创建，这保证每次调用 DatabaseHelper() 时都返回我们之前创建的 _instance
  DatabaseHelper._internal(); //将构造函数 _internal 定义为私有，保证无法在外部初始化

  // 创建数据库实例
  static Database? _database; // 用 _database 变量来保存数据

  Future<Database> get database async {
    // 获取数据库实例的 getter 函数，每次访问 dbHelper.database 时调用
    if (_database != null) return _database!; // 如果 _database 已经存在就直接返回
    _database = await _initDatabase(); //否则调用 _initDatabase
    return _database!; // 等待 _initDatavase 完成之后返回 _database
  }

  // 初始化数据库实例
  Future<Database> _initDatabase() async {
    String dbPath = path.join(await getDatabasesPath(),
        '.todo_database.db'); // 在该系统默认存放数据库文件的路径存放 todo_database.db
    return await openDatabase(
      // 如果已经存在，打开数据库，否则创建一个新文件
      dbPath, // 上面获取的数据库存储路径
      version: 2, // 数据库的版本号，根据后续迭代可以修改
      onCreate: (db, version) {
        // 如果是新创建的 db 文件，执行脚本
        return db.execute(
          //需要注意的是， SQLite 并不支持布尔类型，此处用 integer 来存储 isCompleted
          '''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER,
            detail TEXT)
          ''',
        );
      },
    );
  }

  // 以下是对数据库操作方法的封装

  // 插入新待办
  Future<void> insertTodoItem(TodoItem item) async {
    final db = await database;
    await db.insert(
      'todos',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // 如果 pk 相同则替换
    );
  }

  // 从数据库中恢复所有待办
  Future<List<TodoItem>> getTodoItems() async {
    final db = await database;
    // 通过 db.query 读取 todos 表里的所有记录，返回一个 List
    final List<Map<String, dynamic>> maps = await db.query('todos');
    // 把 List 里的每一个 Map 通过 fromMap 方法 转换成 todoItem
    return List.generate(maps.length, (i) {
      return TodoItem.fromMap(maps[i]);
    });
  }

  // 修改已有待办
  Future<void> updateTodoItem(TodoItem item) async {
    final db = await database;
    await db.update(
      'todos',
      item.toMap(),
      where: 'id = ?', // 通过 id 进行匹配
      whereArgs: [item.id], // 传入 item 的 id 作为 where 使用的匹配值
    );
  }

  // 删除待办
  Future<void> deleteTodoItem(int id) async {
    // 与上面的update不同，此处只需要传入 id
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<TodoItem> _todoItems = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  int _selectedIndex = 0;

  late List<Widget> _pages;

  Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadTodoItems(); // 应用启动时加载任务列表
  }

  // 从数据库加载任务列表
  void _loadTodoItems() async {
    List<TodoItem> items = await _dbHelper.getTodoItems();
    setState(() {
      _todoItems = items; // 将返回的 List 设定为 working list
    });
  }

  // 添加新任务
  void _addTodoItem(String title, String detail) async {
    TodoItem newItem = TodoItem(
        title: title,
        detail: detail); // 创建一个 task 为标题的 TodoItem， id 和 isCompleted 保持默认
    await _dbHelper
        .insertTodoItem(newItem); // 将这个 TodoItem 插入数据库，这时候通过数据库操作赋予了 pk
    _loadTodoItems(); // 重新加载任务列表
  }

  // 删除任务
  void _deleteTodoItem(int id) async {
    await _dbHelper.deleteTodoItem(id);
    _loadTodoItems(); // 重新加载任务列表
  }

  // 更新任务
  void _toggleTodoItemCompletion(TodoItem item) async {
    item.isCompleted = !item.isCompleted;
    await _dbHelper.updateTodoItem(item);
    _loadTodoItems(); // 重新加载任务列表
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _pushAddTodoScreen() {
    TextEditingController controllerTitle = TextEditingController();
    TextEditingController controllerDetail = TextEditingController();

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
                  _addTodoItem(title, detail); // 假设 _addTodoItem 也支持 detail 参数
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

  void _editTodoItem(TodoItem todoItem) {
    TextEditingController controller_title =
        TextEditingController(text: todoItem.title);
    TextEditingController controller_detail =
        TextEditingController(text: todoItem.detail);

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
                    hintText: '输入新标题', prefixIcon: Icon(Icons.title)),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller_detail,
                decoration: InputDecoration(
                    hintText: '输入新描述', prefixIcon: Icon(Icons.description)),
              )
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
                if (newTitle.isNotEmpty) {
                  // 更新 TodoItem 的 title
                  todoItem.title = newTitle;
                  await _dbHelper.updateTodoItem(todoItem); // 更新数据库中的值
                  _loadTodoItems(); // 刷新任务列表
                }
                if (newDetail.isNotEmpty) {
                  todoItem.detail = newDetail;
                  await _dbHelper.updateTodoItem(todoItem);
                  _loadTodoItems();
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

  @override
  Widget build(BuildContext context) {
    _pages = [
      _buildTodoList(),
      _workInProgress('时间轴'),
      _workInProgress('设置'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getPageTitle(_selectedIndex)}'),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: '添加待办',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '卡片视图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '时间轴视图',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }

  // 构建待办事项列表
  Widget _buildTodoList() {
    return SingleChildScrollView(
      // 使用 SingleChildScrollView 使待办事项可以滚动
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children:
              _todoItems.map((todoItem) => _buildTodoItem(todoItem)).toList(),
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return '卡片视图';
      case 1:
        return '时间轴视图';
      case 2:
        return '设置';
      default:
        return '卡片视图';
    }
  }

  Widget _workInProgress(String pagename) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center, // 将图标放在进度指示器的中心
            children: [
              SizedBox(
                height: 100.0,
                width: 100.0,
                child: CircularProgressIndicator(
                  strokeWidth: 6.0, // 环形进度条的宽度
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orangeAccent), // 环的颜色
                ),
              ),
              Icon(
                Icons.construction,
                color: Colors.orangeAccent,
                size: 60.0, // 图标大小
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Text(
            '${pagename} 界面尚未开发完毕',
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  // 构建单个待办事项项
  Widget _buildTodoItem(TodoItem todoItem) {
    bool isExpanded = _expandedStates[todoItem.id] ?? false;

    return LayoutBuilder(builder: (context, constraints) {
      // 获取屏幕的宽度
      double screenWidth = MediaQuery.of(context).size.width;

      // 根据屏幕宽度动态调整卡片的最大宽度
      double cardWidth = screenWidth * 0.4; // 卡片宽度为屏幕的 40%
      if (cardWidth < 100) cardWidth = 100; // 设置最小宽度
      if (cardWidth > 250) cardWidth = 250; // 设置最大宽度

      double expandedCardWidth = screenWidth * 0.6;

      return GestureDetector(
        onTap: () {
          setState(() {
            _expandedStates[todoItem.id!] = !isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(isExpanded ? 16.0 : 8.0),
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: isExpanded ? expandedCardWidth : cardWidth,
          ),
          child: Stack(
            children: [
              // 卡片内容
              Card(
                elevation: isExpanded ? 12.0 : 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // 设置圆角
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // 整体的通用 padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题的 Padding
                      Padding(
                        padding: const EdgeInsets.only(right: 36.0), // 右边距 36
                        child: Text(
                          todoItem.title,
                          softWrap: true, // 允许换行
                          maxLines: null, // 允许多行显示
                          overflow: TextOverflow.visible, // 确保文本不会被截断
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold, // 加粗标题
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      // 详细描述的 Padding
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0), // 右边距 8
                        child: Text(
                          todoItem.detail,
                          softWrap: true,
                          maxLines: isExpanded ? 5 : 1, // 显示详细描述
                          overflow: TextOverflow.ellipsis, // 超出时显示省略号
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // PopupMenuButton 悬浮在右上角
              Positioned(
                right: 8, // 距离右边 0 像素
                top: 8, // 距离顶部 0 像素
                child: PopupMenuButton<String>(
                  iconSize: isExpanded ? 24 : 0, // 图标大小
                  onSelected: (value) {
                    // 根据选择的值执行操作
                    if (value == 'Edit') {
                      // 编辑项
                      _editTodoItem(todoItem);
                    } else if (value == 'Delete') {
                      // 删除项
                      _deleteTodoItem(todoItem.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'Edit',
                        child: Text('编辑'),
                      ),
                      PopupMenuItem(
                        value: 'Delete',
                        child: Text('删除'),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
