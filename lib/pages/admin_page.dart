import 'package:flutter/material.dart';
import 'package:petvet/pages/admin/vet_approval_page.dart';
import 'package:petvet/pages/login_page.dart';
import 'package:petvet/pages/admin/user_management_page.dart';
import 'package:petvet/services/admin_service.dart';

import 'admin_appointment_management_page.dart';
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminPage> {
  final AdminService _adminService = AdminService();

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
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await _adminService.fetchStats();

      setState(() {
        stats = {
          "total_users": data['total_users']-1,
          "total_vets": data['total_vets'],
          "total_owners": data['total_owners'],
          "total_appointments": data['total_appointments']
        };
        isLoading = false;
      });
    } catch (e) {
      print("İstatistik Hatası: $e");
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veriler alınamadı: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
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
            const SizedBox(height: 16),
            // --- İSTATİSTİK KARTLARI ---
            GridView.count(
              crossAxisCount: 2,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                );
              },
            ),
            _buildActionTile(
              title: "Veteriner Onayları",
              subtitle: "Bekleyen veteriner başvurularını incele",
              icon: Icons.verified_user,
              color: const Color(0xFFD32F2F),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VetApprovalPage()),
                ).then((_) {
                  _loadStats();
                });
              },
            ),
            _buildActionTile(
              title: "Tüm Randevuları Yönet",
              subtitle: "Sistemdeki aktif ve geçmiş tüm randevuları gör",
              icon: Icons.event_note,
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminAppointmentManagementPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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