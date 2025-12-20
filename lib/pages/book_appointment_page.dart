import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';

class BookAppointmentPage extends StatefulWidget {
  final int clinicId;
  final String clinicName;
  final int vetId;
  final String vetName;
  final int currentUserId;

  const BookAppointmentPage({
    Key? key,
    required this.clinicId,
    required this.clinicName,
    required this.vetId,
    required this.vetName,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _noteController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedPetId;

  List<Map<String, dynamic>> myPets = [];
  bool isLoading = false;
  bool isPetsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  Future<void> _loadMyPets() async {
    try {
      final urlString = "${ApiService.baseUrl}/pets/${widget.currentUserId}";
      print("İstek atılan adres: $urlString");

      final url = Uri.parse(urlString);
      final response = await http.get(url);

      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          myPets = List<Map<String, dynamic>>.from(data['pets']);
          isPetsLoading = false;
        });

        print("Listelenen Pet Sayısı: ${myPets.length}");

      } else {
        print("Petler yüklenemedi: ${response.body}");
        setState(() => isPetsLoading = false);
      }
    } catch (e) {
      print("Pet yükleme hatası: $e");
      setState(() => isPetsLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF22577A),
              onPrimary: Colors.white,
              onSurface: Colors.brown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 09, minute: 00),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF22577A),
              onSurface: Colors.brown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _submitAppointment() async {
    if (selectedPetId == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen hayvan, tarih ve saat seçiniz.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final success = await AppointmentService.createAppointment(
      ownerId: widget.currentUserId,
      vetId: widget.vetId,
      clinicId: widget.clinicId,
      petId: selectedPetId!,
      date: finalDateTime,
      reason: _noteController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Randevunuz başarıyla oluşturuldu! ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu, tekrar deneyin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Randevu Oluştur",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF22577A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(child: Text(widget.clinicName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(child: Text("Vet. ${widget.vetName}", style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text("Hangi dostumuz için?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            isPetsLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
              value: selectedPetId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                filled: true,
                fillColor: Colors.white,
                hintText: "Evcil Hayvan Seçiniz",
              ),
              items: myPets.map((pet) {
                return DropdownMenuItem<int>(
                  value: pet['id'],
                  child: Text(pet['name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedPetId = val);
              },
              validator: (val) => val == null ? "Lütfen seçim yapın" : null,
            ),
            const SizedBox(height: 20),
            const Text("Zamanlama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.brown, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? "Tarih Seç"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.brown, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime == null
                                ? "Saat Seç"
                                : selectedTime!.format(context),
                            style: TextStyle(color: selectedTime == null ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Notunuz (Opsiyonel)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Örn: Aşı takvimi için geliyoruz...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "RANDEVUYU ONAYLA",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}