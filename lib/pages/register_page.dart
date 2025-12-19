import 'package:flutter/material.dart';
import '../utils/register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = "";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text(
          "Kayıt Ol",
          style: TextStyle(color: const Color(0xFFFFFFFF)),
        ),
        backgroundColor: const Color(0xFF22577A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(
              controller: nameController,
              label: 'Ad Soyad',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),

            //  Role seçimi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'owner',
                  groupValue: selectedRole,
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
                const Text('Owner'),
                Radio<String>(
                  value: 'vet',
                  groupValue: selectedRole,
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
                const Text('Vet'),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        await RegisterService.register(
                          context: context,
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          role: selectedRole,
                        );
                        setState(() => isLoading = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF22577A)),
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
}
