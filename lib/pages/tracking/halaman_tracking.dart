import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/models/tracking_setor_model.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/main_navigation.dart';
import 'package:test23/widgets/tracking/card_banner_peta_cabang.dart';
import 'package:test23/widgets/tracking/card_estimasi_berat.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';
import 'package:test23/widgets/tracking/grid_kategori_setor.dart';
import 'package:test23/widgets/tracking/modal_keranjang_setor.dart';
import 'package:test23/widgets/tracking/section_riwayat_pengajuan.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/tr4sh_brand_logo.dart';

class HalamanTracking extends StatefulWidget {
  const HalamanTracking({super.key});

  @override
  State<HalamanTracking> createState() => _HalamanTrackingState();
}

class _HalamanTrackingState extends State<HalamanTracking> {
  int _selectedIdKategori = 1;
  String _selectedCategory = 'Plastik';
  double _hargaPerKg = 3000.0;

  bool _isLoading = true;
  List<PengajuanSetorModel> _listSampah = [];
  int _totalCount = 0;

  String _selectedTabStatus = 'semua';
  bool _showAllRiwayat = false;

  List<KategoriSampahModel> _daftarKategoriDatabase = [];

  @override
  void initState() {
    super.initState();
    _loadDataAwal();
  }

  Future<void> _loadDataAwal() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await Future.wait([
      _loadRiwayatSampah(),
      _loadKategoriDatabase(),
    ]);
  }

  Future<void> _loadRiwayatSampah() async {
    if (UserAccountData.isGuest) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalCount = 0;
          _listSampah = [];
        });
      }
      return;
    }

    try {
      final res = await ApiService.fetchRiwayatSetor();
      if (res.success && mounted) {
        List<dynamic> rawItems = [];
        int total = 0;

        if (res.data is Map) {
          final dataMap = Map<String, dynamic>.from(res.data as Map);
          rawItems =
              (dataMap['items'] is List) ? (dataMap['items'] as List) : [];
          total = int.tryParse(dataMap['total']?.toString() ?? '') ??
              rawItems.length;
        } else if (res.data is List) {
          rawItems = res.data as List;
          total = rawItems.length;
        }

        final parsedItems = rawItems
            .whereType()
            .map(
              (e) => PengajuanSetorModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

        setState(() {
          _listSampah = parsedItems;
          _totalCount = total;
          _isLoading = false;
          UserAccountData.isNewAccount = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _totalCount = UserAccountData.totalSetoran;
      });
    }
  }

  Future<void> _loadKategoriDatabase() async {
    try {
      final res = await ApiService.fetchKategoriSampah();
      if (res.success && res.data is List && mounted) {
        final parsedKategori = (res.data as List)
            .whereType()
            .map(
              (e) => KategoriSampahModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

        setState(() {
          _daftarKategoriDatabase = parsedKategori;
        });
      }
    } catch (_) {}
  }

  void _handleInputSampah(double initialWeight, double initialRupiah) {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Jual Sampah Memerlukan Akun',
        message:
            'Mode Tamu tidak dapat melakukan pengajuan penjualan sampah ke bank sampah. Silakan masuk terlebih dahulu.',
        icon: Icons.recycling_rounded,
      );
      return;
    }

    final int? activeUserId = UserAccountData.currentUserId;
    if (activeUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi akun tidak ditemukan. Silakan masuk kembali.'),
        ),
      );
      return;
    }

    ModalKeranjangSetor.show(
      context: context,
      activeUserId: activeUserId,
      initialIdKategori: _selectedIdKategori,
      initialCategory: _selectedCategory,
      initialWeight: initialWeight,
      hargaPerKg: _hargaPerKg,
      daftarKategoriDatabase: _daftarKategoriDatabase,
      onSuccess: _loadRiwayatSampah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedList =
        _listSampah.where((item) => item.isAccepted).toList();
    final double acceptedTotalKg =
        acceptedList.fold(0.0, (sum, item) => sum + item.jumlah);
    final int acceptedCount = acceptedList.length;

    final bool isZeroState =
        UserAccountData.isGuest || UserAccountData.isNewAccount;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDataAwal,
          color: AppColors.darkGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                _buildHeader(),
                const SizedBox(height: 16),
                if (UserAccountData.isGuest) ...[
                  _buildGuestBanner(),
                  const SizedBox(height: 16),
                ],
                const CardBannerPetaCabang(),
                const SizedBox(height: 16),
                CardTrackingChart(
                  totalDisetor: isZeroState
                      ? '0.0 kg'
                      : '${acceptedTotalKg > 0 ? acceptedTotalKg.toStringAsFixed(1) : '0.0'} kg',
                  trendPercent: isZeroState
                      ? '+0 setoran'
                      : '+$acceptedCount setoran tercatat',
                  rawData: isZeroState
                      ? const []
                      : acceptedList.map((e) => e.toMap()).toList(),
                ),
                const SizedBox(height: 16),
                CardEstimasiBerat(
                  categoryName: _selectedCategory,
                  hargaPerKg: _hargaPerKg,
                  onInputSampah: _handleInputSampah,
                ),
                const SizedBox(height: 20),
                GridKategoriSetor(
                  onCategorySelected: (idKategori, title, unit, weight, harga) {
                    setState(() {
                      _selectedIdKategori = idKategori;
                      _selectedCategory = title;
                      _hargaPerKg = harga;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SectionRiwayatPengajuan(
                  isLoading: _isLoading,
                  totalCount: _totalCount,
                  listSampah: _listSampah,
                  selectedTabStatus: _selectedTabStatus,
                  showAllRiwayat: _showAllRiwayat,
                  onTabChanged: (statusKey) {
                    setState(() {
                      _selectedTabStatus = statusKey;
                      _showAllRiwayat = false;
                    });
                  },
                  onToggleShowAll: () {
                    setState(() {
                      _showAllRiwayat = !_showAllRiwayat;
                    });
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Tr4shBrandLogo(subtitle: 'TRACKING'),
          GestureDetector(
            onTap: () => MainNavigationPage.jumpToTab(context, 4),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFD6F3DD),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.darkGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF856404),
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Tamu: Fitur Terkunci',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Color(0xFF856404),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Masuk ke akun Anda untuk mencatat setoran dan memantau status pengantaran.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF856404)),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
              );
            },
            child: const Text(
              'Masuk',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}