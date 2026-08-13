import 'package:flutter/material.dart';
import 'package:notaris_app/utils/app_colors.dart';

class DateRangeFilterWidget extends StatelessWidget {
  final String tanggalAwal;
  final String tanggalAkhir;
  final VoidCallback? onTanggalAwalTap;
  final VoidCallback? onTanggalAkhirTap;

  const DateRangeFilterWidget({
    super.key,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    this.onTanggalAwalTap,
    this.onTanggalAkhirTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateInputField(
            label: 'Tanggal Awal',
            value: tanggalAwal,
            onTap: onTanggalAwalTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateInputField(
            label: 'Tanggal Akhir',
            value: tanggalAkhir,
            onTap: onTanggalAkhirTap,
          ),
        ),
      ],
    );
  }
}

class _DateInputField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DateInputField({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
