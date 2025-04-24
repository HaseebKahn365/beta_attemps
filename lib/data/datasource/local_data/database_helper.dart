import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final instance = DatabaseHelper._instance();
  static Database? _db;
  static late DatabaseHelper _databaseHelper;

  DatabaseHelper._instance() {
    _databaseHelper = this;
    _initDB();
  }

  factory DatabaseHelper() => instance;

  final tableName = 'note';
  final id = 'id';
  final title = 'title';
  final text = 'text';
  final date = 'date';

  Future<Database> _initDB() async {
    if (_db != null) return _db!;
    _db = await openDatabase('notes.db');
    return _db!;
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await _initDB();
    return await db.insert(tableName, note);
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await _initDB();
    return await db.query(tableName);
  }

  Future<int> deleteNote(int id) async {
    final db = await _initDB();
    return await db.delete(tableName, where: '$id = ?', whereArgs: [id]);
  }
}
