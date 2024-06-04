import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notely/models/note.dart';

class NotesDatabase {
  NotesDatabase._init();
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize the database if it's not already initialized
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // Incremented version
      onCreate: _createDB,
      onUpgrade: _updateDB, // Added migration logic
    );
  }

  // Create the notes table
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableNotes (
      ${NotesField.id} $idType,
      ${NotesField.title} $textType,
      ${NotesField.description} $textType,
      ${NotesField.isPinned} $boolType
    )
  ''');
  }

  Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableNotes ADD COLUMN ${NotesField.isPinned} INTEGER NOT NULL DEFAULT 0');
    }
  }

  // Create a note
  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  // Read a note by id
  Future<Note> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableNotes,
      columns: NotesField.values,
      where: '${NotesField.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  // Read all notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    const orderBy = '${NotesField.isPinned} DESC, ${NotesField.id} ASC';
    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      tableNotes,
      note.toJson(),
      where: '${NotesField.id} = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: '${NotesField.id} = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
