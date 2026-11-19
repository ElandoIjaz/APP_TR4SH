import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/core/validators/auth_validator.dart';
import 'package:test23/data/api_service.dart';
import 'package:test23/data/user_account_data.dart';
import 'package:test23/pages/akun/halaman_bantuan_faq.dart';
import 'package:test23/pages/akun/halaman_notifikasi.dart';
import 'package:test23/pages/akun/halaman_pengaturan_akun.dart';
import 'package:test23/pages/akun/halaman_riwayat_setor.dart';
import 'package:test23/pages/akun/halaman_riwayat_transaksi.dart';
import 'package:test23/pages/auth/halaman_login.dart';
import 'package:test23/pages/konten/halaman_upload_konten.dart';
import 'package:test23/widgets/akun/banner_dampak_positif.dart';
import 'package:test23/widgets/akun/card_menu_akun.dart';
import 'package:test23/widgets/akun/card_profil_user.dart';
import 'package:test23/widgets/akun/card_statistik_akun.dart';
import 'package:test23/widgets/akun/header_akun.dart';
import 'package:test23/widgets/akun/tombol_keluar.dart';
import 'package:test23/widgets/umum/auth_required_modal.dart';

class HalamanAkun extends StatefulWidget {
  const HalamanAkun({super.key});

  @override
  State<HalamanAkun> createState() => _HalamanAkunState();
}

class _HalamanAkunState extends State<HalamanAkun> {
  String _namaLengkap = 'Pengguna Tamu';
  String _username = 'Silakan masuk untuk mengakses fitur akun';
  String _nomorTelepon = '';

  @override
  void initState() {
    super.initState();
    _syncStateFromAccountData();
    if (UserAccountData.isLoggedIn) {
      _fetchProfileDariAPI();
    }
  }

