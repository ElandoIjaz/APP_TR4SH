/// Validator untuk autentikasi (Masuk & Pendaftaran) di aplikasi TR4SH.
/// Memisahkan logic if-else agar kode halaman UI tetap rapi dan mudah dibaca.
class AuthValidator {
  AuthValidator._();

  /// Batasan panjang input
  static const int minHpDigits = 10;
  static const int maxHpDigits = 15;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;

  /// Validasi nomor HP mandiri.
  static String? validateNomorHp(String telepon) {
    final clean = telepon.trim();
    if (clean.isEmpty) {
      return 'Nomor telepon tidak boleh kosong!';
    }

    final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length != clean.length) {
      return 'Nomor telepon hanya boleh berisi angka!';
    }

    if (clean.length < minHpDigits) {
      return 'Nomor telepon minimal $minHpDigits digit!';
    }

    if (clean.length > maxHpDigits) {
      return 'Nomor telepon maksimal $maxHpDigits digit!';
    }

    if (!clean.startsWith('08') &&
        !clean.startsWith('628') &&
        !clean.startsWith('8')) {
      return 'Format nomor HP tidak valid (harus diawali 08, 628, atau 8)!';
    }

    return null;
  }

  /// Validasi kata sandi mandiri.
  static String? validatePassword(String password) {
    final clean = password.trim();
    if (clean.isEmpty) {
      return 'Kata sandi tidak boleh kosong!';
    }

    if (clean.length < minPasswordLength) {
      return 'Kata sandi minimal $minPasswordLength karakter!';
    }

    if (clean.length > maxPasswordLength) {
      return 'Kata sandi maksimal $maxPasswordLength karakter!';
    }

    if (clean.contains(' ')) {
      return 'Kata sandi tidak boleh mengandung spasi!';
    }

    return null;
  }

  /// Validasi form Login.
  /// Mengembalikan pesan error jika tidak valid, atau `null` jika valid.
  static String? validateLogin({
    required String username,
    required String password,
  }) {
    final cleanUsername = username.trim();
    final cleanPassword = password.trim();

    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      return 'Username dan kata sandi tidak boleh kosong!';
    }

    if (cleanPassword.length > maxPasswordLength) {
      return 'Kata sandi maksimal $maxPasswordLength karakter!';
    }

    return null;
  }

  /// Validasi form Pendaftaran (Register).
  /// Mengembalikan pesan error jika tidak valid, atau `null` jika valid.
  static String? validateRegister({
    required String nama,
    required String username,
    required String telepon,
    required String password,
    required bool setuju,
  }) {
    final cleanNama = nama.trim();
    final cleanUsername = username.trim();
    final cleanTelepon = telepon.trim();
    final cleanPassword = password.trim();

    if (cleanNama.isEmpty || cleanUsername.isEmpty || cleanTelepon.isEmpty || cleanPassword.isEmpty) {
      return 'Semua kolom harus diisi!';
    }

    if (cleanNama.length < 3) {
      return 'Nama lengkap minimal 3 karakter!';
    }

    if (cleanNama.length > 60) {
      return 'Nama lengkap maksimal 60 karakter!';
    }

    if (cleanUsername.length < 3) {
      return 'Username minimal 3 karakter!';
    }

    if (cleanUsername.length > 30) {
      return 'Username maksimal 30 karakter!';
    }

    if (cleanUsername.contains(' ')) {
      return 'Username tidak boleh mengandung spasi!';
    }

    if (cleanUsername.contains('@')) {
      return 'Username tidak boleh menggunakan simbol "@" (bukan email/gmail)!';
    }

    // ── Validasi No. Telepon ──
    final hpError = validateNomorHp(cleanTelepon);
    if (hpError != null) {
      return hpError;
    }

    // ── Validasi Kata Sandi ──
    final pwError = validatePassword(cleanPassword);
    if (pwError != null) {
      return pwError;
    }

    if (!setuju) {
      return 'Anda harus menyetujui Syarat & Ketentuan!';
    }

    return null;
  }
}
