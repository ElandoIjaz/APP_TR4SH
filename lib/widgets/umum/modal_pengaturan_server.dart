import 'package:flutter/material.dart';
import 'package:test23/core/api_config.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/api_service.dart';

class ModalPengaturanServer extends StatefulWidget {
  const ModalPengaturanServer({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ModalPengaturanServer(),
    );
  }

  @override
  State<ModalPengaturanServer> createState() => _ModalPengaturanServerState();
}

class _ModalPengaturanServerState extends State<ModalPengaturanServer> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late bool _isEmulator;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: ApiConfig.laptopWifiIp);
    _portController = TextEditingController(text: ApiConfig.port.toString());
    _isEmulator = ApiConfig.useAndroidEmulator;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final tempIp = _ipController.text.trim();
    final tempPort = int.tryParse(_portController.text.trim()) ?? 8000;

    // Simpan sementara untuk pengujian
    final prevIp = ApiConfig.laptopWifiIp;
    final prevPort = ApiConfig.port;
    final prevEmu = ApiConfig.useAndroidEmulator;

    ApiConfig.laptopWifiIp = tempIp;
    ApiConfig.port = tempPort;
    ApiConfig.useAndroidEmulator = _isEmulator;

    final connected = await ApiService.checkConnection();

    if (!mounted) return;

    setState(() {
      _isTesting = false;
      _testSuccess = connected;
      if (connected) {
        _testResult = 'Berhasil terhubung ke ${ApiConfig.baseUrl}';
      } else {
        _testResult =
            'Gagal terhubung ke ${ApiConfig.baseUrl}.\nPastikan Laravel berjalan dengan command:\nphp artisan serve --host=0.0.0.0 --port=$tempPort\ndan HP terhubung ke WiFi yang sama.';
      }
    });

    // Kembalikan ke state awal jika belum disimpan secara definitif
    if (!connected) {
      ApiConfig.laptopWifiIp = prevIp;
      ApiConfig.port = prevPort;
      ApiConfig.useAndroidEmulator = prevEmu;
    }
  }

  Future<void> _saveConfig() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8000;

    await ApiConfig.setServerConfig(
      ip: ip,
      customPort: port,
      isEmulator: _isEmulator,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Server disetel ke ${ApiConfig.baseUrl}'),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.wifi_tethering_rounded, color: AppColors.forestGreen, size: 24),
                SizedBox(width: 10),
                Text(
                  'Pengaturan IP Server Backend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Aktif saat ini: ${ApiConfig.baseUrl}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),

            const SizedBox(height: 14),
            // Shortcut presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.phone_android_rounded, size: 16),
                  label: const Text('Mode Emulator (10.0.2.2)', style: TextStyle(fontSize: 12)),
                  backgroundColor: _isEmulator ? const Color(0xFFE8F5E9) : null,
                  onPressed: () {
                    setState(() {
                      _isEmulator = true;
                      _testResult = null;
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.wifi_rounded, size: 16),
                  label: const Text('WiFi Laptop (10.10.181.109)', style: TextStyle(fontSize: 12)),
                  backgroundColor: (!_isEmulator && _ipController.text == '10.10.181.109')
                      ? const Color(0xFFE8F5E9)
                      : null,
                  onPressed: () {
                    setState(() {
                      _isEmulator = false;
                      _ipController.text = '10.10.181.109';
                      _testResult = null;
                    });
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Deteksi Otomatis', style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    setState(() => _isTesting = true);
                    final found = await ApiConfig.autoDetectWorkingHost();
                    if (!mounted) return;
                    setState(() {
                      _isTesting = false;
                      _isEmulator = ApiConfig.useAndroidEmulator;
                      _ipController.text = ApiConfig.laptopWifiIp;
                      _testSuccess = found;
                      _testResult = found
                          ? 'Server terdeteksi: ${ApiConfig.baseUrl}'
                          : 'Gagal mendeteksi server otomatis. Pastikan Laravel backend aktif (--host=0.0.0.0).';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Field IP
            const Text(
              'IP WiFi Laptop (lihat via command ipconfig)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _ipController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Contoh: 10.10.181.109',
                prefixIcon: const Icon(Icons.laptop_chromebook_rounded, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Field Port
            const Text(
              'Port Laravel (standar 8000)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '8000',
                prefixIcon: const Icon(Icons.numbers_rounded, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Switch Emulator
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Gunakan Android Emulator (10.0.2.2)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Nyalakan jika run di Android Emulator (AVD)',
                style: TextStyle(fontSize: 11),
              ),
              value: _isEmulator,
              activeThumbColor: AppColors.forestGreen,
              onChanged: (val) {
                setState(() => _isEmulator = val);
              },
            ),
            const SizedBox(height: 12),

            // Status Pengujian
            if (_testResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _testSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _testSuccess ? Colors.green.shade400 : Colors.red.shade400,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: _testSuccess ? Colors.green.shade700 : Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _testSuccess ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check_rounded, size: 18),
                    label: const Text('Tes Ping'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveConfig,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
