import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_akun.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/beranda/halaman_beranda.dart';
import 'package:test23/pages/konten/halaman_konten.dart';
import 'package:test23/pages/produk/halaman_produk.dart';
import 'package:test23/widgets/tracking/card_auto_track_lokasi.dart';
import 'package:test23/widgets/tracking/card_estimasi_berat.dart';
import 'package:test23/widgets/tracking/card_tracking_chart.dart';
import 'package:test23/widgets/tracking/grid_kategori_setor.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';
import 'package:test23/widgets/umum/bottom_nav_bar.dart';
import 'package:test23/widgets/umum/header_beranda.dart';

class HalamanTracking extends StatefulWidget {
  const HalamanTracking({super.key});

  @override
  State<HalamanTracking> createState() => _HalamanTrackingState();
}

class _HalamanTrackingState extends State<HalamanTracking> {
  final int _currentNavIndex = 3;

  int _selectedIdKategori = 1;
  String _selectedCategory = 'Plastik';
  double _hargaPerKg = 3500.0;

  bool _isLoading = true;
  var _listSampah = [];
  double _totalKg = 0.0;
  int _totalCount = 0;
  
  String _selectedTabStatus = 'semua';
  bool _showAllRiwayat = false;

  XFile? _pickedImage;
  final TextEditingController _customSampahController = TextEditingController();
  final TextEditingController _beratController = TextEditingController(text: '1.0');

  var _keranjangSetor = [];
  List<dynamic> _daftarKategoriDatabase = [];

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

