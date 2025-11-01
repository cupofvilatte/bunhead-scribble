import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Database getter
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initialize database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bunhead_scribble.db');
    return await openDatabase(
      path,
      version: 2, // bump version to ensure new table is created
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Create events table if upgrading from version 1
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE events(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              description TEXT
            )
          ''');
        }
      },
    );
  }

  // ---------------- NOTES ----------------

  // Insert note
  Future<void> insertNote(String content) async {
    final db = await database;
    await db.insert('notes', {
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Get notes
  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'date DESC');
  }

  // Update note
  Future<void> updateNote(int id, String newContent) async {
    final db = await database;
    await db.update(
      'notes',
      {'content': newContent, 'date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete note
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- EVENTS ----------------

  // Insert event
  Future<void> insertEvent(String date, String description) async {
    final db = await database;
    await db.insert('events', {'date': date, 'description': description});
  }

  // Get events by date
  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    final db = await database;
    return await db.query('events', where: 'date = ?', whereArgs: [date]);
  }

  // Delete event
  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
