import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/todo_item.dart';

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
        version: 3, // 数据库的版本号，根据后续迭代可以修改
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
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        await db.execute(
            'ALTER TABLE todos ADD COLUMN due_date TEXT DEFAULT \'2001-01-01\'');
      }
    });
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