  @override
  void dispose() {
    _customSampahController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayatSampah() async {
    if (UserAccountData.isGuest) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalKg = 0.0;
          _totalCount = 0;
          _listSampah = [];
        });
      }
      return;
    }

    try {
      final res = await ApiService.fetchRiwayatSetor();
      if (res.success && res.data is Map && mounted) {
        final dataMap = res.data as Map;
        final items = (dataMap['items'] is List) ? (dataMap['items'] as List) : [];
        final totalKg = (dataMap['total_kg'] is num) ? (dataMap['total_kg'] as num).toDouble() : 0.0;
        final totalCount = (dataMap['total'] is int) ? (dataMap['total'] as int) : items.length;

        setState(() {
          _listSampah = items;
          _totalKg = totalKg;
          _totalCount = totalCount;
          _isLoading = false;
          UserAccountData.isNewAccount = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _totalKg = UserAccountData.totalSampahKg;
        _totalCount = UserAccountData.totalSetoran;
      });
    }
  }

  Future<void> _loadKategoriDatabase() async {
    try {
      final res = await ApiService.fetchKategoriSampah();
      if (res.success && res.data is List && mounted) {
        setState(() {
          _daftarKategoriDatabase = res.data as List;
        });
      }
    } catch (_) {}
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi Pelacakan & Verifikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2EFE7)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFD6F5E1),
                    child: Icon(Icons.verified_user_rounded, color: Colors.green, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _listSampah.isNotEmpty
                          ? 'Terdapat ${_listSampah.length} permintaan jual sampah tercatat di sistem bank sampah.'
                          : 'Belum ada permintaan jual sampah yang dikirim.',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _handleInputSampah(double initialWeight, double initialRupiah) async {
    if (UserAccountData.isGuest) {
      AuthRequiredModal.show(
        context,
        title: 'Jual Sampah Memerlukan Akun',
        message: 'Mode Tamu tidak dapat melakukan penjualan sampah ke bank sampah. Silakan masuk terlebih dahulu.',
        icon: Icons.recycling_rounded,
      );
      return;
    }

    double roundedWeight = double.parse(initialWeight.toStringAsFixed(1));

    _keranjangSetor = [
      {
        'id_kategori': _selectedIdKategori,
        'nama_kategori': _selectedCategory,
        'jenis_sampah': '$_selectedCategory ${roundedWeight.toStringAsFixed(1)} kg',
        'jumlah': roundedWeight,
        'satuan': 'kg',
        'harga_per_kg': _hargaPerKg,
      }
    ];

    setState(() {
      _pickedImage = null;
      _customSampahController.clear();
      _beratController.text = roundedWeight.toStringAsFixed(1);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keranjang Jual Sampah',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                    ),
                    Text(
                      'Multi-Kategori',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.darkGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Daftar Sampah Ramah Lingkungan yang Akan Disetor:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _keranjangSetor.length,
                  itemBuilder: (context, idx) {
                    final item = _keranjangSetor[idx] as Map<String, dynamic>;
                    double itemWeight = (item['jumlah'] as num).toDouble();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item['nama_kategori']}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        if (itemWeight > 0.1) {
                                          double newW = double.parse((itemWeight - 0.1).toStringAsFixed(1));
                                          item['jumlah'] = newW;
                                          item['jenis_sampah'] = '${item['nama_kategori']} ${newW.toStringAsFixed(1)} kg';
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  
                                  GestureDetector(
                                    onTap: () {
                                      TextEditingController editCtrl = TextEditingController(
                                        text: itemWeight.toStringAsFixed(1),
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Edit Berat (${item['nama_kategori']})'),
                                          content: TextField(
                                            controller: editCtrl,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              suffixText: 'kg',
                                              hintText: 'Contoh: 1.5',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
                                              onPressed: () {
                                                double? val = double.tryParse(editCtrl.text);
                                                if (val != null && val > 0) {
                                                  double roundedVal = double.parse(val.toStringAsFixed(1));
                                                  setModalState(() {
                                                    item['jumlah'] = roundedVal;
                                                    item['jenis_sampah'] = '${item['nama_kategori']} ${roundedVal.toStringAsFixed(1)} kg';
                                                  });
                                                }
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '${itemWeight.toStringAsFixed(1)} kg',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                      ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        double newW = double.parse((itemWeight + 0.1).toStringAsFixed(1));
                                        item['jumlah'] = newW;
                                        item['jenis_sampah'] = '${item['nama_kategori']} ${newW.toStringAsFixed(1)} kg';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                  if (_keranjangSetor.length > 1) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          _keranjangSetor.removeAt(idx);
                                        });
                                      },
                                      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkGreen,
                    side: const BorderSide(color: AppColors.darkGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        String searchQuery = '';
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            final filteredCategories = _daftarKategoriDatabase.where((cat) {
                              final nama = (cat['nama_kategori'] ?? '').toString().toLowerCase();
                              return nama.contains(searchQuery.toLowerCase());
                            }).toList();

                            return AlertDialog(
                              title: const Text('Pilih Kategori Ramah Lingkungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      autofocus: false,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Cari kategori sampah...',
                                        prefixIcon: const Icon(Icons.search, color: AppColors.darkGreen),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.cardBorder),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Flexible(
                                      child: _daftarKategoriDatabase.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Center(child: CircularProgressIndicator(color: AppColors.darkGreen)),
                                            )
                                          : filteredCategories.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Text('Kategori tidak ditemukan', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: filteredCategories.length,
                                                  itemBuilder: (context, index) {
                                                    final cat = filteredCategories[index] as Map<String, dynamic>;
                                                    final namaKat = cat['nama_kategori']?.toString() ?? 'Kategori';
                                                    final idKat = cat['id_kategori'] is int ? cat['id_kategori'] : int.tryParse(cat['id_kategori'].toString()) ?? 1;
                                                    final hargaKat = cat['harga_per_kg'] is num ? (cat['harga_per_kg'] as num).toDouble() : 3000.0;

                                                    return ListTile(
                                                      title: Text(namaKat, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      subtitle: Text('Rp ${hargaKat.toStringAsFixed(0)} / kg'),
                                                      onTap: () {
                                                        Navigator.pop(context);

                                                        setModalState(() {
                                                          int existingIndex = _keranjangSetor.indexWhere(
                                                            (element) => element['nama_kategori'].toString().toLowerCase() == namaKat.toLowerCase()
                                                          );

                                                          if (existingIndex != -1) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Kategori "$namaKat" sudah ada di keranjang!')),
                                                            );
                                                          } else {
                                                            _keranjangSetor.add({
                                                              'id_kategori': idKat,
                                                              'nama_kategori': namaKat,
                                                              'jenis_sampah': '$namaKat 1.0 kg',
                                                              'jumlah': 1.0,
                                                              'satuan': 'kg',
                                                              'harga_per_kg': hargaKat,
                                                            });
                                                          }
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Kategori Sampah Lain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 16),

                const Text('Bukti Foto Fisik Sampah Gabungan (Wajib):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if (pickedFile != null) {
                      setModalState(() {
                        _pickedImage = pickedFile;
                      });
                    }
                  },
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(_pickedImage!.path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : Image.file(File(_pickedImage!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt_rounded, color: AppColors.darkGreen, size: 26),
                              SizedBox(height: 4),
                              Text('Ketuk untuk Ambil 1 Foto Gabungan Semua Sampah', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (_pickedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap lampirkan foto bukti fisik gabungan sampah terlebih dahulu!')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(color: AppColors.darkGreen),
                        ),
                      );

                      final itemsPayload = _keranjangSetor.map((e) => {
                        'id_kategori': e['id_kategori'],
                        'jenis_sampah': e['jenis_sampah'],
                        'jumlah': e['jumlah'],
                        'satuan': e['satuan'] ?? 'kg',
                      }).toList();

                      final res = await ApiService.kirimSetorSampahMultipart(
                        idUser: UserAccountData.currentUserId ?? 1,
                        items: itemsPayload,
                        sumber: 'Auto-Track Titik Jemput: ${LokasiTrackingService.currentAddress}',
                        fotoFile: _pickedImage,
                      );

                      if (mounted) Navigator.pop(context);

                      if (!mounted) return;

                      if (res.success) {
                        Navigator.pop(context);
                        _loadRiwayatSampah();

                        showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          enableDrag: false,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                                ),
                                const SizedBox(height: 20),
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Color(0xFFD6F5E1),
                                  child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Permintaan Jual Berhasil Dikirim!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total ${_keranjangSetor.length} kategori sampah ramah lingkungan telah berhasil dikirim ke sistem bank sampah dengan status "Pending" untuk diverifikasi admin.',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Mengerti & Lihat Riwayat',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal mengirim: ${res.message}'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Kirim Semua ke Admin (Jual Sampah)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Baru saja';
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return rawDate.toString();
    }
  }

  IconData _getKategoriIcon(dynamic kategoriName) {
    final name = (kategoriName ?? '').toString().toLowerCase();
    if (name.contains('plastik')) return Icons.water_drop_outlined;
    if (name.contains('kertas')) return Icons.inventory_2_outlined;
    if (name.contains('logam') || name.contains('besi') || name.contains('kaleng')) return Icons.hardware_rounded;
    if (name.contains('kaca') || name.contains('beling')) return Icons.wine_bar_rounded;
    if (name.contains('organik')) return Icons.eco_rounded;
    return Icons.category_rounded;
  }

  Color _getKategoriColor(dynamic kategoriName) {
    final name = (kategoriName ?? '').toString().toLowerCase();
    if (name.contains('plastik')) return const Color(0xFF1E8850);
    if (name.contains('kertas')) return const Color(0xFFE65100);
    if (name.contains('logam') || name.contains('besi') || name.contains('kaleng')) return const Color(0xFF0D47A1);
    if (name.contains('kaca') || name.contains('beling')) return const Color(0xFF7B1FA2);
    if (name.contains('organik')) return const Color(0xFFEF6C00);
    return AppColors.darkGreen;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _listSampah.where((item) {
      if (_selectedTabStatus == 'semua') return true;
      final status = (item['status_verifikasi'] ?? 'pending').toString().toLowerCase();
      if (_selectedTabStatus == 'pending') return status == 'pending';
      if (_selectedTabStatus == 'accepted') return status == 'accepted';
      return true;
    }).toList();

    final displayedList = _showAllRiwayat ? filteredList : filteredList.take(5).toList();

    final acceptedList = _listSampah.where((item) {
      final status = (item['status_verifikasi'] ?? 'pending').toString().toLowerCase();
      return status == 'accepted';
    }).toList();

    double acceptedTotalKg = acceptedList.fold(0.0, (sum, item) => sum + (double.tryParse(item['jumlah']?.toString() ?? '0') ?? 0.0));
    int acceptedCount = acceptedList.length;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDataAwal,
          color: AppColors.darkGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),
                HeaderBeranda(
                  userName: UserAccountData.isGuest
                      ? 'Tamu'
                      : (UserAccountData.currentNama.isNotEmpty ? UserAccountData.currentNama.split(' ').first : 'Harin'),
                  onNotificationTap: _showNotificationSheet,
                  onProfileTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HalamanAkun()));
                  },
                ),
                if (UserAccountData.isGuest) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFEEBA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFF856404), size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode Tamu: Pelacakan Terkunci',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF856404)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Masuk ke akun Anda untuk mencatat setoran dan mengumpulkan uang hasil jual.',
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HalamanLogin()));
                          },
                          child: const Text('Masuk', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CardAutoTrackLokasi(onLocationUpdated: () => setState(() {})),
                const SizedBox(height: 16),
                CardTrackingChart(
                  totalDisetor: (UserAccountData.isGuest || UserAccountData.isNewAccount)
                      ? '0.0 kg'
                      : '${acceptedTotalKg > 0 ? acceptedTotalKg.toStringAsFixed(1) : '0.0'} kg',
                  trendPercent: (UserAccountData.isGuest || UserAccountData.isNewAccount)
                      ? '+0 setoran'
                      : '+$acceptedCount setoran tercatat',
                  rawData: (UserAccountData.isGuest || UserAccountData.isNewAccount) ? const [] : acceptedList,
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
                _buildSectionDataMasuk(filteredList.length, displayedList),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: TrashBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HalamanBeranda()));
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HalamanProduk()));
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HalamanKonten()));
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HalamanAkun()));
          }
        },
      ),
    );
  }

  Widget _buildSectionDataMasuk(int totalFilteredCount, List<dynamic> displayedList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F3DD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storage_rounded, size: 16, color: AppColors.darkGreen),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Data Permintaan Jual (${_listSampah.length})',
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF00C853)),
                    const SizedBox(width: 5),
                    const Text(
                      'Sistem Ramah Lingkungan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E8850),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Status verifikasi dan riwayat penjualan sampah ramah lingkungan Anda',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildTabButton('Semua', 'semua'),
              const SizedBox(width: 8),
              _buildTabButton('Pending', 'pending'),
              const SizedBox(width: 8),
              _buildTabButton('Accepted', 'accepted'),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkGreen),
                ),
              ),
            )
          else if (displayedList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text(
                    'Belum Ada Permintaan Jual Sampah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gunakan estimasi berat di atas untuk mulai menjual sampah ramah lingkungan Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = displayedList[index] as Map<String, dynamic>;
                    final namaKategori = item['nama_kategori']?.toString() ?? 'Sampah';
                    final jenisSampah = item['jenis_sampah']?.toString() ?? 'Setoran';
                    final jumlah = item['jumlah']?.toString() ?? '0';
                    final satuan = item['satuan']?.toString() ?? 'kg';
                    
                    final totalRupiah = item['total_rupiah'] != null 
                        ? double.tryParse(item['total_rupiah'].toString()) ?? 0.0 
                        : 0.0;
                    final formattedRupiah = 'Rp ${totalRupiah.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                    final tgl = _formatDate(item['created_at']);
                    final statusVerifikasi = item['status_verifikasi']?.toString() ?? 'pending';
                    final pesanAdmin = item['pesan_admin']?.toString();
                    final catColor = _getKategoriColor(namaKategori);

                    Color statusColor = Colors.orange;
                    String statusLabel = 'Pending';
                    if (statusVerifikasi == 'accepted') {
                      statusColor = Colors.green;
                      statusLabel = 'Accepted';
                    } else if (statusVerifikasi == 'denied') {
                      statusColor = Colors.red;
                      statusLabel = 'Denied';
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getKategoriIcon(namaKategori), color: catColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            jenisSampah,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.mintSoft,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '$jumlah $satuan',
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.darkGreen,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              formattedRupiah,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            namaKategori,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: catColor),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(tgl, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 8),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status Verifikasi:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),

                          if (statusVerifikasi == 'accepted') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFC8E6C9)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Silahkan Jual sampah anda ke Bank Sampah Sahabat Ibu terdekat',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (statusVerifikasi == 'denied') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.block_rounded, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Maaf kelakuan seperti ini tidak sopan dan anda dapat diblock',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFC62828)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (pesanAdmin != null && pesanAdmin.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Pesan Admin: $pesanAdmin',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                if (totalFilteredCount > 5)
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGreen,
                        side: const BorderSide(color: AppColors.darkGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                      _showAllRiwayat = !_showAllRiwayat;
                    });
                  },
                      child: Text(
                        _showAllRiwayat ? 'Sembunyikan Sebagian' : 'Data Penjualan Lainnya (${totalFilteredCount - 5} lainnya)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String statusKey) {
    final bool isSelected = _selectedTabStatus == statusKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabStatus = statusKey;
            _showAllRiwayat = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkGreen : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.darkGreen : AppColors.cardBorder),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.darkGreen,
            ),
          ),
        ),
      ),
    );
  }
}