import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/appointment_service.dart';
import '../../services/vet_patients_service.dart';

class VetAppointmentsPage extends StatefulWidget {
  final int vetId;
  const VetAppointmentsPage({required this.vetId, Key? key}) : super(key: key);

  @override
  State<VetAppointmentsPage> createState() => _VetAppointmentsPageState();
}

class _VetAppointmentsPageState extends State<VetAppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() async {
    setState(() => isLoading = true);
    appointments = await AppointmentService.getVetAppointments(widget.vetId);
    setState(() => isLoading = false);
  }

  // --- Durum Yardımcıları ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed': return Colors.green.shade700;
      case 'rejected': return Colors.red.shade700;
      case 'completed': return Colors.blue.shade700;
      default: return Colors.orange.shade800;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return "ONAY BEKLİYOR";
      case 'approved': return "ONAYLANDI";
      case 'confirmed': return "PLANLANDI";
      case 'completed': return "TAMAMLANDI";
      case 'rejected': return "İPTAL EDİLDİ";
      default: return status.toUpperCase();
    }
  }

  void _showAddAppointmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Köşeleri yuvarlatmak için şeffaf yaptık
      builder: (ctx) => _AddAppointmentForm(
        vetId: widget.vetId,
        onSuccess: () {
          Navigator.pop(ctx);
          _loadAppointments();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Randevu oluşturuldu!"), backgroundColor: Colors.green),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Randevu Yönetimi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22577A),
        onPressed: _showAddAppointmentSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Randevu Yaz", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22577A)))
          : appointments.isEmpty
          ? const Center(child: Text("Henüz bekleyen randevu yok.", style: TextStyle(color: Colors.brown)))
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final a = appointments[index];
          final status = a['status'] ?? 'pending';
          final statusColor = _getStatusColor(status);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                    // Durum Şeridi
                    Container(width: 6, color: statusColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Üst Başlık (Pet İsmi)
                            Row(
                              children: [
                                const Icon(Icons.pets, size: 18, color: Color(0xFF22577A)),
                                const SizedBox(width: 8),
                                Text(
                                  a['pet_name'] ?? 'Bilinmiyor',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22577A), fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Detaylar
                            _buildDetailRow(Icons.calendar_today_rounded, DateFormat('dd MMMM yyyy - HH:mm').format(DateTime.parse(a['date']))),
                            const SizedBox(height: 6),
                            _buildDetailRow(Icons.info_outline_rounded, "Sebep: ${a['reason'] ?? '-'}"),

                            const SizedBox(height: 12),

                            // Durum Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
                              child: Text(_getStatusText(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                            ),

                            // Butonlar (Sadece Aksiyon Gerekiyorsa)
                            if (status == 'pending' || status == 'approved' || status == 'confirmed') ...[
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: _buildActionButtons(a['id'], status),
                              ),
                            ],
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
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500))),
      ],
    );
  }

  List<Widget> _buildActionButtons(int appointmentId, String status) {
    if (status == 'pending') {
      return [
        TextButton(
          onPressed: () async {
            await AppointmentService.updateAppointmentStatus(appointmentId, 'rejected');
            _loadAppointments();
          },
          child: const Text("REDDET", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () async {
            await AppointmentService.updateAppointmentStatus(appointmentId, 'approved');
            _loadAppointments();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text("ONAYLA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ];
    } else {
      return [
        ElevatedButton.icon(
          onPressed: () async {
            await AppointmentService.updateAppointmentStatus(appointmentId, 'completed');
            _loadAppointments();
          },
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text("TAMAMLA", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ];
    }
  }
}

// --- Yeni Randevu Formu (Bottom Sheet) ---
class _AddAppointmentForm extends StatefulWidget {
  final int vetId;
  final VoidCallback onSuccess;
  const _AddAppointmentForm({required this.vetId, required this.onSuccess});

  @override
  State<_AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<_AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  List<dynamic> _myPatients = [];
  int? _selectedPetId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 09, minute: 00);
  bool _isLoading = false;
  bool _isPatientsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  void _fetchPatients() async {
    try {
      final patients = await VetPatientsService().getMyPatients(widget.vetId);
      setState(() {
        _myPatients = patients;
        _isPatientsLoading = false;
      });
    } catch (e) {
      setState(() => _isPatientsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFECE8D9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Randevu / Aşı Yaz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22577A))),
              const SizedBox(height: 24),

              // Hasta Seçimi
              _buildStyledContainer(
                child: _isPatientsLoading
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Hasta Seçiniz", prefixIcon: Icon(Icons.pets), border: InputBorder.none),
                  value: _selectedPetId,
                  items: _myPatients.map((pet) => DropdownMenuItem<int>(value: pet['id'], child: Text("${pet['name']} (${pet['owner_name']})"))).toList(),
                  onChanged: (val) => setState(() => _selectedPetId = val),
                  validator: (val) => val == null ? "Hasta seçimi zorunludur" : null,
                ),
              ),
              const SizedBox(height: 12),

              // Sebep
              _buildStyledContainer(
                child: TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: "Muayene Nedeni / Aşı Tipi", prefixIcon: Icon(Icons.edit_note), border: InputBorder.none),
                  validator: (val) => val!.isEmpty ? "Sebep giriniz" : null,
                ),
              ),
              const SizedBox(height: 12),

              // Tarih ve Saat
              Row(
                children: [
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.calendar_today,
                      label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                        if (d != null) setState(() => _selectedDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerButton(
                      icon: Icons.access_time,
                      label: _selectedTime.format(context),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _selectedTime);
                        if (t != null) setState(() => _selectedTime = t);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22577A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("RANDEVU OLUŞTUR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }

  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF22577A)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22577A))),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPetId == null) return;
    setState(() => _isLoading = true);
    final finalDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    final success = await AppointmentService().createAppointmentByVet(vetId: widget.vetId, petId: _selectedPetId!, date: finalDateTime, reason: _reasonController.text);
    setState(() => _isLoading = false);
    if (success) widget.onSuccess();
  }
}