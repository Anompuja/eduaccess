/// Form field validators for use with AppTextField validator param.
/// All return null on success, error string on failure.
abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    final re = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!re.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (value != original) return 'Password tidak cocok';
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName tidak boleh kosong';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  static String? requiredDropdown<T>(T? value, {String fieldName = 'Pilihan'}) {
    if (value == null) return '$fieldName harus dipilih';
    return null;
  }
}
