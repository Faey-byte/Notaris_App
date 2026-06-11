import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'package:notaris_app/Pages/Notaris_Page.dart';
import 'package:notaris_app/Pages/Ppat_Page.dart';
import 'package:notaris_app/Pages/Calculator_Page.dart';
import 'package:notaris_app/Widget/App_Bottom_Navbar.dart';
import 'package:notaris_app/Widget/Laporan/export_pdf_button.dart';
import 'package:notaris_app/Widget/Laporan/filter_laporan_card.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart';
import 'package:notaris_app/Widget/Laporan/stat_grid_widget.dart';
import 'package:notaris_app/Widget/Laporan/visualisasi_data_chart.dart';
import 'package:notaris_app/utils/app_colors.dart';

class RekapLaporanPage extends StatelessWidget {
  final RekapLaporanModel data;
  final String tanggalAwal;
  final String tanggalAkhir;
  final JenisLayanan jenisLayanan;
  final ValueChanged<JenisLayanan> onJenisLayananChanged;
  final VoidCallback? onTanggalAwalTap;
  final VoidCallback? onTanggalAkhirTap;
  final VoidCallback? onExportPdf;
  final VoidCallback? onBack;
  final int currentIndex;
  final ValueChanged<int>? onNavTap;

  const RekapLaporanPage({
    super.key,
    required this.data,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.jenisLayanan,
    required this.onJenisLayananChanged,
    required this.currentIndex,
    this.onNavTap,
    this.onTanggalAwalTap,
    this.onTanggalAkhirTap,
    this.onExportPdf,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAll(() => HomePage());
              break;
            case 1:
              Get.offAll(() => NotarisPage());
              break;
            case 2:
              Get.offAll(() => PpatPage());
              break;
            case 3:
              Get.offAll(() => CalculatorPage());
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: onBack,
      ),
      title: const Text(
        'Rekap Laporan',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilterLaporanCard(
          tanggalAwal: tanggalAwal,
          tanggalAkhir: tanggalAkhir,
          jenisLayanan: jenisLayanan,
          onJenisLayananChanged: onJenisLayananChanged,
          onTanggalAwalTap: onTanggalAwalTap,
          onTanggalAkhirTap: onTanggalAkhirTap,
        ),
        const SizedBox(height: 16),
        StatGridWidget(
          totalBerkas: data.totalBerkas,
          totalSelesai: data.totalSelesai,
          totalProses: data.totalProses,
          pemasukan: _formatPemasukan(data.pemasukan),
        ),
        const SizedBox(height: 16),
        _buildVisualisasiSection(),
        const SizedBox(height: 24),
        ExportPdfButton(onTap: onExportPdf),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVisualisasiSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VISUALISASI DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          VisualisasiDataChart(data: data.chartData),
        ],
      ),
    );
  }

  String _formatPemasukan(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      final formatted = m % 1 == 0
          ? m.toStringAsFixed(0)
          : m.toStringAsFixed(1);
      return 'Rp ${formatted}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return 'Rp ${k.toStringAsFixed(0)}K';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}
