import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'book_appointment_page.dart';

class ClinicDetailPage extends StatelessWidget {
  final Map<String, dynamic> clinic;
  final int ownerId;

  const ClinicDetailPage({
    Key? key,
    required this.clinic,
    required this.ownerId, // Constructor'a eklendi
  }) : super(key: key);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      await launchUrl(launchUri);
    } catch (e) {
      print("Arama hatası: $e");
    }
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);

    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Harita açma hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullAddress = "";
    if (clinic['city_name'] != null) fullAddress += "${clinic['city_name']} / ";
    if (clinic['district_name'] != null) fullAddress += "${clinic['district_name']} \n";
    fullAddress += clinic['address_details'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: Text(clinic['name']),
        backgroundColor: const Color(0xFF81C784),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.green.shade100,
              child: Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 100,
                  color: Colors.green.shade700,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Vet. Hekim: ${clinic['vet_name'] ?? 'Belirtilmemiş'}",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  const Text("İletişim Bilgileri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(fullAddress),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: Text(clinic['phone'] ?? "Numara Yok"),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time, color: Colors.orange),
                    title: Text(clinic['working_hours'] ?? "Belirtilmemiş"),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // ARAMA BUTONU
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (clinic['phone'] != null && clinic['phone'].isNotEmpty) {
                              _makePhoneCall(clinic['phone']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Telefon numarası mevcut değil.")),
                              );
                            }
                          },
                          icon: const Icon(Icons.call),
                          label: const Text("Hemen Ara"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // YOL TARİFİ BUTONU
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            String queryAddress = "${clinic['name']} ${clinic['city_name'] ?? ''} ${clinic['district_name'] ?? ''}";
                            _openMap(queryAddress);
                          },
                          icon: const Icon(Icons.map),
                          label: const Text("Yol Tarifi"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.brown),
                      ),
                      child: const Text("Randevu Al", style: TextStyle(fontSize: 16, color: Colors.brown)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}