import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'data/ballet_steps.dart';

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
      version: 4, // bump version to ensure new table is created
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

        await db.execute('''
          CREATE TABLE choreography(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE steps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            category TEXT
          )
        ''');

        for (var step in balletStepsData) {
          await db.insert('steps', step);
        }
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

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE choreography(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              content TEXT,
              date TEXT
            )
          ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE steps(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              description TEXT,
              category TEXT
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

  // ---------------- CHOREOGRAPHY ----------------

  // Insert choreography note
  Future<void> insertChoreo(String content) async {
    final db = await database;
    await db.insert('choreography', {
      'content': content,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Get choreography notes
  Future<List<Map<String, dynamic>>> getChoreoNotes() async {
    final db = await database;
    return await db.query('choreography', orderBy: 'date DESC');
  }

  // Update choreography note
  Future<void> updateChoreo(int id, String newContent) async {
    final db = await database;
    await db.update(
      'choreography',
      {'content': newContent, 'date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete choreography note
  Future<void> deleteChoreo(int id) async {
    final db = await database;
    await db.delete('choreography', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- STEPS ----------------

  // Search ballet steps by name or category
  Future<List<Map<String, dynamic>>> searchSteps(String query) async {
    final db = await database;
    return await db.query(
      'steps',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  // Get all steps (if you want to load everything at once)
  Future<List<Map<String, dynamic>>> getAllSteps() async {
    final db = await database;
    return await db.query('steps', orderBy: 'name ASC');
  }
}