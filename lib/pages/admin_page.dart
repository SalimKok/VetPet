import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petvet/pages/login_page.dart'; // Çıkış yapınca dönmek için

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminPage> {
  // Başlangıç verileri (0 olarak başlatıyoruz)
  Map<String, dynamic> stats = {
    "total_users": 0,
    "total_vets": 0,
    "total_owners": 0,
    "total_appointments": 0
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  // Backend'den istatistikleri çeken fonksiyon
  Future<void> fetchStats() async {
    // DİKKAT: URL'in sonu /api/admin/stats olmalı
    final url = Uri.parse("http://10.0.2.2:5000/api/admin/stats");

    try {
      print("İstek gönderiliyor: $url"); // Terminale bilgi basar
      final response = await http.get(url);

      print("Sunucu Cevabı: ${response.statusCode}"); // Kodu görürüz (200, 404, 500?)

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stats = {
            "total_users": data['total_users'],
            "total_vets": data['total_vets'],
            "total_owners": data['total_owners'],
            "total_appointments": data['total_appointments']
          };
          isLoading = false; // Yükleme bitti
        });
      } else {
        // Hata olsa bile loading'i kapat ki ekranı görelim
        print("Sunucu hatası: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      // Bağlantı koparsa buraya düşer
      print("BAĞLANTI HATASI: $e");
      setState(() => isLoading = false); // Yüklemeyi kapat

      // Ekrana hata mesajı fırlat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bağlantı Hatası: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Çıkış Yapma Fonksiyonu
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE), // Uygulama genel rengin
      appBar: AppBar(
        title: const Text("Yönetim Paneli"),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Genel Bakış",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(height: 16),

            // --- İSTATİSTİK KARTLARI (GRID) ---
            GridView.count(
              crossAxisCount: 2, // Yan yana 2 kutu
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard("Toplam Üye", stats['total_users'].toString(), Icons.people, Colors.blue),
                _buildStatCard("Veterinerler", stats['total_vets'].toString(), Icons.medical_services, Colors.orange),
                _buildStatCard("Hayvan Sahipleri", stats['total_owners'].toString(), Icons.pets, Colors.green),
                _buildStatCard("Randevular", stats['total_appointments'].toString(), Icons.calendar_today, Colors.purple),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Hızlı İşlemler",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(height: 10),

            // --- YÖNETİM LİSTESİ ---
            _buildActionTile(
              title: "Kullanıcıları Yönet",
              subtitle: "Tüm kayıtlı kullanıcıları listele ve düzenle",
              icon: Icons.manage_accounts,
              onTap: () {
                // Buraya Kullanıcı Listesi sayfasına yönlendirme gelecek
                // Navigator.push(...)
              },
            ),
            _buildActionTile(
              title: "Veteriner Onayları",
              subtitle: "Bekleyen veteriner başvurularını incele",
              icon: Icons.verified_user,
              color: const Color(0xFFD32F2F), // Dikkat çeksin diye kırmızımsı
              onTap: () {
                // Onay sayfasına git
              },
            ),
            _buildActionTile(
              title: "Sistem Ayarları",
              subtitle: "Uygulama genel ayarları",
              icon: Icons.settings,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik Kartı Tasarımı (Widget)
  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Aksiyon Butonu Tasarımı (ListTile)
  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF4E342E),
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}