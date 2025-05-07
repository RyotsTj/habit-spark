// SQLite操作に必要なパッケージ
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 自作のタスクモデルをインポート
import '../models/task.dart';

// タスクデータベースのクラス（シングルトンパターン）
class TaskDatabase {
  // インスタンスを1つだけ保持する
  static final TaskDatabase instance = TaskDatabase._init();

  static Database? _database;

  // プライベートコンストラクタ
  TaskDatabase._init();

  // データベースインスタンスを取得（なければ作成）
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  // データベースの初期化処理
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // データベースの保存先
    final path = join(dbPath, filePath); // パスを結合

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // 初回作成時の処理
    );
  }

  // テーブル作成SQL
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        deadline TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');
  }

  // タスクの追加
  Future<void> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap());
  }

  // タスクの取得（全件）
  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  // タスクの更新（主にisDone更新で使う）
  Future<void> updateTask(Task task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // タスクの削除（複数対応予定）
  Future<void> deleteTasks(List<int> ids) async {
    final db = await instance.database;
    final idList = ids.join(','); // カンマ区切りの文字列に変換
    await db.delete('tasks', where: 'id IN ($idList)');
  }
}
