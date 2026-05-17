import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Pages/detail_berkas_ppat.dart';

class BerkasCard extends StatelessWidget {
  final dynamic data;

  const BerkasCard({super.key, required this.data});

  _StatusStyle _getStatusStyle(String status) {
    switch (status) {
      case "PROSES":
        return _StatusStyle(
            "PROSES BPN", const Color(0xFFFF9800), const Color(0xFFFFF3E0));
      case "SELESAI":
        return _StatusStyle(
            "SELESAI", const Color(0xFF4CAF50), const Color(0xFFE8F5E9));
      case "REVISI":
        return _StatusStyle(
            "REVISI PAJAK", const Color(0xFFF44336), const Color(0xFFFFEBEE));
      default:
        return _StatusStyle(
            status, const Color(0xFF9E9E9E), const Color(0xFFF5F5F5));
    }
  }

  IconData _getJenisIcon(String jenis) {
    switch (jenis) {
      case "AJB":
        return Icons.swap_horiz_rounded;
      case "Hibah":
        return Icons.card_giftcard_rounded;
      case "APHT":
        return Icons.account_balance_rounded;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle(data.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "No. Berkas: ${data.no}",
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(style: style),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),

            Row(
              children: [
                Icon(_getJenisIcon(data.jenis),
                    size: 16, color: const Color(0xFF888888)),
                const SizedBox(width: 6),
                Text(data.jenis,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Color(0xFF888888)),
                const SizedBox(width: 6),
                Text(data.tanggal,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF555555))),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _AvatarIcon(icon: Icons.person_outline),
                    if (data.status == "PROSES") ...[
                      const SizedBox(width: 4),
                      _AvatarIcon(icon: Icons.person_outline),
                    ],
                    if (data.jenis == "APHT") ...[
                      const SizedBox(width: 4),
                      _AvatarIcon(icon: Icons.business_outlined),
                    ],
                  ],
                ),

                _DetailButton(
                  onTap: () {
                    Get.to(() => DetailBerkasPage(data: data));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _StatusStyle style;
  const _StatusBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final IconData icon;
  const _AvatarIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF888888)),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Row(
        children: [
          Text(
            "Detail",
            style: TextStyle(
              color: Color(0xFF8B1A1A),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right, size: 18, color: Color(0xFF8B1A1A)),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color textColor;
  final Color bgColor;
  _StatusStyle(this.label, this.textColor, this.bgColor);
}