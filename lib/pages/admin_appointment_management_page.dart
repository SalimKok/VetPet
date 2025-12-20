import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminAppointmentManagementPage extends StatefulWidget {
  const AdminAppointmentManagementPage({Key? key}) : super(key: key);

  @override
  State<AdminAppointmentManagementPage> createState() => _AdminAppointmentManagementPageState();
}

class _AdminAppointmentManagementPageState extends State<AdminAppointmentManagementPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() async {
    setState(() => _isLoading = true);
    final data = await _adminService.getAllAppointments();
    setState(() {
      _appointments = data;
      _isLoading = false;
    });
  }

  // --- SİLME FONKSİYONU ---
  void _deleteAppointment(int id) async {
    // Önce kullanıcıya soralım
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Randevuyu Sil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text("Bu randevuyu sistemden kalıcı olarak silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İptal", style: TextStyle(color: Colors.brown))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Evet, Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await _adminService.deleteAnyAppointment(id); // AdminService'e eklediğiniz metot
      if (success) {
        _fetchAppointments();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Randevu başarıyla silindi"), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silme işlemi başarısız!")));
      }
    }
  }

  void _changeStatus(int id, String status) async {
    bool success = await _adminService.updateAnyAppointmentStatus(id, status);
    if (success) {
      _fetchAppointments();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Durum güncellendi"), backgroundColor: Colors.green));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return "ONAY BEKLİYOR";
      case 'approved': return "ONAYLANDI";
      case 'completed': return "TAMAMLANDI";
      case 'rejected': return "REDDEDİLDİ";
      default: return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Sistem Randevuları", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A), // Admin paneli için de ana temayı kullandım
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22577A)))
          : RefreshIndicator(
        onRefresh: () async => _fetchAppointments(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            final appo = _appointments[index];
            final status = appo['status'] ?? 'pending';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF22577A).withOpacity(0.1), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ExpansionTile(
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF22577A).withOpacity(0.1),
                    child: const Icon(Icons.event_note_rounded, color: Color(0xFF22577A)),
                  ),
                  title: Row(
                    children: [
                      // PET TARAFI
                      const Icon(Icons.pets, size: 16, color: Color(0xFF22577A)),
                      const SizedBox(width: 6),
                      Text(
                        appo['pet_name'] ?? 'Pet',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),

                      // AYRAÇ
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                      ),

                      // VET TARAFI
                      const Icon(Icons.medication_rounded, size: 16, color: Color(0xFF22577A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${appo['vet_name'] ?? 'Hekim'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.brown,
                          ),
                          overflow: TextOverflow.ellipsis, // Uzun isimlerde taşmayı önler
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appo['date'] != null
                            ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(appo['date']))
                            : "Tarih Belirsiz", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_getStatusText(status),
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                        ),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          _buildDetailRow(Icons.person, "Sahibi:", appo['owner_name'] ?? '-'),
                          _buildDetailRow(Icons.info_outline, "Sebep:", appo['reason'] ?? '-'),
                          const SizedBox(height: 20),

                          // DURUM DEĞİŞTİRME BUTONLARI
                          const Text("Durumu Güncelle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _statusButton(appo['id'], "pending", Colors.orange),
                                const SizedBox(width: 8),
                                _statusButton(appo['id'], "approved", Colors.green),
                                const SizedBox(width: 8),
                                _statusButton(appo['id'], "rejected", Colors.red),
                                const SizedBox(width: 8),
                                _statusButton(appo['id'], "completed", Colors.blue),
                              ],
                            ),
                          ),
                          const Divider(height: 30),

                          // --- SİLME BUTONU ---
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteAppointment(appo['id']),
                              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                              label: const Text("RANDEVUYU SİSTEMDEN SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statusButton(int id, String status, Color color) {
    return InkWell(
      onTap: () => _changeStatus(id, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}