import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/lokasi_service.dart';
import 'package:test23/data/user_account_data.dart';

class HalamanPilihLokasiAkurat extends StatefulWidget {
  final AlamatModel? initialAlamat;

  const HalamanPilihLokasiAkurat({super.key, this.initialAlamat});

  @override
  State<HalamanPilihLokasiAkurat> createState() => _HalamanPilihLokasiAkuratState();
}

class _HalamanPilihLokasiAkuratState extends State<HalamanPilihLokasiAkurat> {
  late double _latitude;
  late double _longitude;
  String _accuracyText = '±1.2 meter - GPS Sangat Akurat';
  bool _isLocating = false;
  int _mapModeIndex = 0; // 0: Normal Google Maps, 1: Satelit GMaps, 2: Hybrid GMaps

  late TextEditingController _gmapsSearchController;
  late TextEditingController _labelController;
  late TextEditingController _penerimaController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;
  late TextEditingController _patokanController;
  late TextEditingController _kotaController;
  late TextEditingController _kodePosController;
  bool _isUtama = false;

  String _selectedLabelType = 'Rumah';
  final List<String> _labelTypes = ['Rumah', 'Kantor', 'Apartemen', 'Lainnya'];
  List<LokasiGmapsItem> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAlamat;
    _latitude = a?.latitude ?? LokasiTrackingService.currentLatitude;
    _longitude = a?.longitude ?? LokasiTrackingService.currentLongitude;
    _isUtama = a?.isUtama ?? false;
    _selectedLabelType = a?.label ?? 'Rumah';

