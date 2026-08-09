import 'package:flutter/material.dart';
import 'package:notaris_app/Widget/Laporan/visualisasi_data_chart.dart';
import 'package:notaris_app/utils/app_colors.dart';

class VisualisasiSection extends StatelessWidget {
  final dynamic chartData;

  const VisualisasiSection({super.key, required this.chartData});

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
            'VISUALISASI DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          VisualisasiDataChart(data: chartData),
        ],
      ),
    );
  }
}