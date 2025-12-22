import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId; // Giriş yapmış kullanıcının ID'si

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Şifrelerin görünürlük durumlarını tutan değişkenler
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _handleUpdate() async {
    // Klavyeyi kapatarak UX'i iyileştirelim
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.changePassword(
      userId: widget.userId,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return; // Context kontrolü

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        behavior: SnackBarBehavior.floating, // Modern yüzen snackbar
        backgroundColor: result['success']
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
    );

    if (result['success']) {
      // Başarılıysa bir süre bekleyip sayfayı kapatalım
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text(
          "Şifre Güvenliği",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
        // Geri butonunun rengini temaya uygun hale getirelim
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Hesap güvenliğiniz için güçlü bir şifre oluşturun.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // --- Mevcut Şifre Alanı ---
                _buildPasswordField(
                  controller: _oldPasswordController,
                  labelText: "Mevcut Şifreniz",
                  isVisible: _isOldPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                  validator: (v) =>
                      v!.isEmpty ? "Lütfen mevcut şifrenizi girin" : null,
                ),
                const SizedBox(height: 20),

                // --- Yeni Şifre Alanı ---
                _buildPasswordField(
                  controller: _newPasswordController,
                  labelText: "Yeni Şifre",
                  isVisible: _isNewPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                  // Buraya daha karmaşık regex kontrolleri de eklenebilir
                  validator: (v) =>
                      v!.length < 6 ? "Şifre en az 6 karakter olmalıdır" : null,
                ),
                const SizedBox(height: 20),

                // --- Yeni Şifre Tekrar Alanı ---
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  labelText: "Yeni Şifre (Tekrar)",
                  isVisible: _isConfirmPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (v) {
                    if (v != _newPasswordController.text)
                      return "Şifreler eşleşmiyor";
                    if (v!.isEmpty) return "Lütfen şifrenizi tekrar girin";
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleUpdate(),
                ),

                const SizedBox(height: 40),

                // --- Aksiyon Butonu ---
                SizedBox(
                  height: 56, // Modern buton yüksekliği
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22577A),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            "Şifreyi Güncelle",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kod tekrarını önlemek ve tutarlı bir tasarım sağlamak için yardımcı metot.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Modern, dolgulu (filled) input stili
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        // Temanın surface rengine göre hafif bir ton farkı yaratalım
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF22577A),
          ),
          onPressed: onVisibilityToggle,
          tooltip: isVisible ? "Şifreyi Gizle" : "Şifreyi Göster",
        ),
        border: borderStyle,
        enabledBorder: borderStyle,
        // Odaklanıldığında tema renginde belirgin bir çerçeve
        focusedBorder: borderStyle.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: borderStyle.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: borderStyle.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }
}
