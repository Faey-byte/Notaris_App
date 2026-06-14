import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  Widget _buildIconWithBadge(Icon icon) {
    final notifController = Get.find<NotificationController>();
    return Obx(() {
      final count = notifController.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          if (count > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF913632),
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedLabelStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 12,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Notaris",
        ),
        // PPAT — dengan badge notif
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(const Icon(Icons.insert_drive_file_outlined)),
          activeIcon: _buildIconWithBadge(const Icon(Icons.insert_drive_file)),
          label: "PPAT",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          activeIcon: Icon(Icons.calculate),
          label: "Kalkulator",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_sharp),
          activeIcon: Icon(Icons.account_circle),
          label: "Laporan",
        ),
      ],
    );
  }
}