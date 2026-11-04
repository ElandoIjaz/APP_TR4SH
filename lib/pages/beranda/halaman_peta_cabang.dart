import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test23/core/app_colors.dart';

class HalamanPetaCabang extends StatefulWidget {
  const HalamanPetaCabang({super.key});

  @override
  State<HalamanPetaCabang> createState() => _HalamanPetaCabangState();
}

class _HalamanPetaCabangState extends State<HalamanPetaCabang> {
  late GoogleMapController _mapController;

  // Titik koordinat pusat (contoh: area Jember, Jawa Timur)
  static const LatLng _initialPosition = LatLng(-8.184487, 113.705886);

  // Daftar data titik cabang bank sampah
  final List> _daftarCabang = [
    {
      'id': 'cabang_1',
      'nama': 'Bank Sampah Pusat Sahabat Ibu',
      'alamat': 'Jl. Kalimantan No. 37, Tegalboto, Jember',
      'jam': '08:00 - 16:00 WIB',
      'telp': '0812-3456-7890',
      'latLng': const LatLng(-8.165123, 113.716234),
    },
    {
      'id': 'cabang_2',
      'nama': 'Unit Bank Sampah Patrang',
      'alamat': 'Jl. Srikoyo No. 12, Patrang, Jember',
      'jam': '08:00 - 14:00 WIB',
      'telp': '0821-9876-5432',
      'latLng': const LatLng(-8.152341, 113.698512),
    },
    {
      'id': 'cabang_3',
      'nama': 'Unit Bank Sampah Kaliwates',
      'alamat': 'Jl. Sultan Agung No. 88, Kaliwates, Jember',
      'jam': '08:30 - 15:00 WIB',
      'telp': '0856-1122-3344',
      'latLng': const LatLng(-8.173912, 113.678910),
    },
  ];

  Map<String, dynamic>? _selectedCabang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Cabang Bank Sampah',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Widget Google Maps
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 13.0,
            ),
            markers: _daftarCabang.map((cabang) {
              return Marker(
                markerId: MarkerId(cabang['id']),
                position: cabang['latLng'],
                infoWindow: InfoWindow(
                  title: cabang['nama'],
                  snippet: cabang['alamat'],
                ),
                onTap: () {
                  setState(() {
                    _selectedCabang = cabang;
                  });
                },
              );
            }).toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              setState(() {
                _selectedCabang = null;
              });
            },
          ),

          // Card Detail Cabang di Bagian Bawah saat Marker Ditekan
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
                        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Buka: ${_selectedCabang!['jam']}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mengarahkan rute ke ${_selectedCabang!['nama']}...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_rounded, size: 16),
                        label: const Text(
                          'Navigasi ke Lokasi',
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