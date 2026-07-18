class RekapLaporanModel {
  final int totalBerkas;
  final int totalSelesai;
  final int totalProses;
  final double pemasukan;
  final List<ChartDataModel> chartData;

  const RekapLaporanModel({
    required this.totalBerkas,
    required this.totalSelesai,
    required this.totalProses,
    required this.pemasukan,
    required this.chartData,
  });

  factory RekapLaporanModel.fromJson(Map<String, dynamic> json) {
    final rawChart = json['chart_data'] as List? ?? [];
    return RekapLaporanModel(
      totalBerkas: (json['total_berkas'] ?? 0) as int,
      totalSelesai: (json['total_selesai'] ?? 0) as int,
      totalProses: (json['total_proses'] ?? 0) as int,
      pemasukan: ((json['pemasukan'] ?? 0) as num).toDouble(),
      chartData: rawChart
          .map((e) => ChartDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ============================================================
  // ✅ Dipakai buat /api/v1/generate/report/PPAT — balikin ARRAY
  // transaksi mentah, bukan object aggregate. Flutter yang hitung
  // total/chart-nya sendiri di sini.
  //
  // 🔧 CATATAN: backend belum filter by start_date/end_date
  // (parameter itu cuma divalidasi format-nya, tidak dipakai query),
  // jadi di sini SEMUA data yang balik dari API langsung dihitung
  // apa adanya — TIDAK difilter ulang berdasarkan tanggal di Flutter.
  // Begitu backend sudah filter beneran, endpoint ini otomatis
  // akan balikin data yang sudah sesuai periode dari server.
  // ============================================================
  factory RekapLaporanModel.fromPpatTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final items = rawList.whereType<Map<String, dynamic>>().toList();

    final totalBerkas = items.length;

    // 🔧 ASUMSI: status "done" = Selesai, selain itu (pending/dll) = Proses.
    final totalSelesai =
        items.where((e) => (e['status']?.toString() ?? '') == 'done').length;
    final totalProses = totalBerkas - totalSelesai;

    // 🔧 ASUMSI: pemasukan cuma dihitung dari transaksi yang statusnya "done".
    double pemasukan = 0;
    for (var item in items) {
      if ((item['status']?.toString() ?? '') == 'done') {
        pemasukan += ((item['amount'] ?? 0) as num).toDouble();
      }
    }

    // Agregasi per bulan (label Indonesia), urut kronologis
    const monthLabels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final Map<String, double> monthlyTotals = {};
    for (var item in items) {
      final created = _parseDDMMYYYY(item['created_at']?.toString());
      if (created == null) continue;
      final label = monthLabels[created.month - 1];
      final amount = ((item['amount'] ?? 0) as num).toDouble();
      monthlyTotals[label] = (monthlyTotals[label] ?? 0) + amount;
    }
    final chartData = monthLabels
        .where((label) => monthlyTotals.containsKey(label))
        .map((label) => ChartDataModel(label: label, value: monthlyTotals[label]!))
        .toList();

    return RekapLaporanModel(
      totalBerkas: totalBerkas,
      totalSelesai: totalSelesai,
      totalProses: totalProses,
      pemasukan: pemasukan,
      chartData: chartData,
    );
  }

  // ============================================================
  // ✅ Dipakai buat /api/v1/generate/report/Notaris — logic sama
  // persis dengan fromPpatTransactionList, dipisah namanya biar
  // jelas dipakai untuk endpoint Notaris.
  //
  // 🔧 ASUMSI: struktur response Notaris sama dengan PPAT (amount,
  // case_name, status, created_at, dst). Kalau ternyata field-nya
  // beda, kirim contoh response-nya biar mapping-nya disesuaikan.
  // ============================================================
  factory RekapLaporanModel.fromNotarisTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return RekapLaporanModel.fromPpatTransactionList(
      rawList,
      startDate: startDate,
      endDate: endDate,
    );
  }

  static DateTime? _parseDDMMYYYY(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final dd = int.tryParse(parts[0]);
    final mm = int.tryParse(parts[1]);
    final yyyy = int.tryParse(parts[2]);
    if (dd == null || mm == null || yyyy == null) return null;
    return DateTime(yyyy, mm, dd);
  }
}

class ChartDataModel {
  final String label;
  final double value;

  const ChartDataModel({
    required this.label,
    required this.value,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label']?.toString() ?? '',
      value: ((json['value'] ?? 0) as num).toDouble(),
    );
  }
}