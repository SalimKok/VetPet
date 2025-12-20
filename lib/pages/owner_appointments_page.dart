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

  // --- Yardımcı Tasarım Widget'ları ---

  String _getStatusTR(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Onay Bekliyor';
      case 'approved': return 'Onaylandı';
      case 'rejected': return 'Reddedildi';
      case 'completed': return 'Tamamlandı';
      case 'cancelled': return 'İptal Edildi';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange.shade800;
      case 'approved': return Colors.green.shade700;
      case 'rejected':
      case 'cancelled': return Colors.red.shade700;
      case 'completed': return Colors.blue.shade700;
      default: return Colors.black87;
    }
  }

  Widget _buildAppointmentDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF22577A)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  // --- Randevu Ekleme/Düzenleme Penceresi ---

  Future<void> _showAddOrEditAppointmentDialog({Map<String, dynamic>? appointment}) async {
    int? selectedPetId = appointment?['pet_id'];
    int? selectedVetId = appointment?['vet_id'];
    DateTime? selectedDate = appointment != null ? DateTime.parse(appointment['date']) : null;
    final TextEditingController reasonController = TextEditingController(text: appointment?['reason'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFFECE8D9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            appointment == null ? "Yeni Randevu" : "Randevuyu Düzenle",
            style: const TextStyle(color: Color(0xFF22577A), fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStyledDropdown<int>(
                  value: selectedPetId,
                  label: "Evcil Hayvan",
                  icon: Icons.pets,
                  items: pets.map((p) => DropdownMenuItem(value: p['id'] as int, child: Text(p['name']))).toList(),
                  onChanged: (val) => setModalState(() => selectedPetId = val),
                ),
                _buildStyledDropdown<int>(
                  value: selectedVetId,
                  label: "Veteriner Hekim",
                  icon: Icons.person,
                  items: vets.map((v) => DropdownMenuItem(value: v['id'] as int, child: Text(v['name']))).toList(),
                  onChanged: (val) => setModalState(() => selectedVetId = val),
                ),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setModalState(() => selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF22577A)),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null ? DateFormat('dd/MM/yyyy - HH:mm').format(selectedDate!) : "Tarih ve Saat Seç",
                          style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: "Sebep (opsiyonel)",
                    prefixIcon: const Icon(Icons.notes, color: Color(0xFF22577A)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Kapat", style: TextStyle(color: Colors.brown))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22577A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (selectedPetId == null || selectedVetId == null || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tüm alanları doldurun!")));
                  return;
                }
                bool success = appointment == null
                    ? await AppointmentService.createAppointment(petId: selectedPetId!, ownerId: widget.ownerId, vetId: selectedVetId!, clinicId: null, date: selectedDate!, reason: reasonController.text)
                    : await AppointmentService.updateAppointment(appointmentId: appointment['id'], date: selectedDate!, reason: reasonController.text);
                if (success) {
                  Navigator.pop(context);
                  _loadAppointments();
                }
              },
              child: Text(appointment == null ? "Kaydet" : "Güncelle", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Randevularım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22577A)))
          : Column(
        children: [
          Expanded(
            child: appointments.isEmpty
                ? const Center(child: Text("Henüz randevunuz bulunmuyor.", style: TextStyle(color: Colors.brown)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final a = appointments[index];
                final petName = petNames[a['pet_id']] ?? 'Bilinmiyor';
                final rawStatus = a['status'] ?? 'pending';
                final statusTR = _getStatusTR(rawStatus);
                final bool isEditable = rawStatus == 'pending';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(width: 6, color: _getStatusColor(rawStatus)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.pets, size: 18, color: Color(0xFF22577A)),
                                        const SizedBox(width: 8),
                                        Text(petName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF22577A))),
                                      ]),
                                      if (isEditable)
                                        GestureDetector(
                                          onTap: () => _showAddOrEditAppointmentDialog(appointment: a),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: const Color(0xFF22577A).withOpacity(0.1), shape: BoxShape.circle),
                                            child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF22577A)),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAppointmentDetail(Icons.medical_services_outlined, "Hekim:", vetNames[a['vet_id']] ?? 'Bilinmiyor'),
                                  const SizedBox(height: 6),
                                  _buildAppointmentDetail(Icons.calendar_today_outlined, "Tarih:", DateFormat('dd MMMM yyyy – HH:mm').format(DateTime.parse(a['date']))),
                                  if (a['reason'] != null && a['reason'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _buildAppointmentDetail(Icons.chat_bubble_outline_rounded, "Not:", a['reason']),
                                  ],
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: _getStatusColor(rawStatus).withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
                                    child: Text(statusTR.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(rawStatus), letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => _showAddOrEditAppointmentDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Yeni Randevu Oluştur", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}