import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'book_appointment_page.dart';

class ClinicDetailPage extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final int ownerId;

  const ClinicDetailPage({
    Key? key,
    required this.clinic,
    required this.ownerId,
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Arama hatası: $e");
    }
  }

  Future<void> _openMap(String address) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    final Uri url = Uri.parse(googleMapsUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Harita hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullAddress = "";
    if (clinic['city_name'] != null) fullAddress += "${clinic['city_name']} / ";
    if (clinic['district_name'] != null) fullAddress += "${clinic['district_name']} \n";
    fullAddress += clinic['address_details'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9), // Ana Tema Krem
      appBar: AppBar(
        title: Text(clinic['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A), // Ana Tema Lacivert
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22577A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.medical_services, size: 16, color: Color(0xFF22577A)),
                  const SizedBox(width: 8),
                  Text(
                    "Vet. Hekim: ${clinic['vet_name'] ?? 'Belirtilmemiş'}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF22577A)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bilgi Kutusu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile(Icons.location_on_rounded, "ADRES", fullAddress, Colors.redAccent),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(color: Color(0xFFECE8D9)),
                  ),
                  _buildInfoTile(Icons.phone_rounded, "TELEFON", clinic['phone'] ?? "Numara Yok", Colors.blueAccent),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(color: Color(0xFFECE8D9)),
                  ),
                  _buildInfoTile(Icons.access_time_filled_rounded, "ÇALIŞMA SAATLERİ", clinic['working_hours'] ?? "Belirtilmemiş", Colors.orangeAccent),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hızlı Aksiyon Butonları (Ara ve Yol Tarifi)
            Row(
              children: [
                _buildCompactButton(
                  icon: Icons.call,
                  label: "Ara",
                  color: Colors.green.shade600,
                  onTap: () => clinic['phone'] != null ? _makePhoneCall(clinic['phone']) : null,
                ),
                const SizedBox(width: 12),
                _buildCompactButton(
                  icon: Icons.directions,
                  label: "Yol Tarifi",
                  color: Colors.blueAccent,
                  onTap: () => _openMap("${clinic['name']} $fullAddress"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Randevu Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookAppointmentPage(
                        clinicId: clinic['id'],
                        clinicName: clinic['name'],
                        vetId: clinic['vet_id'],
                        vetName: clinic['vet_name'] ?? 'Hekim',
                        currentUserId: ownerId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                child: const Text(
                  "RANDEVU AL",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}