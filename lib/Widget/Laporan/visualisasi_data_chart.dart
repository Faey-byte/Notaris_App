import 'package:flutter/material.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class VisualisasiDataChart extends StatelessWidget {
  final List<ChartDataModel> data;
  final double height;

  const VisualisasiDataChart({
    super.key,
    required this.data,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    const double maxBarWidth = 56;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Sisakan ruang untuk teks nilai (atas) + spacing + label (bawah)
                const double reservedForText = 44;
                final double barMaxHeight =
                    (constraints.maxHeight - reservedForText).clamp(0.0, double.infinity);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: data.length <= 3
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceEvenly,
                  children: data.map((item) {
                    final ratio = maxValue > 0 ? item.value / maxValue : 0.0;
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxBarWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _BarItem(
                          label: item.label,
                          value: item.value,
                          heightRatio: ratio,
                          maxHeight: barMaxHeight,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.only(top: 4),
            color: AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double value;
  final double heightRatio;
  final double maxHeight;

  const _BarItem({
    required this.label,
    required this.value,
    required this.heightRatio,
    required this.maxHeight,
  });

  String _formatValue(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return m % 1 == 0 ? '${m.toStringAsFixed(0)}Jt' : '${m.toStringAsFixed(1)}Jt';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}Rb';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatValue(value),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}