/// Validator untuk autentikasi (Masuk & Pendaftaran) di aplikasi TR4SH.
/// Memisahkan logic if-else agar kode halaman UI tetap rapi dan mudah dibaca.
class AuthValidator {
  AuthValidator._();

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

    if (cleanUsername.length < 3) {
      return 'Username minimal 3 karakter!';
    }

    if (cleanPassword.length < 6) {
      return 'Kata sandi minimal 6 karakter!';
    }

    if (!setuju) {
      return 'Anda harus menyetujui Syarat & Ketentuan!';
    }

    return null;
  }
}
