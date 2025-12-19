import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petvet/pages/register_page.dart';
import 'package:petvet/utils/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  Future<void> _handleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => rememberMe = value);

    if (value) {
      await prefs.setString('saved_email', emailController.text.trim());
      await prefs.setString('saved_password', passwordController.text.trim());
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color:const Color(0xFF22577A),),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF22577A),
          ),
          onPressed: () =>
              setState(() => isPasswordVisible = !isPasswordVisible),
        )
            : null,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    await LoginService.login(
      context: context,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      rememberMe: rememberMe,
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/pet_logo.jpg',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "VetPet'e Hoş Geldiniz 🐾",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Evcil dostlarınız için en iyi veteriner deneyimi",
              style: TextStyle(fontSize: 14, color: Colors.brown, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              label: 'Şifre',
              icon: Icons.lock_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  activeColor: const Color(0xFF81C784),
                    onChanged: (bool? value) {
                      if (value != null) {
                        _handleRememberMe(value);
                      }
                    },
                ),
                const Text(
                  "Beni Hatırla",
                  style: TextStyle(color: Colors.brown, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: const Text(
                'Hesabınız yok mu? Kayıt Olun 🐶',
                style: TextStyle(color: Colors.brown, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
