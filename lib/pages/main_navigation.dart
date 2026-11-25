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

  // Helper static agar halaman tab maupun sub-halaman (Navigator.push) bisa memicu pindah tab
  static void jumpToTab(BuildContext context, int index) {
    final ancestorState =
        context.findAncestorStateOfType<_MainNavigationPageState>();
    final state = ancestorState ?? _MainNavigationPageState._activeState;
    if (state != null && state.mounted) {
      state.switchToTab(index, immediate: ancestorState == null);
    }
  }

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  static _MainNavigationPageState? _activeState;

  late final PageController _pageController;
  int _currentIndex = 0;

  // Simpan instance halaman sekali saja agar tidak dibuat ulang
  final List<Widget> _pages = const [
    _KeepAlivePage(child: HalamanBeranda()),  // Index 0
    _KeepAlivePage(child: HalamanProduk()),   // Index 1
    _KeepAlivePage(child: HalamanKonten()),   // Index 2
    _KeepAlivePage(child: HalamanTracking()), // Index 3
    _KeepAlivePage(child: HalamanAkun()),     // Index 4
  ];

  @override
  void initState() {
    super.initState();
    _activeState = this;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    if (_activeState == this) {
      _activeState = null;
    }
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

  // Method publik untuk mengontrol perpindahan halaman dari luar/dalam
  void switchToTab(int index, {bool immediate = false}) {
    if (index == _currentIndex) return;
    if (!_canNavigateToTab(index)) return;

    final int distance = (index - _currentIndex).abs();

    setState(() {
      _currentIndex = index;
    });

    if (!_pageController.hasClients) return;

    // Jika dari sub-halaman (Navigator.push) atau lompat > 1 tab, langsung jumpToPage
    // agar tidak bentrok dengan animasi pop halaman
    if (immediate || distance > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onNavTapped(int index) {
    switchToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    _activeState = this;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const PageScrollPhysics(),
        onPageChanged: (index) {
          if (!_canNavigateToTab(index)) {
            _pageController.jumpToPage(_currentIndex);
            return;
          }

          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

/// Wrapper agar setiap tab di dalam PageView tetap hidup di memori (tidak rebuild/glitch)
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}