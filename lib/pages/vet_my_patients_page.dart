import 'package:flutter/material.dart';
import '../../services/vet_patients_service.dart';
import 'vet_search_pets_page.dart';
import 'visit_history_page.dart';

class VetMyPatientsPage extends StatefulWidget {
  final int vetId;
  const VetMyPatientsPage({Key? key, required this.vetId}) : super(key: key);

  @override
  State<VetMyPatientsPage> createState() => _VetMyPatientsPageState();
}

class _VetMyPatientsPageState extends State<VetMyPatientsPage> {
  final VetPatientsService _vetPatientsService = VetPatientsService();
  List<dynamic> _myPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPatients();
  }

  void _loadMyPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _vetPatientsService.getMyPatients(widget.vetId);
      setState(() {
        _myPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
      appBar: AppBar(
        title: const Text("Hastalarım"),
        backgroundColor: const Color(0xFF81C784),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.search),
        label: const Text("Hasta Bul / Ekle"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VetSearchPetsPage(vetId: widget.vetId),
            ),
          );
          _loadMyPatients();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPatients.isEmpty
          ? const Center(
        child: Text(
          "Henüz takip ettiğiniz bir hasta yok.\n'Hasta Bul' butonuna basarak ekleyin.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _myPatients.length,
        itemBuilder: (context, index) {
          final pet = _myPatients[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.pets, color: Colors.blue, size: 30),
              ),
              title: Text("${pet['name'] ?? 'İsimsiz'} (id:${pet['id']})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${pet['species']} - ${pet['breed']}"),
                  Text(
                    "Sahibi: ${pet['owner_name']}",
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              trailing: const Icon(Icons.receipt_long, size: 24, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitHistoryPage(
                      petId: pet['id'],
                      petName: pet['name'],
                      isVet: true,
                      vetId: widget.vetId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}