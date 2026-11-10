import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, 'freshtrack.db');

    return openDatabase(
      filePath,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE assessments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            produce_name TEXT NOT NULL,
            freshness_status TEXT NOT NULL,
            confidence REAL,
            image_path TEXT,
            assessed_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            produce_name TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT 'Other',
            quantity REAL NOT NULL,
            unit TEXT NOT NULL,
            freshness_status TEXT,
            date_added TEXT NOT NULL,
            purchase_date TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE feedback (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            assessment_id INTEGER,
            is_correct INTEGER NOT NULL,
            prediction_accuracy TEXT,
            actual_produce TEXT,
            actual_condition TEXT,
            is_helpful INTEGER,
            comments TEXT,
            submitted_at TEXT NOT NULL,
            FOREIGN KEY (assessment_id)
              REFERENCES assessments(id)
              ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Version 1 -> Version 2
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE inventory
            ADD COLUMN category TEXT NOT NULL DEFAULT 'Other'
          ''');

          await db.execute('''
            ALTER TABLE inventory
            ADD COLUMN purchase_date TEXT
          ''');
        }

        // Version 2 -> Version 3
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE feedback
            ADD COLUMN prediction_accuracy TEXT
          ''');

          await db.execute('''
            ALTER TABLE feedback
            ADD COLUMN actual_produce TEXT
          ''');

          await db.execute('''
            ALTER TABLE feedback
            ADD COLUMN actual_condition TEXT
          ''');

          await db.execute('''
            ALTER TABLE feedback
            ADD COLUMN is_helpful INTEGER
          ''');
        }
      },
    );
  }

  // =====================================================
  // ASSESSMENTS
  // =====================================================

  Future<int> insertAssessment(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('assessments', data);
  }

  Future<List<Map<String, dynamic>>> getAssessments() async {
    final db = await database;

    return db.query('assessments', orderBy: 'assessed_at DESC, id DESC');
  }

  Future<Map<String, dynamic>?> getAssessmentById(int id) async {
    final db = await database;

    final results = await db.query(
      'assessments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  Future<int> deleteAssessment(int id) async {
    final db = await database;

    return db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  // =====================================================
  // INVENTORY
  // =====================================================

  Future<int> insertInventory(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('inventory', data);
  }

  Future<List<Map<String, dynamic>>> getInventory() async {
    final db = await database;

    return db.query('inventory', orderBy: 'date_added DESC, id DESC');
  }

  Future<int> updateInventory(int id, Map<String, dynamic> data) async {
    final db = await database;

    return db.update('inventory', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteInventory(int id) async {
    final db = await database;

    return db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  // =====================================================
  // FEEDBACK
  // =====================================================

  Future<int> insertFeedback(Map<String, dynamic> data) async {
    final db = await database;

    return db.insert('feedback', data);
  }

  Future<List<Map<String, dynamic>>> getFeedback() async {
    final db = await database;

    return db.query('feedback', orderBy: 'submitted_at DESC, id DESC');
  }

  Future<List<Map<String, dynamic>>> getFeedbackForAssessment(
    int assessmentId,
  ) async {
    final db = await database;

    return db.query(
      'feedback',
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
      orderBy: 'submitted_at DESC, id DESC',
    );
  }

  Future<bool> hasFeedbackForAssessment(int assessmentId) async {
    final db = await database;

    final results = await db.query(
      'feedback',
      columns: ['id'],
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  // =====================================================
  // DATABASE LIFECYCLE
  // =====================================================

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
