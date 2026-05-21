import 'package:flutter/material.dart';
import 'package:notaris_app/utils/app_colors.dart';
enum JenisLayanan { notaris, ppat }

class JenisLayananToggle extends StatelessWidget {
  final JenisLayanan selected;
  final ValueChanged<JenisLayanan> onChanged;

  const JenisLayananToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Layanan',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ToggleItem(
                  label: 'Notaris',
                  isSelected: selected == JenisLayanan.notaris,
                  onTap: () => onChanged(JenisLayanan.notaris),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
              ),
              Expanded(
                child: _ToggleItem(
                  label: 'PPAT',
                  isSelected: selected == JenisLayanan.ppat,
                  onTap: () => onChanged(JenisLayanan.ppat),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.white,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
