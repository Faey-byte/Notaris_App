import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'notaris_notary.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ppat_draft (
            id_field TEXT PRIMARY KEY, 
            jenis_pekerjaan TEXT,
            label TEXT,
            text_value TEXT,
            file_id TEXT,
            matchkey TEXT,
            url TEXT,
            local_path TEXT -- 🔥 Kolom baru ditambahkan di sini saat instalasi awal
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('''
              ALTER TABLE ppat_draft ADD COLUMN local_path TEXT;
            ''');
          } catch (e) {
            print("Info: Kolom local_path mungkin sudah ada. $e");
          }
        }
      },
    );
  }

  Future<void> saveDraft(Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert(
      'ppat_draft',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDraftByJenis(String jenis) async {
    final dbClient = await db;
    return await dbClient.query(
      'ppat_draft',
      where: 'jenis_pekerjaan = ?',
      whereArgs: [jenis],
    );
  }

  Future<void> deleteDraftByJenis(String jenis) async {
    final dbClient = await db;
    await dbClient.delete(
      'ppat_draft',
      where: 'jenis_pekerjaan = ?',
      whereArgs: [jenis],
    );
  }
}