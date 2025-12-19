import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/appointment_service.dart';
import '../../services/pet_service.dart';
import '../../services/vet_service.dart';

class AppointmentPage extends StatefulWidget {
  final int ownerId;
  const AppointmentPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> pets = [];
  List<Map<String, dynamic>> vets = [];
  Map<int, String> petNames = {};
  Map<int, String> vetNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() async {
    setState(() => isLoading = true);
    pets = await PetService.getPets(widget.ownerId);
    vets = await VetService.getVets();
    petNames = {for (var pet in pets) pet['id']: pet['name']};
    vetNames = {for (var vet in vets) vet['id']: vet['name']};
    appointments = await AppointmentService.getOwnerAppointments(widget.ownerId);
    setState(() => isLoading = false);
  }

  String _getStatusTR(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳ Onay Bekliyor';
      case 'approved':
        return '👍 Onaylandı';
      case 'rejected':
        return '❌ Reddedildi';
      case 'completed':
        return '✔️ Tamamlandı';
      case 'cancelled':
        return '🚫 İptal Edildi';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
      case 'cancelled':
        return Colors.red.shade700;
      case 'completed':
        return Colors.blue.shade700;
      default:
        return Colors.black87;
    }
  }

  Future<void> _showAddOrEditAppointmentDialog({Map<String, dynamic>? appointment}) async {
    int? selectedPetId = appointment?['pet_id'];
    int? selectedVetId = appointment?['vet_id'];
    DateTime? selectedDate = appointment != null ? DateTime.parse(appointment['date']) : null;
    String reason = appointment?['reason'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(appointment == null ? "Yeni Randevu" : "Randevu Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedPetId,
                  decoration: const InputDecoration(labelText: "Evcil Hayvan"),
                  items: pets.map((pet) => DropdownMenuItem<int>(
                    value: pet['id'],
                    child: Text(pet['name']),
                  )).toList(),
                  onChanged: (val) => selectedPetId = val,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedVetId,
                  decoration: const InputDecoration(labelText: "Veteriner"),
                  items: vets.map((vet) => DropdownMenuItem<int>(
                    value: vet['id'],
                    child: Text(vet['name']),
                  )).toList(),
                  onChanged: (val) => selectedVetId = val,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedDate != null
                            ? TimeOfDay.fromDateTime(selectedDate!)
                            : TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                  child: Text(selectedDate != null
                      ? DateFormat('yyyy-MM-dd – kk:mm').format(selectedDate!)
                      : "Tarih ve Saat Seç"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: reason),
                  decoration: const InputDecoration(labelText: "Sebep (opsiyonel)"),
                  onChanged: (val) => reason = val,
                ),
              ],
            ),
          ),
          actions: [
            if (appointment != null)
              TextButton(
                onPressed: () async {
                  final success = await AppointmentService.deleteAppointment(appointment['id']);
                  if (success) {
                    Navigator.pop(context);
                    _loadAppointments();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Randevu iptal edildi!")),
                    );
                  }
                },
                child: const Text("İptal Et"),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kapat"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPetId == null || selectedVetId == null || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tüm zorunlu alanları doldurun!")),
                  );
                  return;
                }

                bool success;
                if (appointment == null) {
                  success = await AppointmentService.createAppointment(
                    petId: selectedPetId!,
                    ownerId: widget.ownerId,
                    vetId: selectedVetId!,
                    clinicId: null,
                    date: selectedDate!,
                    reason: reason,
                  );
                } else {
                  success = await AppointmentService.updateAppointment(
                    appointmentId: appointment['id'],
                    date: selectedDate!,
                    reason: reason,
                  );
                }

                if (success) {
                  Navigator.pop(context);
                  _loadAppointments();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appointment == null ? "Randevu oluşturuldu!" : "Randevu güncellendi!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("İşlem başarısız!")),
                  );
                }
              },
              child: Text(appointment == null ? "Kaydet" : "Güncelle"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor:const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Randevularım",style: TextStyle(color:  const Color(0xFFFFFFFF)),),
        backgroundColor: const Color(0xFF22577A),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: appointments.isEmpty
                ? const Center(child: Text("Henüz randevu yok!"))
                : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final a = appointments[index];
                final petName = petNames[a['pet_id']] ?? 'Bilinmiyor';
                final rawStatus = a['status'] ?? 'pending';

                final statusTR = _getStatusTR(rawStatus);
                final statusColor = _getStatusColor(rawStatus);
                final bool isEditable = rawStatus == 'pending';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      "Evcil Hayvan: $petName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Veteriner: ${vetNames[a['vet_id']] ?? 'Bilinmiyor'}"),
                        Text("Tarih: ${DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.parse(a['date']))}"),
                        if (a['reason'] != null && a['reason'].toString().isNotEmpty)
                          Text("Sebep: ${a['reason']}"),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text("Durum: "),
                            Text(
                              statusTR,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: isEditable
                        ? IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: "Düzenle / İptal Et",
                      onPressed: () => _showAddOrEditAppointmentDialog(appointment: a),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22577A),
                foregroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => _showAddOrEditAppointmentDialog(),
              child: const Text("Yeni Randevu Oluştur"),
            ),
          ),
        ],
      ),
    );
  }
}