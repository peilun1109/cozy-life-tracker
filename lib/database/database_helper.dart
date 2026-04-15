import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'cozy_life_tracker.db');
    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            progress INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            mood TEXT,
            created_at TEXT NOT NULL,
            goal_id INTEGER,
            FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE entry_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL,
            image_path TEXT NOT NULL,
            FOREIGN KEY(entry_id) REFERENCES entries(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY,
            reminder_enabled INTEGER NOT NULL DEFAULT 1,
            reminder_time TEXT NOT NULL DEFAULT '21:00'
          )
        ''');

        await db.insert(
          'app_settings',
          {
            'id': 1,
            'reminder_enabled': 1,
            'reminder_time': '21:00',
          },
        );
      },
    );
  }
}
