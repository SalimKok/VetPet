import 'package:flutter/material.dart';
import '../services/clinic_service.dart';

class VetClinicsPage extends StatefulWidget {
  final int vetId;
  const VetClinicsPage({required this.vetId, Key? key}) : super(key: key);

  @override
  State<VetClinicsPage> createState() => _VetClinicsPageState();
}

class _VetClinicsPageState extends State<VetClinicsPage> {
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  void _loadClinics() async {
    setState(() => isLoading = true);
    clinics = await ClinicService.getVetClinics(widget.vetId);
    setState(() => isLoading = false);
  }

  Future<void> _showClinicDialog({Map<String, dynamic>? clinic}) async {
    final nameController = TextEditingController(text: clinic?['name'] ?? '');
    final addressController = TextEditingController(text: clinic?['address'] ?? '');
    final phoneController = TextEditingController(text: clinic?['phone'] ?? '');
    final hoursController = TextEditingController(text: clinic?['working_hours'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clinic == null ? "Yeni Klinik" : "Klinik Düzenle"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Klinik Adı"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Adres"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Telefon"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(labelText: "Çalışma Saatleri"),
              ),
            ],
          ),
        ),
        actions: [
          if (clinic != null)
            TextButton(
              onPressed: () async {
                final success = await ClinicService.deleteClinic(clinic['id']);
                if (success) {
                  Navigator.pop(context);
                  _loadClinics();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Klinik silindi!")),
                  );
                }
              },
              child: const Text("Sil"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success;
              if (clinic == null) {
                success = await ClinicService.createClinic(
                  vetId: widget.vetId,
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  workingHours: hoursController.text,
                );
              } else {
                success = await ClinicService.updateClinic(
                  clinicId: clinic['id'],
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  workingHours: hoursController.text,
                );
              }

              if (success) {
                Navigator.pop(context);
                _loadClinics();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(clinic == null ? "Klinik eklendi!" : "Klinik güncellendi!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("İşlem başarısız!")),
                );
              }
            },
            child: Text(clinic == null ? "Kaydet" : "Güncelle"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE), // Diğer sayfalarla aynı arka plan
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF81C784),
        onPressed: () => _showClinicDialog(),
        child: const Icon(Icons.add),
      ),
      body: clinics.isEmpty
          ? const Center(child: Text("Henüz klinik eklenmedi!"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final c = clinics[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                c['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              subtitle: Text(
                "${c['address'] ?? ''}\n📞 ${c['phone'] ?? '-'}\n🕒 ${c['working_hours'] ?? '-'}",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.brown),
                onPressed: () => _showClinicDialog(clinic: c),
              ),
            ),
          );
        },
      ),
    );
  }
}
