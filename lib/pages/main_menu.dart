import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'input_penjualan_page.dart';
import 'stok_page.dart';
import 'laporan_harian_page.dart';
import 'manajemen_user_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _index = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const InputPenjualanPage(),
    const StokPage(),
    const LaporanHarianPage(),
    const ManajemenUserPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Jual"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Stok"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Laporan"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "User"),
        ],
      ),
    );
  }
}
