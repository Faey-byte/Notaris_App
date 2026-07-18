import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/Model/Notifikasi_Model.dart';
import 'package:notaris_app/utils/app_colors.dart';

class NotifikasiCardWidget extends StatelessWidget {
  final NotifikasiModel data;
  final VoidCallback onTap;

  const NotifikasiCardWidget({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: data.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon berdasarkan tipe notifikasi
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconBgColor(data.type),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconData(data.type), size: 20, color: _getIconColor(data.type)),
            ),
            const SizedBox(width: 14),
            
            // Konten teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: data.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _formatTime(data.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: data.isRead ? AppColors.textSecondary : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods untuk styling dinamis ---
  IconData _getIconData(String type) {
    switch (type) {
      case 'berkas': return Icons.insert_drive_file_outlined;
      case 'pembayaran': return Icons.account_balance_wallet_outlined;
      default: return Icons.notifications_none_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'berkas': return AppColors.primary;
      case 'pembayaran': return Colors.green;
      default: return Colors.orange;
    }
  }

  Color _getIconBgColor(String type) {
    return _getIconColor(type).withOpacity(0.1);
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m yang lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}j yang lalu";
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}