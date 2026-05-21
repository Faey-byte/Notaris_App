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
}

class ChartDataModel {
  final String label;
  final double value;

  const ChartDataModel({
    required this.label,
    required this.value,
  });
}
