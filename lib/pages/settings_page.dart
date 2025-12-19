import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final String userRole;

  const SettingsPage({Key? key, required this.userRole}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationEnabled = true;
  bool isDarkMode = false;

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Oturumu kapatmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ApiService.currentUserId = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVet = widget.userRole == 'vet';
    final bool isOwner = widget.userRole == 'owner';

    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Ayarlar"),
        backgroundColor: const Color(0xFF22577A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("HESAP"),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: "Şifre Değiştir",
            color: Colors.blue,
            onTap: () {},
          ),

          if (isOwner)
            _buildSettingsTile(
              icon: Icons.location_on_outlined,
              title: "Kayıtlı Adreslerim",
              color: Colors.orange,
              onTap: () {},
            ),

          if (isOwner)
            _buildSettingsTile(
              icon: Icons.pets,
              title: "Evcil Hayvan Geçmişi",
              color: Colors.brown,
              onTap: () {},
            ),

          if (isVet)
            _buildSettingsTile(
              icon: Icons.local_hospital_outlined,
              title: "Klinik Ayarları",
              color: Colors.redAccent,
              onTap: () {},
            ),

          if (isVet)
            _buildSettingsTile(
              icon: Icons.access_time,
              title: "Çalışma Saatleri",
              color: Colors.teal,
              onTap: () {},
            ),

          const SizedBox(height: 20),
          _buildSectionHeader("UYGULAMA"),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined, color: Colors.red),
                  title: const Text("Bildirimler"),
                  value: isNotificationEnabled,
                  onChanged: (val) => setState(() => isNotificationEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: Colors.purple),
                  title: const Text("Karanlık Mod"),
                  value: isDarkMode,
                  onChanged: (val) => setState(() => isDarkMode = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22577A),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout),
            label: const Text("Çıkış Yap"),
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              "v1.0.0 (${isVet ? 'Veteriner' : 'Hayvan Sahibi'})",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}