  String _formatPhoneForInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62') && digits.length >= 10) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  void _syncStateFromAccountData() {
    if (!UserAccountData.isLoggedIn) {
      _namaLengkap = 'Pengguna Tamu';
      _username = 'Silakan masuk untuk mengakses fitur akun';
      _nomorTelepon = '';
    } else {
      _namaLengkap = UserAccountData.currentNama.isNotEmpty
          ? UserAccountData.currentNama
          : 'Pengguna TR4SH';
      _username = UserAccountData.currentUsername.isNotEmpty
          ? (UserAccountData.currentUsername.startsWith('@')
              ? UserAccountData.currentUsername
              : '@${UserAccountData.currentUsername}')
          : '';
      _nomorTelepon = _formatPhoneForInput(UserAccountData.currentPhone);
    }
  }

  // Tarik profil terbaru (nama, no_wa, foto, statistik) langsung dari backend Laravel
  Future<void> _fetchProfileDariAPI() async {
    if (UserAccountData.currentUserId == null) return;

    try {
      await ApiService.getUserSession();
      final res = await ApiService.fetchUserProfile(
        idUser: UserAccountData.currentUserId,
      );
      if (mounted) {
        setState(() {
          if (res.success && res.data is Map) {
            UserAccountData.updateFromUserData(
              Map<String, dynamic>.from(res.data as Map),
            );
          }
          _syncStateFromAccountData();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(_syncStateFromAccountData);
      }
    }
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _namaLengkap);
    final userCtrl = TextEditingController(text: _username);
    final phoneCtrl = TextEditingController(text: _nomorTelepon);
    final picker = ImagePicker();

    XFile? selectedPhoto;
    Uint8List? selectedPhotoBytes;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          Future<void> pickProfilePhoto() async {
            try {
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 800,
                imageQuality: 80,
              );
              if (picked == null) return;
              final bytes = await picked.readAsBytes();
              setModalState(() {
                selectedPhoto = picked;
                selectedPhotoBytes = bytes;
              });
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memilih foto: $e'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }

          Widget buildPreviewAvatar() {
            if (selectedPhotoBytes != null) {
              return Image.memory(selectedPhotoBytes!, fit: BoxFit.cover);
            }
            final existingFoto = UserAccountData.currentFoto;
            if (existingFoto != null && existingFoto.isNotEmpty) {
              if (existingFoto.startsWith('http://') ||
                  existingFoto.startsWith('https://')) {
                return Image.network(
                  existingFoto,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppColors.darkGreen,
                  ),
                );
              }
            }
            return const Icon(
              Icons.person_rounded,
              size: 40,
              color: AppColors.darkGreen,
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pemilih Foto Profil
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: isSaving ? null : pickProfilePhoto,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFD6F3DD),
                                    border: Border.all(
                                      color: const Color(0xFFBFE7CA),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipOval(child: buildPreviewAvatar()),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: AppColors.limeAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: isSaving ? null : pickProfilePhoto,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.darkGreen,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              selectedPhoto != null
                                  ? 'Ganti Foto Terpilih'
                                  : 'Ubah Foto Profil',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Nama Lengkap
                    TextField(
                      controller: nameCtrl,
                      enabled: !isSaving,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                        LengthLimitingTextInputFormatter(60),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Username (Dikunci, tidak dapat diubah)
                    TextField(
                      controller: userCtrl,
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        helperText: 'Username bersifat permanen dan tidak dapat diubah',
                        filled: true,
                        fillColor: const Color(0xFFF3F6F4),
                        suffixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nomor WhatsApp / Telepon
                    TextField(
                      controller: phoneCtrl,
                      enabled: !isSaving,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nomor WhatsApp / Telepon',
                        hintText: 'Contoh: 081234567890',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.limeAccent,
                          foregroundColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                final cleanName = nameCtrl.text.trim();
                                final cleanPhone = phoneCtrl.text.trim();

                                if (cleanName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nama lengkap wajib diisi.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                final hpError =
                                    AuthValidator.validateNomorHp(cleanPhone);
                                if (hpError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(hpError),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                final userId = UserAccountData.currentUserId;
                                if (userId == null) return;

                                setModalState(() => isSaving = true);

                                final res = await ApiService.updateProfile(
                                  idUser: userId,
                                  namaLengkap: cleanName,
                                  noWa: cleanPhone,
                                  fotoFile: selectedPhoto,
                                );

                                if (!mounted) return;
                                setModalState(() => isSaving = false);

                                if (res.success) {
                                  setState(_syncStateFromAccountData);
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res.message),
                                      backgroundColor: AppColors.darkGreen,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res.message),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.darkGreen,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun TR4SH!?',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await ApiService.logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HalamanLogin()),
                (route) => false,
              );
            },
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.darkGreen,
          onRefresh: _fetchProfileDariAPI,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14),

                // ── 1. Header (HeaderAkun) ──
                HeaderAkun(
                  onNotificationTap: () {
                    if (!UserAccountData.isLoggedIn) {
                      AuthRequiredModal.show(
                        context,
                        title: 'Notifikasi Memerlukan Akun',
                        message:
                            'Silakan masuk terlebih dahulu untuk melihat notifikasi Anda.',
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HalamanNotifikasi(),
                      ),
                    );
                  },
                  onSettingsTap: () {
                    if (!UserAccountData.isLoggedIn) {
                      AuthRequiredModal.show(
                        context,
                        title: 'Pengaturan Akun Memerlukan Login',
                        message:
                            'Silakan masuk terlebih dahulu untuk mengatur akun Anda.',
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HalamanPengaturanAkun(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── 2. User Profile Card ──
                CardProfilUser(
                  name: _namaLengkap,
                  username: _username,
                  isGuest: UserAccountData.isGuest,
                  isVerified: !UserAccountData.isGuest,
                  avatarAsset: UserAccountData.isGuest
                      ? null
                      : UserAccountData.currentFoto,
                  onEditTap: () {
                    if (UserAccountData.isGuest) {
                      AuthRequiredModal.show(
                        context,
                        title: 'Masuk ke Akun',
                        message:
                            'Mode Tamu tidak dapat mengubah profil. Silakan masuk atau buat akun terlebih dahulu.',
                      );
                    } else {
                      _showEditProfileModal();
                    }
                  },
                ),

                const SizedBox(height: 16),

                // ── 3. Stats Card ──
                CardStatistikAkun(
                  totalSetoran: UserAccountData.isGuest
                      ? '0 Kali'
                      : '${UserAccountData.totalSetoran} Kali',
                  sampahTerkumpul: UserAccountData.isGuest
                      ? '0.0 kg'
                      : '${UserAccountData.totalSampahKg.toStringAsFixed(1)} kg',
                ),

                const SizedBox(height: 16),

                // ── 4. Dampak Positifmu Banner ──
                BannerDampakPositif(
                  sampahDikurangi: UserAccountData.isGuest
                      ? 'Total 0.0 kg sampah berhasil dikurangi dari TPA'
                      : 'Total ${UserAccountData.totalSampahKg.toStringAsFixed(1)} kg sampah berhasil dikurangi dari TPA',
                  reduksiCO2: UserAccountData.isGuest
                      ? 'Setara 0.0 kg reduksi CO2e'
                      : 'Setara ${(UserAccountData.totalSampahKg * 1.45).toStringAsFixed(1)} kg reduksi CO2e',
                ),

                const SizedBox(height: 16),

                // ── 5. Menu List Card ──
                CardMenuAkun(
                  onMenuTap: (menuTitle) {
                    if (UserAccountData.isGuest) {
                      AuthRequiredModal.show(
                        context,
                        title: '$menuTitle Memerlukan Akun',
                        message:
                            'Silakan masuk atau daftar akun terlebih dahulu untuk mengakses menu $menuTitle.',
                      );
                      return;
                    }

                    if (menuTitle == 'Riwayat Transaksi') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanRiwayatTransaksi(),
                        ),
                      );
                    } else if (menuTitle == 'Riwayat Setor Sampah') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanRiwayatSetor(),
                        ),
                      );
                    } else if (menuTitle == 'Konten Edukasi Saya') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanUploadKonten(),
                        ),
                      );
                    } else if (menuTitle == 'Notifikasi') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanNotifikasi(),
                        ),
                      );
                    } else if (menuTitle == 'Bantuan & FAQ') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanBantuanFaq(),
                        ),
                      );
                    } else if (menuTitle == 'Pengaturan Akun') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HalamanPengaturanAkun(),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 18),

                // ── 6. Tombol Masuk/Keluar ──
                if (UserAccountData.isGuest)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HalamanLogin(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text(
                          'Masuk / Buat Akun Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  TombolKeluar(onLogoutTap: _showLogoutDialog),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}