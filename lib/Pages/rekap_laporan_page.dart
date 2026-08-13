import 'package:flutter/material.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Widget/app_bottom_navbar.dart';
import 'package:notaris_app/Widget/Laporan/export_pdf_button.dart';
import 'package:notaris_app/Widget/Laporan/filter_laporan_card.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart';
import 'package:notaris_app/Widget/Laporan/rekap_laporan_app_bar.dart';
import 'package:notaris_app/Widget/Laporan/stat_grid_widget.dart';
import 'package:notaris_app/Widget/Laporan/visualisasi_section.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:notaris_app/utils/currency_formatter.dart';
import 'package:notaris_app/utils/main_nav_handler.dart';

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
      appBar: RekapLaporanAppBar(onBack: onBack),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: MainNavHandler.handleTap,
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
          pemasukan: CurrencyFormatter.formatPemasukan(data.pemasukan),
        ),
        const SizedBox(height: 16),
        VisualisasiSection(chartData: data.chartData),
        const SizedBox(height: 24),
        ExportPdfButton(onTap: onExportPdf),
        const SizedBox(height: 16),
      ],
    );
  }
}
