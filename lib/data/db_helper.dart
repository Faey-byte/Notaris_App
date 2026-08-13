import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:notaris_app/utils/logger.dart';

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
      version: 5,
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
            local_path TEXT,
            client_id TEXT,
            publicID TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE notaris_draft (
            id_field TEXT PRIMARY KEY,
            berkas_id TEXT,
            jenis_pekerjaan TEXT,
            label TEXT,
            text_value TEXT,
            url TEXT,
            matchkey TEXT,
            local_path TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              'ALTER TABLE ppat_draft ADD COLUMN local_path TEXT;',
            );
          } catch (e) {
            AppLogger.log('DB migration v1->v2 failed: $e');
          }
        }
        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE ppat_draft ADD COLUMN client_id TEXT;',
            );
          } catch (e) {
            AppLogger.log('DB migration v2->v3 failed: $e');
          }
        }
        if (oldVersion < 4) {
          try {
            await db.execute('''
              CREATE TABLE ppat_draft_new (
                id_field TEXT PRIMARY KEY,
                jenis_pekerjaan TEXT,
                label TEXT,
                text_value TEXT,
                file_id TEXT,
                matchkey TEXT,
                url TEXT,
                local_path TEXT,
                client_id TEXT,
                publicID TEXT
              )
            ''');
            await db.execute('''
              INSERT INTO ppat_draft_new
              SELECT
                id_field,
                jenis_pekerjaan,
                label,
                text_value,
                file_id,
                matchkey,
                url,
                local_path,
                client_id,
                CAST(publicID AS TEXT)
              FROM ppat_draft
            ''');
            await db.execute('DROP TABLE ppat_draft');
            await db.execute('ALTER TABLE ppat_draft_new RENAME TO ppat_draft');
          } catch (e) {
            AppLogger.log('DB migration v3->v4 failed: $e');
          }
        }
        if (oldVersion < 5) {
          try {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS notaris_draft (
                id_field TEXT PRIMARY KEY,
                berkas_id TEXT,
                jenis_pekerjaan TEXT,
                label TEXT,
                text_value TEXT,
                url TEXT,
                matchkey TEXT,
                local_path TEXT
              )
            ''');
          } catch (e) {
            AppLogger.log('DB migration v4->v5 failed: $e');
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

  Future<String?> getFileIdByJenis(String jenis) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'ppat_draft',
      columns: ['file_id'],
      where: 'jenis_pekerjaan = ? AND file_id IS NOT NULL',
      whereArgs: [jenis],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['file_id'] as String?;
  }

  Future<List<Map<String, dynamic>>> getDraftByClientId(String clientId) async {
    final dbClient = await db;
    return await dbClient.query(
      'ppat_draft',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }

  Future<String?> getFileIdByClientId(String clientId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'ppat_draft',
      columns: ['file_id'],
      where: 'client_id = ? AND file_id IS NOT NULL',
      whereArgs: [clientId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['file_id'] as String?;
  }

  Future<void> saveNotarisDraft(Map<String, dynamic> data) async {
    final dbClient = await db;
    await dbClient.insert(
      'notaris_draft',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotarisDraftByBerkasId(
    String berkasId,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'notaris_draft',
      where: 'berkas_id = ?',
      whereArgs: [berkasId],
    );
  }

  Future<List<Map<String, dynamic>>> getNotarisDraftByJenis(
    String jenis,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'notaris_draft',
      where: 'jenis_pekerjaan = ?',
      whereArgs: [jenis],
    );
  }

  Future<void> deleteNotarisDraftByBerkasId(String berkasId) async {
    final dbClient = await db;
    await dbClient.delete(
      'notaris_draft',
      where: 'berkas_id = ?',
      whereArgs: [berkasId],
    );
  }

  Future<void> cekSeluruhDataDraft() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> hasil = await dbClient.query(
        'ppat_draft',
      );
      AppLogger.log(
        "📊 === TOTAL DATA PPAT DI SQLITE: ${hasil.length} BARIS ===",
      );
      for (int i = 0; i < hasil.length; i++) {
        AppLogger.log(
          "--------------------------------------------------\n"
          "Baris ke-${i + 1}: ${hasil[i]}\n"
          "--------------------------------------------------",
        );
      }
    } catch (e) {
      AppLogger.log("❌ Gagal membaca database ppat_draft: $e");
    }
  }

  Future<void> cekSeluruhDataNotaris() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> hasil = await dbClient.query(
        'notaris_draft',
      );
      AppLogger.log(
        "📊 === TOTAL DATA NOTARIS DI SQLITE: ${hasil.length} BARIS ===",
      );
      for (int i = 0; i < hasil.length; i++) {
        AppLogger.log(
          "--------------------------------------------------\n"
          "Baris ke-${i + 1}: ${hasil[i]}\n"
          "--------------------------------------------------",
        );
      }
    } catch (e) {
      AppLogger.log("❌ Gagal membaca database notaris_draft: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotarisDraft() async {
    final dbClient = await db;
    return await dbClient.query('notaris_draft', orderBy: 'berkas_id DESC');
  }
}
