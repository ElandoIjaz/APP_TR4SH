export 'models/lokasi_gmaps_item_model.dart';

import 'models/lokasi_gmaps_item_model.dart';

class LokasiTrackingService {
  LokasiTrackingService._();

  // Current live auto-tracked GPS location
  static double currentLatitude = -6.907482;
  static double currentLongitude = 107.618954;
  static String currentAccuracy = '±1.2 meter (GPS Sangat Akurat)';
  static String currentAddress =
      'Jl. Riau No. 45, RT 03 / RW 07, Kel. Citarum, Kec. Bandung Wetan';
  static String currentCity = 'Kota Bandung, Jawa Barat';
  static String currentPostalCode = '40115';
  static String currentPatokan = 'Pagar besi hitam, seberang Bank Sampah RT 03';
  static String nearestBankSampah =
      'Bank Sampah Citarum Bersih (0.8 km • Driver Siap Jemput)';
  static bool isGpsActive = true;

  // Google Maps preset places for instant search in GMaps mode
  static final List<LokasiGmapsItem> gmapsPlaces = [
    const LokasiGmapsItem(
      namaTempat: 'Rumah Tinggal (Jl. Riau)',
      alamatLengkap:
          'Jl. Riau No. 45, RT 03 / RW 07, Kel. Citarum, Kec. Bandung Wetan',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40115',
      latitude: -6.907482,
      longitude: 107.618954,
      patokan: 'Pagar besi hitam, seberang Bank Sampah RT 03',
    ),
    const LokasiGmapsItem(
      namaTempat: 'Gedung Sate & Lapangan Gasibu',
      alamatLengkap: 'Jl. Diponegoro No. 22, Citarum, Bandung Wetan',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40115',
      latitude: -6.902484,
      longitude: 107.618776,
      patokan: 'Pintu Gerbang Selatan Gedung Sate',
    ),
    const LokasiGmapsItem(
      namaTempat: 'TR4SH Office & Eco Hub Dago',
      alamatLengkap: 'Gedung Eco Hub Lt. 4, Jl. Ir. H. Juanda No. 128',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40132',
      latitude: -6.892114,
      longitude: 107.610842,
      patokan: 'Lobby timur, samping drop box daur ulang',
    ),
    const LokasiGmapsItem(
      namaTempat: 'Paris Van Java Mall',
      alamatLengkap: 'Jl. Sukajadi No. 131-139, Cipedes, Sukajadi',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40162',
      latitude: -6.889412,
      longitude: 107.595914,
      patokan: 'Pintu Lobby Resort Level Ground',
    ),
    const LokasiGmapsItem(
      namaTempat: 'Bandung Electronic Center (BEC)',
      alamatLengkap: 'Jl. Purnawarman No. 13-15, Babakan Ciamis, Sumur Bandung',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40117',
      latitude: -6.908520,
      longitude: 107.609210,
      patokan: 'Drop off motor barat BEC',
    ),
    const LokasiGmapsItem(
      namaTempat: 'Braga Heritage Walk',
      alamatLengkap: 'Jl. Braga No. 99-101, Braga, Sumur Bandung',
      kota: 'Kota Bandung, Jawa Barat',
      kodePos: '40111',
      latitude: -6.917456,
      longitude: 107.609432,
      patokan: 'Depan landmark Braga Citywalk',
    ),
  ];

  static String getGoogleMapsUrl(double lat, double lng) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }

  static void updateTrackedLocation({
    required double lat,
    required double lng,
    required String address,
    required String city,
    required String postalCode,
    String? patokan,
    String? accuracy,
  }) {
    currentLatitude = lat;
    currentLongitude = lng;
    currentAddress = address;
    currentCity = city;
    currentPostalCode = postalCode;
    if (patokan != null) currentPatokan = patokan;
    if (accuracy != null) currentAccuracy = accuracy;
  }
}
