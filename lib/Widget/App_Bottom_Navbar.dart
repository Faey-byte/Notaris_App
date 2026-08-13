import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF913632),
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 12,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Notaris",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_drive_file_outlined),
          activeIcon: Icon(Icons.insert_drive_file),
          label: "PPAT",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          activeIcon: Icon(Icons.calculate),
          label: "Kalkulator",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_sharp),
          activeIcon: Icon(Icons.account_circle),
          label: "Laporan",
        ),
      ],
    );
  }
}