    _gmapsSearchController = TextEditingController();
    _labelController = TextEditingController(text: a?.label ?? 'Rumah');
    _penerimaController = TextEditingController(text: a?.penerima ?? 'Bintang Pratama');
    _teleponController = TextEditingController(text: a?.telepon ?? '0812-3456-7890');
    _alamatController = TextEditingController(
      text: a?.alamatLengkap ?? LokasiTrackingService.currentAddress,
    );
    _patokanController = TextEditingController(text: a?.patokan ?? LokasiTrackingService.currentPatokan);
    _kotaController = TextEditingController(text: a?.kota ?? LokasiTrackingService.currentCity);
    _kodePosController = TextEditingController(text: a?.kodePos ?? LokasiTrackingService.currentPostalCode);
  }

  @override
  void dispose() {
    _gmapsSearchController.dispose();
    _labelController.dispose();
    _penerimaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _patokanController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  void _onGmapsSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      _searchResults = LokasiTrackingService.gmapsPlaces.where((item) {
        return item.namaTempat.toLowerCase().contains(lower) ||
            item.alamatLengkap.toLowerCase().contains(lower);
      }).toList();
      _showSearchResults = true;
    });
  }

  void _selectGmapsPlace(LokasiGmapsItem item) {
    setState(() {
      _latitude = item.latitude;
      _longitude = item.longitude;
      _alamatController.text = item.alamatLengkap;
      _kotaController.text = item.kota;
      _kodePosController.text = item.kodePos;
      _patokanController.text = item.patokan;
      _accuracyText = '±1.1 meter (Google Maps Verified)';
      _showSearchResults = false;
      _gmapsSearchController.text = item.namaTempat;
    });

    LokasiTrackingService.updateTrackedLocation(
      lat: item.latitude,
      lng: item.longitude,
      address: item.alamatLengkap,
      city: item.kota,
      postalCode: item.kodePos,
      patokan: item.patokan,
      accuracy: '±1.1 meter (Google Maps Verified)',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Lokasi Google Maps terpilih: ${item.namaTempat}'),
        backgroundColor: AppColors.darkGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _detectCurrentGpsLocation() {
    setState(() {
      _isLocating = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _latitude = -6.907482 + (0.0002 * (DateTime.now().millisecond % 5 - 2));
        _longitude = 107.618954 + (0.0002 * (DateTime.now().millisecond % 4 - 2));
        _accuracyText = '±1.2 meter - GPS Sangat Akurat';
        _isLocating = false;
        _alamatController.text = 'Jl. Riau No. 45, RT 03 / RW 07, Kel. Citarum, Kec. Bandung Wetan';
        _kotaController.text = 'Kota Bandung, Jawa Barat';
        _kodePosController.text = '40115';
        _patokanController.text = 'Pagar besi hitam, seberang Bank Sampah RT 03';
      });

      LokasiTrackingService.updateTrackedLocation(
        lat: _latitude,
        lng: _longitude,
        address: _alamatController.text,
        city: _kotaController.text,
        postalCode: _kodePosController.text,
        patokan: _patokanController.text,
        accuracy: _accuracyText,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Lokasi GPS Akurat Terkunci! (Radius 1.2m tersinkronisasi)'),
          backgroundColor: AppColors.darkGreen,
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _showGoogleMapsModal() {
    final url = LokasiTrackingService.getGoogleMapsUrl(_latitude, _longitude);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F3DD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pin_drop_rounded, color: AppColors.darkGreen, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Navigasi Google Maps',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgScreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Titik Koordinat GMaps:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    '${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    url,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF1E8850), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Titik ini akan digunakan kurir marketplace dan penjemput sampah untuk navigasi rute langsung ke lokasi Anda.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF4C6656), height: 1.3),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka tautan Google Maps langsung ke titik koordinat...'),
                      backgroundColor: AppColors.darkGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 16, color: AppColors.limeAccent),
                label: const Text('Buka Aplikasi Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAddress() {
    if (_alamatController.text.trim().isEmpty || _penerimaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi nama penerima dan alamat pengiriman'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newAlamat = AlamatModel(
      id: widget.initialAlamat?.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _selectedLabelType,
      penerima: _penerimaController.text.trim(),
      telepon: _teleponController.text.trim(),
      alamatLengkap: _alamatController.text.trim(),
      kota: _kotaController.text.trim(),
      kodePos: _kodePosController.text.trim(),
      patokan: _patokanController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      akurasiGps: _accuracyText,
      isUtama: _isUtama,
    );

    if (_isUtama) {
      for (var a in UserAccountData.listAlamat) {
        a.isUtama = false;
      }
    }

    final existingIndex =
        UserAccountData.listAlamat.indexWhere((a) => a.id == newAlamat.id);
    if (existingIndex != -1) {
      UserAccountData.listAlamat[existingIndex] = newAlamat;
    } else {
      UserAccountData.listAlamat.add(newAlamat);
    }

    // Also sync with LokasiTrackingService for live waste pickup auto-tracking
    LokasiTrackingService.updateTrackedLocation(
      lat: newAlamat.latitude,
      lng: newAlamat.longitude,
      address: newAlamat.alamatLengkap,
      city: newAlamat.kota,
      postalCode: newAlamat.kodePos,
      patokan: newAlamat.patokan,
      accuracy: newAlamat.akurasiGps,
    );

    Navigator.pop(context, newAlamat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tentukan Lokasi Akurat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Buka di Google Maps',
            icon: const Icon(Icons.map_rounded, color: AppColors.darkGreen),
            onPressed: _showGoogleMapsModal,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Interactive Google Maps Area ──
            Container(
              height: 290,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE4EDE7),
              ),
              child: Stack(
                children: [
                  // Map Canvas Background (Simulated Google Maps)
                  Positioned.fill(
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          _latitude = -6.907482 + (details.localPosition.dy - 145) * 0.0001;
                          _longitude = 107.618954 + (details.localPosition.dx - 180) * 0.0001;
                          _accuracyText = '±1.2 meter (Pin Maps Disesuaikan)';
                        });
                      },
                      child: CustomPaint(
                        painter: _SimulatedMapPainter(isSatellite: _mapModeIndex == 1),
                      ),
                    ),
                  ),

                  // Top Google Maps Search Bar
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _gmapsSearchController,
                            onChanged: _onGmapsSearchChanged,
                            style: const TextStyle(fontSize: 12, color: AppColors.darkGreen),
                            decoration: InputDecoration(
                              hintText: 'Cari tempat di Google Maps (cth: Dago, BEC, PVJ)...',
                              hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.darkGreen),
                              suffixIcon: _gmapsSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                                      onPressed: () {
                                        _gmapsSearchController.clear();
                                        _onGmapsSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),

                        // Suggestions list dropdown
                        if (_showSearchResults && _searchResults.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Material(
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _searchResults.map((item) {
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.place_rounded, color: AppColors.darkGreen, size: 18),
                                    title: Text(item.namaTempat, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                                    subtitle: Text(item.alamatLengkap, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    onTap: () => _selectGmapsPlace(item),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Floating GPS Accuracy Status Badge
                  Positioned(
                    top: 62,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Titik Pin Presisi: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                Text(
                                  _accuracyText,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF2E6B4E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map Mode Switcher (Normal / Satelit / Hybrid)
                  Positioned(
                    top: 115,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildModeChip(0, 'Peta'),
                          _buildModeChip(1, 'Satelit'),
                          _buildModeChip(2, 'Hybrid'),
                        ],
                      ),
                    ),
                  ),

                  // Center Pin Marker
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 26,
                            color: AppColors.limeAccent,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Map Actions: "Kunci GPS Saya" & "Buka GMaps"
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.darkGreen,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _showGoogleMapsModal,
                          icon: const Icon(Icons.map_outlined, size: 15, color: AppColors.darkGreen),
                          label: const Text('Buka di GMaps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        FloatingActionButton.extended(
                          heroTag: 'gps_button',
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: AppColors.limeAccent,
                          elevation: 4,
                          icon: _isLocating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.limeAccent,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded, size: 18),
                          label: Text(
                            _isLocating ? 'Mencari GPS...' : 'Kunci GPS Saya',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _detectCurrentGpsLocation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Form Alamat Detail ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori (Rumah / Kantor / Apartemen / dll)
                  const Text(
                    'Label Alamat',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _labelTypes.map((type) {
                      final bool isSelected = _selectedLabelType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.darkGreen,
                        backgroundColor: AppColors.bgScreen,
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.limeAccent : AppColors.darkGreen,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _selectedLabelType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Nama Penerima & Telepon
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _penerimaController,
                          label: 'Nama Penerima',
                          hint: 'cth: Bintang Pratama',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _teleponController,
                          label: 'No. Handphone',
                          hint: '0812-xxxx-xxxx',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Alamat Lengkap
                  _buildTextField(
                    controller: _alamatController,
                    label: 'Alamat Lengkap & Nomor Rumah',
                    hint: 'Nama jalan, nomor rumah, RT/RW, kelurahan',
                    icon: Icons.home_outlined,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 14),

                  // Kota & Kode Pos
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: _kotaController,
                          label: 'Kota / Kabupaten',
                          hint: 'Kota Bandung, Jawa Barat',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _kodePosController,
                          label: 'Kode Pos',
                          hint: '40115',
                          icon: Icons.markunread_mailbox_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Catatan Patokan Kurir (Sangat Penting untuk Akurasi)
                  _buildTextField(
                    controller: _patokanController,
                    label: 'Patokan Khusus Kurir (Opsional)',
                    hint: 'cth: Pagar besi hitam, seberang bank sampah, lantai 2',
                    icon: Icons.flag_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Atur sebagai Alamat Utama
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Atur sebagai Alamat Utama',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                              Text(
                                'Digunakan otomatis untuk pesanan marketplace',
                                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isUtama,
                          activeThumbColor: AppColors.darkGreen,
                          activeTrackColor: AppColors.mintSoft,
                          onChanged: (val) {
                            setState(() {
                              _isUtama = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saveAddress,
                      icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.limeAccent),
                      label: const Text(
                        'Simpan Lokasi Akurat',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
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

  Widget _buildModeChip(int index, String title) {
    final isSelected = _mapModeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _mapModeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.limeAccent : AppColors.darkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgScreen,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.darkGreen),
            decoration: InputDecoration(
              icon: Icon(icon, size: 18, color: const Color(0xFF1E8850)),
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter to render realistic map grid lines and eco-landmarks ──
class _SimulatedMapPainter extends CustomPainter {
  final bool isSatellite;

  _SimulatedMapPainter({this.isSatellite = false});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = isSatellite ? const Color(0xFF2C3E33) : const Color(0xFFE8EFEA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = isSatellite ? const Color(0xFF4A5D51) : Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadLinePaint = Paint()
      ..color = isSatellite ? const Color(0xFF5F7567) : const Color(0xFFD6E2D9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Main road horizontal
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), roadLinePaint);

    // Main road vertical
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), roadLinePaint);

    // Diagonal arterial road
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width * 0.9, 0), roadPaint);

    // River / water feature
    final riverPaint = Paint()
      ..color = isSatellite ? const Color(0xFF1E465A) : const Color(0xFFC7E2E8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.2);
    riverPath.quadraticBezierTo(size.width * 0.4, size.height * 0.25, size.width, size.height * 0.15);
    canvas.drawPath(riverPath, riverPaint);

    // Park / Green zones
    final parkPaint = Paint()..color = isSatellite ? const Color(0xFF1B3D28) : const Color(0xFFD3EAD8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, 100, 70),
        const Radius.circular(12),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 120, size.height - 80, 95, 60),
        const Radius.circular(12),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SimulatedMapPainter oldDelegate) =>
      oldDelegate.isSatellite != isSatellite;
}
