import 'package:flutter/material.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'date_range_filter_widget.dart';
import 'jenis_layanan_toggle.dart';

class FilterLaporanCard extends StatelessWidget {
  final String tanggalAwal;
  final String tanggalAkhir;
  final JenisLayanan jenisLayanan;
  final ValueChanged<JenisLayanan> onJenisLayananChanged;
  final VoidCallback? onTanggalAwalTap;
  final VoidCallback? onTanggalAkhirTap;

  const FilterLaporanCard({
    super.key,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.jenisLayanan,
    required this.onJenisLayananChanged,
    this.onTanggalAwalTap,
    this.onTanggalAkhirTap,
  });

  @override
  Widget build(BuildContext context) {
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
            'FILTER LAPORAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          DateRangeFilterWidget(
            tanggalAwal: tanggalAwal,
            tanggalAkhir: tanggalAkhir,
            onTanggalAwalTap: onTanggalAwalTap,
            onTanggalAkhirTap: onTanggalAkhirTap,
          ),
          const SizedBox(height: 12),
          JenisLayananToggle(
            selected: jenisLayanan,
            onChanged: onJenisLayananChanged,
          ),
        ],
      ),
    );
  }
}
