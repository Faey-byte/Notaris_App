import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class DetailDropdownCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color backgroundColor;
  final Color textColor;

  const DetailDropdownCard({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.items,
    required this.onChanged,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          PopupMenuButton<String>(
            onSelected: onChanged,
            itemBuilder: (context) => items.map((String val) {
              return PopupMenuItem<String>(
                value: val,
                child: Text(val, style: const TextStyle(color: AppColors.textPrimary)),
              );
            }).toList(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentValue,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}