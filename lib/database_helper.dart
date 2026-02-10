import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'bmi_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bmi_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL,
        height REAL,
        bmi REAL,
        comment TEXT,
        date TEXT
      )
    ''');
  }

  Future<int> insertRecord(BMIRecord record) async {
    Database db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<BMIRecord>> getRecords() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('records', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return BMIRecord.fromMap(maps[i]);
    });
  }

  Future<int> deleteRecord(int id) async {
    Database db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }
}
