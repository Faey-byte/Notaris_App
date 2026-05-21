import 'package:flutter/material.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class VisualisasiDataChart extends StatelessWidget {
  final List<ChartDataModel> data;
  final double height;

  const VisualisasiDataChart({
    super.key,
    required this.data,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final ratio = maxValue > 0 ? item.value / maxValue : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _BarItem(
                label: item.label,
                heightRatio: ratio,
                maxHeight: height - 20,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double heightRatio;
  final double maxHeight;

  const _BarItem({
    required this.label,
    required this.heightRatio,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              width: double.infinity,
              height: maxHeight * heightRatio.clamp(0.05, 1.0),
              decoration: BoxDecoration(
                color: heightRatio >= 0.8
                    ? AppColors.chartBar
                    : AppColors.chartBarSoft,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
