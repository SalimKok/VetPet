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

  void _showAddAppointmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _AddAppointmentForm(
          vetId: widget.vetId,
          onSuccess: () {
            Navigator.pop(ctx);
            _loadAppointments();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Randevu oluşturuldu!")),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Randevularım",style: TextStyle(color: const Color(0xFFFFFFFF))),
        backgroundColor: const Color(0xFF22577A),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22577A),
        child: const Icon(Icons.add,color: const Color(0xFFFFFFFF)),
        onPressed: _showAddAppointmentSheet,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? const Center(child: Text("Henüz randevu yok!"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final a = appointments[index];
          final appointmentId = a['id'];
          final status = a['status'] ?? 'pending';

          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Evcil Hayvan: ${a['pet_name'] ?? 'Bilinmiyor'}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(DateFormat('yyyy-MM-dd – HH:mm')
                          .format(DateTime.parse(a['date']))),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("Sebep: ${a['reason'] ?? '-'}"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BUTONLAR
                  if (status == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await AppointmentService.updateAppointmentStatus(
                                appointmentId, 'rejected');
                            _loadAppointments();
                          },
                          child: const Text("Reddet", style: TextStyle(color: Colors.red)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await AppointmentService.updateAppointmentStatus(
                                appointmentId, 'approved');
                            _loadAppointments();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("Onayla"),
                        ),
                      ],
                    ),

                  if (status == 'approved' || status == 'confirmed')
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await AppointmentService.updateAppointmentStatus(
                              appointmentId, 'completed');
                          _loadAppointments();
                        },
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text("Tamamla"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Yardımcı renk fonksiyonu
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return "ONAY BEKLİYOR";
      case 'approved': return "ONAYLANDI";
      case 'confirmed': return "PLANLANDI";
      case 'completed': return "TAMAMLANDI";
      case 'rejected': return "İPTAL EDİLDİ";
      default: return status.toUpperCase();
    }
  }
}

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
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 00);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen hasta seçin ve alanları doldurun.")));
      return;
    }

    setState(() => _isLoading = true);

    final DateTime finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final success = await AppointmentService().createAppointmentByVet(
      vetId: widget.vetId,
      petId: _selectedPetId!,
      date: finalDateTime,
      reason: _reasonController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hata oluştu!")));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Yeni Randevu / Aşı Oluştur",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.brown)),
              const SizedBox(height: 20),

              // 1. HASTA SEÇİMİ (DROPDOWN)
              _isPatientsLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Hasta Seçiniz",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                value: _selectedPetId,
                items: _myPatients.map((pet) {
                  return DropdownMenuItem<int>(
                    value: pet['id'],
                    child: Text("${pet['name']} (${pet['owner_name'] ?? '-'})"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPetId = val),
                validator: (val) => val == null ? "Hasta seçimi zorunludur" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: "Sebep (Örn: Kuduz Aşısı)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (val) => val!.isEmpty ? "Sebep giriniz" : null,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (t != null) setState(() => _selectedTime = t);
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22577A),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("RANDEVU OLUŞTUR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}