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

  factory RekapLaporanModel.fromPpatTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final items = rawList.whereType<Map<String, dynamic>>().toList();

    final totalBerkas = items.length;

    final totalSelesai = items
        .where((e) => (e['status']?.toString() ?? '') == 'done')
        .length;
    final totalProses = totalBerkas - totalSelesai;

    double pemasukan = 0;
    for (var item in items) {
      if ((item['status']?.toString() ?? '') == 'done') {
        pemasukan += ((item['amount'] ?? 0) as num).toDouble();
      }
    }

    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
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
        .map(
          (label) => ChartDataModel(label: label, value: monthlyTotals[label]!),
        )
        .toList();

    return RekapLaporanModel(
      totalBerkas: totalBerkas,
      totalSelesai: totalSelesai,
      totalProses: totalProses,
      pemasukan: pemasukan,
      chartData: chartData,
    );
  }

  factory RekapLaporanModel.fromNotarisTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var items = rawList.whereType<Map<String, dynamic>>().toList();

    if (startDate != null || endDate != null) {
      final start = startDate != null
          ? DateTime(startDate.year, startDate.month, startDate.day)
          : null;
      final end = endDate != null
          ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
          : null;

      items = items.where((item) {
        final created = _parseDDMMYYYY(item['created_at']?.toString());
        if (created == null) return false;
        if (start != null && created.isBefore(start)) return false;
        if (end != null && created.isAfter(end)) return false;
        return true;
      }).toList();
    }

    final totalBerkas = items.length;

    final totalSelesai = items
        .where((e) => (e['status']?.toString() ?? '') == 'done')
        .length;
    final totalProses = totalBerkas - totalSelesai;

    double pemasukan = 0;
    for (var item in items) {
      if ((item['status']?.toString() ?? '') == 'done') {
        pemasukan += ((item['amount'] ?? 0) as num).toDouble();
      }
    }

    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
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
        .map(
          (label) => ChartDataModel(label: label, value: monthlyTotals[label]!),
        )
        .toList();

    return RekapLaporanModel(
      totalBerkas: totalBerkas,
      totalSelesai: totalSelesai,
      totalProses: totalProses,
      pemasukan: pemasukan,
      chartData: chartData,
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

  const ChartDataModel({required this.label, required this.value});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label']?.toString() ?? '',
      value: ((json['value'] ?? 0) as num).toDouble(),
    );
  }
}
