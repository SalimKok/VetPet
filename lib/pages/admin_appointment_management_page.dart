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

  // Durum Güncelleme Fonksiyonu
  void _changeStatus(int id, String status) async {
    bool success = await _adminService.updateAnyAppointmentStatus(id, status);
    if (success) {
      _fetchAppointments();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Durum güncellendi")));
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
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: const Text("Sistem Randevuları"),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async => _fetchAppointments(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            final appo = _appointments[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.event, color: Colors.indigo),
                title: Text("${appo['pet_name']} ↔ ${appo['vet_name']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appo['date'] != null
                        ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(appo['date']))
                        : "Tarih Belirsiz"),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appo['status'] ?? 'pending').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(appo['status'] ?? 'pending')),
                      ),
                      child: Text(
                        "DURUM: ${_getStatusText(appo['status'] ?? 'pending')}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(appo['status'] ?? 'pending'),
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sahibi: ${appo['owner_name']}"),
                        Text("Sebep: ${appo['reason'] ?? '-'}"),
                        const Divider(),
                        const Text("Durumu Değiştir:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statusButton(appo['id'], "pending", Colors.orange),
                            _statusButton(appo['id'], "approved", Colors.green),
                            _statusButton(appo['id'], "rejected", Colors.red),
                            _statusButton(appo['id'], "completed", Colors.blue),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statusButton(int id, String status, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 8)),
      onPressed: () => _changeStatus(id, status),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
    );
  }
}