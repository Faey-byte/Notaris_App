import 'package:flutter/material.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Pages/rekap_laporan_page.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart';

class RekapLaporanController extends StatefulWidget {
  const RekapLaporanController({super.key});

  @override
  State<RekapLaporanController> createState() => _RekapLaporanControllerState();
}

class _RekapLaporanControllerState extends State<RekapLaporanController> {
  JenisLayanan _jenisLayanan = JenisLayanan.notaris;
  DateTime _tanggalAwal = DateTime(2021, 4, 11);
  DateTime _tanggalAkhir = DateTime(2022, 4, 30);

  final RekapLaporanModel _notarisData = const RekapLaporanModel(
    totalBerkas: 124,
    totalSelesai: 98,
    totalProses: 26,
    pemasukan: 45200000,
    chartData: [
      ChartDataModel(label: 'Jan', value: 20),
      ChartDataModel(label: 'Feb', value: 45),
      ChartDataModel(label: 'Mar', value: 30),
      ChartDataModel(label: 'Apr', value: 80),
      ChartDataModel(label: 'Mei', value: 55),
      ChartDataModel(label: 'Jun', value: 70),
    ],
  );

  final RekapLaporanModel _ppatData = const RekapLaporanModel(
    totalBerkas: 182,
    totalSelesai: 79,
    totalProses: 103,
    pemasukan: 4700000,
    chartData: [
      ChartDataModel(label: 'Jan', value: 15),
      ChartDataModel(label: 'Feb', value: 60),
      ChartDataModel(label: 'Mar', value: 40),
      ChartDataModel(label: 'Apr', value: 90),
      ChartDataModel(label: 'Mei', value: 35),
      ChartDataModel(label: 'Jun', value: 50),
    ],
  );

  RekapLaporanModel get _currentData =>
      _jenisLayanan == JenisLayanan.notaris ? _notarisData : _ppatData;

  void _onJenisLayananChanged(JenisLayanan val) {
    setState(() => _jenisLayanan = val);
  }

  Future<void> _onTanggalAwalTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAwal,
      firstDate: DateTime(2000),
      lastDate: _tanggalAkhir,
    );
    if (picked != null) {
      setState(() => _tanggalAwal = picked);
    }
  }

  Future<void> _onTanggalAkhirTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAkhir,
      firstDate: _tanggalAwal,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggalAkhir = picked);
    }
  }

  void _onExportPdf() {
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm/$dd/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return RekapLaporanPage(
      data: _currentData,
      tanggalAwal: _formatDate(_tanggalAwal),
      tanggalAkhir: _formatDate(_tanggalAkhir),
      jenisLayanan: _jenisLayanan,
      onJenisLayananChanged: _onJenisLayananChanged,
      onTanggalAwalTap: _onTanggalAwalTap,
      onTanggalAkhirTap: _onTanggalAkhirTap,
      onExportPdf: _onExportPdf,
      onBack: () => Navigator.pop(context), currentIndex: 0,
    );
  }
}
