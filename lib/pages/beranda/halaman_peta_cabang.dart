import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart'; // Terhubung ke ApiService
import 'package:url_launcher/url_launcher.dart';

class HalamanPetaCabang extends StatefulWidget {
  const HalamanPetaCabang({super.key});

  @override
  State<HalamanPetaCabang> createState() => _HalamanPetaCabangState();
}

class _HalamanPetaCabangState extends State<HalamanPetaCabang> {
  final MapController _mapController = MapController();

  // Titik pusat awal (Area Jember, Jawa Timur)
  static const LatLng _initialPosition = LatLng(-8.184487, 113.705886);

  // Posisi Pengguna / "Kita"
  final LatLng _userPosition = const LatLng(-8.170200, 113.700100);

  var _daftarCabang = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedCabang;
  Map<String, dynamic>? _cabangTerdekat;
  
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadLokasiCabangFromDatabase();
  }

  double _hitungJarakKm(LatLng p1, LatLng p2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((p2.latitude - p1.latitude) * p) / 2 +
        c(p1.latitude * p) *
            c(p2.latitude * p) *
            (1 - c((p2.longitude - p1.longitude) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Mengambil data secara dinamis dari database Laravel menggunakan ApiService.fetchBankSampah()
  Future<void> _loadLokasiCabangFromDatabase() async {
    try {
      final res = await ApiService.fetchBankSampah(); // Menggunakan method yang tersedia di ApiService
      if (res.success && res.data is List) {
        final rawList = res.data as List;
        final formattedList = rawList.map((item) {
          final mapItem = Map<String, dynamic>.from(item);
          
          // Parsing koordinat latitude & longitude dari database
          final double lat = double.tryParse(mapItem['latitude']?.toString() ?? '') ?? -8.184487;
          final double lng = double.tryParse(mapItem['longitude']?.toString() ?? '') ?? 113.705886;
          final LatLng pos = LatLng(lat, lng);

          final double jarak = _hitungJarakKm(_userPosition, pos);

          return {
            'id': mapItem['id']?.toString() ?? mapItem['id_bank']?.toString() ?? '1',
            'nama': mapItem['nama_cabang'] ?? mapItem['nama'] ?? 'Bank Sampah',
            'alamat': mapItem['alamat'] ?? '',
            'jam': mapItem['jam_operasional'] ?? '08:00 - 16:00 WIB',
            'telp': mapItem['telepon'] ?? '-',
            'latLng': pos,
            'jarak_km': jarak,
          };
        }).toList();

        if (formattedList.isNotEmpty) {
          // Cari cabang terdekat
          Map<String, dynamic>? terdekat;
          double minJarak = double.infinity;
          for (var c in formattedList) {
            final double j = c['jarak_km'];
            if (j < minJarak) {
              minJarak = j;
              terdekat = c;
            }
          }

          setState(() {
            _daftarCabang = formattedList;
            _cabangTerdekat = terdekat;
            _isLoading = false;
          });

          if (terdekat != null) {
            _pilihCabang(terdekat);
          }
          return;
        }
      }
    } catch (_) {}

    // Fallback data statis jika server/database offline
    final fallbackList = [
      {
        'id': '1',
        'nama': 'Bank Sampah Pusat Sahabat Ibu',
        'alamat': 'Jl. Kalimantan No. 37, Tegalboto, Jember',
        'jam': '08:00 - 16:00 WIB',
        'telp': '081234567890',
        'latLng': const LatLng(-8.165123, 113.716234),
        'jarak_km': _hitungJarakKm(_userPosition, const LatLng(-8.165123, 113.716234)),
      },
      {
        'id': '2',
        'nama': 'Unit Bank Sampah Patrang',
        'alamat': 'Jl. Srikoyo No. 12, Patrang, Jember',
        'jam': '08:00 - 14:00 WIB',
        'telp': '082198765432',
        'latLng': const LatLng(-8.152341, 113.698512),
        'jarak_km': _hitungJarakKm(_userPosition, const LatLng(-8.152341, 113.698512)),
      },
      {
        'id': '3',
        'nama': 'Unit Bank Sampah Kaliwates',
        'alamat': 'Jl. Sultan Agung No. 88, Kaliwates, Jember',
        'jam': '08:30 - 15:00 WIB',
        'telp': '085611223344',
        'latLng': const LatLng(-8.173912, 113.678910),
        'jarak_km': _hitungJarakKm(_userPosition, const LatLng(-8.173912, 113.678910)),
      },
    ];

    setState(() {
      _daftarCabang = fallbackList;
      _cabangTerdekat = fallbackList.first;
      _isLoading = false;
    });
    _pilihCabang(fallbackList.first);
  }

  // Mengambil jalur rute jalan raya via OSRM API (Gratis & In-App)
  Future<void> _fetchRoute(LatLng tujuan) async {
    setState(() => _isLoadingRoute = true);
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${_userPosition.longitude},${_userPosition.latitude};${tujuan.longitude},${tujuan.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coords = geometry['coordinates'] as List;

          setState(() {
            _routePoints = coords.map<LatLng>((coord) {
              return LatLng(coord[1] as double, coord[0] as double);
            }).toList();
            _isLoadingRoute = false;
          });
          return;
        }
      }
    } catch (_) {}

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
    _mapController.move(target, 14.5);
  }

  Future<void> _bukaNavigasiEksternal(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Cabang & Rute Bank Sampah',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: _initialPosition,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tr4sh.app',
                    ),
                    
                    // Layer Garis Rute Jalan Raya (OSRM)
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

                    // Marker Layer (Posisi Kita & Cabang)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userPosition,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 32),
                        ),
                        ..._daftarCabang.map<Marker>((cabang) {
                          final LatLng actualPos = cabang['latLng'] as LatLng;
                          final bool isSelected = _selectedCabang?['id'] == cabang['id'];
                          return Marker(
                            point: actualPos,
                            width: isSelected ? 55 : 45,
                            height: isSelected ? 55 : 45,
                            child: GestureDetector(
                              onTap: () => _pilihCabang(cabang),
                              child: Icon(
                                Icons.location_pin,
                                color: isSelected ? Colors.amber : Colors.redAccent,
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
                    top: 90,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            SizedBox(width: 8),
                            Text('Memuat rute jalan raya...', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Panel Atas: Rekomendasi Terdekat & Dropdown Pilihan Cabang
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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
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
                                const Icon(Icons.recommend_rounded, color: AppColors.darkGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rekomendasi Terdekat: ${_cabangTerdekat!['nama']} (${(_cabangTerdekat!['jarak_km'] as double).toStringAsFixed(1)} km)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCabang?['id']?.toString(),
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            labelText: 'Pilih Cabang Bank Sampah',
                            labelStyle: const TextStyle(fontSize: 13, color: AppColors.darkGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: _daftarCabang.map((cabang) {
                            final double jarak = cabang['jarak_km'];
                            return DropdownMenuItem<String>(
                              value: cabang['id'].toString(),
                              child: Text(
                                '${cabang['nama']} (${jarak.toStringAsFixed(1)} km)',
                                style: const TextStyle(fontSize: 12.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final dipilih = _daftarCabang.firstWhere((c) => c['id'].toString() == val);
                              _pilihCabang(dipilih);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Bawah: Detail Cabang & Tombol Navigasi
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
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
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
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => setState(() => _selectedCabang = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedCabang!['alamat'],
                                  style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.near_me_rounded, size: 14, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                'Jarak: ${(_selectedCabang!['jarak_km'] as double).toStringAsFixed(1)} km dari posisi Anda',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final LatLng target = _selectedCabang!['latLng'] as LatLng;
                                _bukaNavigasiEksternal(target.latitude, target.longitude);
                              },
                              icon: const Icon(Icons.navigation_rounded, size: 16),
                              label: const Text(
                                'Buka Navigasi Turn-by-Turn',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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