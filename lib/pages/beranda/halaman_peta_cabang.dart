import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HalamanPetaCabang extends StatefulWidget {
  const HalamanPetaCabang({super.key});

  @override
  State<HalamanPetaCabang> createState() => _HalamanPetaCabangState();
}

class _HalamanPetaCabangState extends State<HalamanPetaCabang> {
  final MapController _mapController = MapController();

  static const LatLng _initialPosition = LatLng(-8.184487, 113.705886);
  LatLng _userPosition = _initialPosition;

   List<Map<String, dynamic>> _daftarCabang = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedCabang;
  Map<String, dynamic>? _cabangTerdekat;

  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndData();
  }

  Future<void> _initializeLocationAndData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          _userPosition = LatLng(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      debugPrint("Gagal mendeteksi lokasi GPS: $e");
    }

    if (!mounted) return;
    await _loadLokasiCabangFromDatabase();
  }

  double _hitungJarakKm(LatLng p1, LatLng p2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a =
        0.5 -
        c((p2.latitude - p1.latitude) * p) / 2 +
        c(p1.latitude * p) *
            c(p2.latitude * p) *
            (1 - c((p2.longitude - p1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> _loadLokasiCabangFromDatabase() async {
    try {
      final res = await ApiService.fetchBankSampah();
      if (!mounted) return;

      if (res.success && res.data is List) {
        final rawList = res.data as List;
        final  List<Map<String, dynamic>> formattedList = rawList.map((item) {
          final mapItem = Map<String, dynamic>.from(item);

          final double lat =
              double.tryParse(mapItem['latitude']?.toString() ?? '') ??
              -8.184487;
          final double lng =
              double.tryParse(mapItem['longitude']?.toString() ?? '') ??
              113.705886;
          final LatLng pos = LatLng(lat, lng);

          final double jarak = _hitungJarakKm(_userPosition, pos);

          return {
            'id':
                mapItem['id_bank_sampah']?.toString() ??
                mapItem['id']?.toString() ??
                '1',
            'nama':
                mapItem['nama_bank_sampah'] ??
                mapItem['nama_cabang'] ??
                mapItem['nama'] ??
                'Bank Sampah',
            'alamat': mapItem['alamat']?.toString() ?? '',
            'jam': mapItem['jam_operasional']?.toString() ?? '-',
            'telp':
                mapItem['no_telp']?.toString() ??
                mapItem['telepon']?.toString() ??
                '-',
            'latLng': pos,
            'jarak_km': jarak,
          };
        }).toList();

        if (formattedList.isNotEmpty) {
          // Urutkan dari cabang terdekat ke terjauh
          formattedList.sort(
            (a, b) =>
                (a['jarak_km'] as double).compareTo(b['jarak_km'] as double),
          );

          final terdekat = formattedList.first;

          setState(() {
            _daftarCabang = formattedList;
            _cabangTerdekat = terdekat;
            _isLoading = false;
          });

          _pilihCabang(terdekat);
          return;
        }
      }
    } catch (e) {
      debugPrint("Gagal memuat dari API: $e");
    }

    if (!mounted) return;

    // Fallback jika API gagal atau kosong
    const fallbackPos = LatLng(-8.200710207165347, 113.7090619023833);
    final  List<Map<String, dynamic>> fallbackList = [
      {
        'id': '1',
        'nama': 'Bank Sampah Sahabat Ibu',
        'alamat':
            'Perumahan Taman Gading, Tumpengsari, Tegal Besar, Kec. Kaliwates, Jember',
        'jam': '08:00 - 17:00 WIB',
        'telp': '082141055879',
        'latLng': fallbackPos,
        'jarak_km': _hitungJarakKm(_userPosition, fallbackPos),
      },
    ];

    setState(() {
      _daftarCabang = fallbackList;
      _cabangTerdekat = fallbackList.first;
      _isLoading = false;
    });
    _pilihCabang(fallbackList.first);
  }

  Future<void> _fetchRoute(LatLng tujuan) async {
    if (mounted) setState(() => _isLoadingRoute = true);
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${_userPosition.longitude},${_userPosition.latitude};${tujuan.longitude},${tujuan.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coords = geometry['coordinates'] as List;

          setState(() {
            _routePoints = coords.map<LatLng>((coord) {
              return LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              );
            }).toList();
            _isLoadingRoute = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _routePoints = [_userPosition, tujuan];
      _isLoadingRoute = false;
    });
  }

  void _pilihCabang(Map<String, dynamic> cabang) {
    setState(() {
      _selectedCabang = cabang;
    });
    final LatLng target = cabang['latLng'] as LatLng;
    _fetchRoute(target);
    _fokuskanPetaKeRute(_userPosition, target);
  }

  void _fokuskanPetaKeRute(LatLng start, LatLng end) {
    final double centerLat = (start.latitude + end.latitude) / 2;
    final double centerLng = (start.longitude + end.longitude) / 2;

    final double jarak = _hitungJarakKm(start, end);
    double targetZoom = 15.0;
    if (jarak > 5) targetZoom = 13.5;
    if (jarak > 10) targetZoom = 12.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.move(LatLng(centerLat, centerLng), targetZoom);
      } catch (e) {
        debugPrint("Peta belum siap digerakkan: $e");
      }
    });
  }

  Future<void> _bukaNavigasiEksternal(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _tampilkanDaftarCabang() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Pilih Cabang Bank Sampah',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _daftarCabang.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final cabang = _daftarCabang[index];
                    final double jarak = cabang['jarak_km'] as double;
                    final bool isSelected =
                        _selectedCabang?['id'] == cabang['id'];
                    final bool isTerdekat =
                        _cabangTerdekat?['id'] == cabang['id'];

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFF0F9F4),
                      leading: Icon(
                        Icons.location_on_rounded,
                        color: isSelected
                            ? AppColors.darkGreen
                            : Colors.grey.shade500,
                      ),
                      title: Text(
                        cabang['nama'].toString(),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.darkGreen
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        cabang['alamat'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTerdekat
                              ? const Color(0xFFD6F5E1)
                              : const Color(0xFFF1F5F3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${jarak.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isTerdekat
                                ? const Color(0xFF15803D)
                                : const Color(0xFF406354),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pilihCabang(cabang);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Cabang & Rute Bank Sampah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userPosition,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tr4sh.app',
                    ),

                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blueAccent,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userPosition,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.blueAccent,
                            size: 32,
                          ),
                        ),
                        ..._daftarCabang.map<Marker>((cabang) {
                          final LatLng actualPos = cabang['latLng'] as LatLng;
                          final bool isSelected =
                              _selectedCabang?['id'] == cabang['id'];
                          return Marker(
                            point: actualPos,
                            width: isSelected ? 55 : 45,
                            height: isSelected ? 55 : 45,
                            child: GestureDetector(
                              onTap: () => _pilihCabang(cabang),
                              child: Icon(
                                Icons.location_pin,
                                color: isSelected
                                    ? Colors.amber
                                    : Colors.redAccent,
                                size: isSelected ? 50 : 42,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                if (_isLoadingRoute)
                  Positioned(
                    top: 135,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Memuat rute jalan raya...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Tombol Fokus ke Lokasi Pengguna
                Positioned(
                  right: 16,
                  bottom: _selectedCabang != null ? 250 : 30,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      _mapController.move(_userPosition, 15.0);
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),

                // Panel Atas: Rekomendasi Terdekat & Tombol Pilih Cabang
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_cabangTerdekat != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.recommend_rounded,
                                  color: AppColors.darkGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rekomendasi Terdekat: ${_cabangTerdekat!['nama']} (${(_cabangTerdekat!['jarak_km'] as double).toStringAsFixed(1)} km)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGreen,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        InkWell(
                          onTap: _tampilkanDaftarCabang,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6FAF7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.darkGreen.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.storefront_rounded,
                                  size: 18,
                                  color: AppColors.darkGreen,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedCabang != null
                                        ? '${_selectedCabang!['nama']} (${(_selectedCabang!['jarak_km'] as double).toStringAsFixed(1)} km)'
                                        : 'Pilih Cabang Bank Sampah',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkGreen,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.darkGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Kartu Informasi Cabang Terpilih
                if (_selectedCabang != null)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedCabang!['nama'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    setState(() => _selectedCabang = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedCabang!['alamat'],
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Jam: ${_selectedCabang!['jam']}  •  Telp: ${_selectedCabang!['telp']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 14,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jarak: ${(_selectedCabang!['jarak_km'] as double).toStringAsFixed(1)} km dari posisi Anda',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                final LatLng target =
                                    _selectedCabang!['latLng'] as LatLng;
                                _fokuskanPetaKeRute(_userPosition, target);
                                _bukaNavigasiEksternal(
                                  target.latitude,
                                  target.longitude,
                                );
                              },
                              icon: const Icon(
                                Icons.navigation_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Buka Navigasi Turn-by-Turn',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}