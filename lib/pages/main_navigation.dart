import 'package:flutter/material.dart';
import 'package:test23/data/user_account_data.dart';

// Import 5 Halaman Utama
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/tracking/halaman_tracking.dart';
import 'package:test23/pages/akun/halaman_akun.dart';

// Import Widget Umum
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  // ⚠️ Wajib ada: Helper static agar halaman anak bisa memicu perpindahan tab utama
  static void jumpToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationPageState>();
    state?.switchToTab(index);
  }

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Pengecekan hak akses Guest sebelum pindah ke tab tertentu
  bool _canNavigateToTab(int targetIndex) {
    if (targetIndex == 3 && UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Fitur Tracking Sampah Memerlukan Akun',
        message:
            'Pelacakan sampah daur ulang, grafik analitik, dan perolehan poin hanya dapat digunakan setelah Anda masuk atau membuat akun.',
        icon: Icons.query_stats_rounded,
      );
      return false;
    }
    return true;
  }

  // ⚠️ Wajib ada: Method publik untuk mengontrol perpindahan halaman dari luar/dalam
  void switchToTab(int index) {
    if (!_canNavigateToTab(index)) return;

    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Dipanggil saat ikon menu di TrashBottomNav ditekan
  void _onNavTapped(int index) {
    switchToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(), // Pemaksaan gestur swipe PageView tetap aktif
        onPageChanged: (index) {
          // Membatasi swipe jika user Guest mencoba masuk ke Tracking (Index 3)
          if (!_canNavigateToTab(index)) {
            _pageController.jumpToPage(_currentIndex);
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HalamanBeranda(),  // Index 0
          HalamanProduk(),   // Index 1
          HalamanKonten(),   // Index 2
          HalamanTracking(), // Index 3
          HalamanAkun(),     // Index 4
        ],
      ),

      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}