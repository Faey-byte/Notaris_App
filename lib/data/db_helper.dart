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
      version: 4, // ✅ Naik ke versi 4: fix tipe publicID INTEGER → TEXT
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
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              'ALTER TABLE ppat_draft ADD COLUMN local_path TEXT;',
            );
          } catch (_) {}
        }
        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE ppat_draft ADD COLUMN client_id TEXT;',
            );
          } catch (_) {}
        }
        if (oldVersion < 4) {
          // SQLite tidak support ALTER COLUMN tipe data secara langsung.
          // Solusi: recreate table dengan tipe publicID yang benar (TEXT).
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
            await db.execute(
              'ALTER TABLE ppat_draft_new RENAME TO ppat_draft',
            );
          } catch (e) {
            // Jika gagal (misal tabel lama tidak ada), biarkan saja
          }
        }
      },
    );
  }

  // ============================================================
  // CRUD DASAR
  // ============================================================

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

  // ============================================================
  // QUERY BERDASARKAN CLIENT_ID
  // Dipakai sebagai &publicID di URL fetchDetailBerkas
  // ============================================================

  /// Ambil file_id pertama yang ditemukan berdasarkan jenis_pekerjaan.
  /// Dipakai sebagai &publicID di URL fetchDetailBerkas.
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

  /// Ambil semua row berdasarkan client_id.
  /// Untuk keperluan detail berkas di DetailBerkasController.
  Future<List<Map<String, dynamic>>> getDraftByClientId(
    String clientId,
  ) async {
    final dbClient = await db;
    return await dbClient.query(
      'ppat_draft',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }

  /// Ambil file_id berdasarkan client_id.
  /// Dipakai sebagai parameter &id di fetchReadPpat.
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

  // ============================================================
  // DEBUG: Cetak seluruh isi database ke console
  // ============================================================

  Future<void> cekSeluruhDataDraft() async {
    try {
      final dbClient = await db;
      final List<Map<String, dynamic>> hasil = await dbClient.query(
        'ppat_draft',
      );

      print("📊 === TOTAL DATA DI SQLITE: ${hasil.length} BARIS ===");

      if (hasil.isEmpty) {
        print("⚠️ DATABASE KOSONG");
      } else {
        for (int i = 0; i < hasil.length; i++) {
          // Cetak semua field dalam SATU print agar tidak disela log Android
          print(
            "--------------------------------------------------\n"
            "Baris ke-${i + 1}:\n"
            "🔹 id_field        : ${hasil[i]['id_field']}\n"
            "🔹 label           : ${hasil[i]['label']}\n"
            "🔹 jenis_pekerjaan : ${hasil[i]['jenis_pekerjaan']}\n"
            "🔹 file_id         : ${hasil[i]['file_id']}\n"
            "🔹 matchkey        : ${hasil[i]['matchkey']}\n"
            "🔹 url             : ${hasil[i]['url']}\n"
            "🔹 text_value      : ${hasil[i]['text_value']}\n"
            "🔹 local_path      : ${hasil[i]['local_path']}\n"
            "🔹 client_id       : ${hasil[i]['client_id']}\n"
            "🔹 publicID        : ${hasil[i]['publicID']}\n"
            "--------------------------------------------------",
          );
        }
      }
    } catch (e) {
      print("❌ Gagal membaca database: $e");
    }
  }
}