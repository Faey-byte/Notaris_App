import 'package:flutter/material.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'stat_card_widget.dart';

class StatGridWidget extends StatelessWidget {
  final int totalBerkas;
  final int totalSelesai;
  final int totalProses;
  final String pemasukan;

  const StatGridWidget({
    super.key,
    required this.totalBerkas,
    required this.totalSelesai,
    required this.totalProses,
    required this.pemasukan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                label: 'Total Berkas',
                value: '$totalBerkas',
                icon: Icons.folder_outlined,
                iconColor: AppColors.statusProses,
                iconBgColor: AppColors.statusProsesBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                label: 'Total Selesai',
                value: '$totalSelesai',
                icon: Icons.check_circle_outline,
                iconColor: AppColors.statusSelesai,
                iconBgColor: AppColors.statusSelesaiBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCardWidget(
                label: 'Total Proses',
                value: '$totalProses',
                icon: Icons.pending_outlined,
                iconColor: AppColors.statusProses,
                iconBgColor: AppColors.statusProsesBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCardWidget(
                label: 'Pemasukan',
                value: pemasukan,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primarySoft,
                isHighlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
