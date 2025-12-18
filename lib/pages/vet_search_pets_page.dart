import 'package:flutter/material.dart';
import '../../services/vet_patients_service.dart';


class VetSearchPetsPage extends StatefulWidget {
  final int vetId;
  const VetSearchPetsPage({Key? key, required this.vetId}) : super(key: key);

  @override
  State<VetSearchPetsPage> createState() => _VetSearchPetsPageState();
}

class _VetSearchPetsPageState extends State<VetSearchPetsPage> {
  final VetPatientsService _vetPatientsService = VetPatientsService();

  List<dynamic> _allPets = [];
  List<dynamic> _filteredPets = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllPets();
  }

  void _loadAllPets() async {
    try {
      final pets = await _vetPatientsService.getAllPets();
      setState(() {
        _allPets = pets;
        _filteredPets = pets;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => _isLoading = false);
    }
  }

  void _runFilter(String keyword) {
    List<dynamic> results = [];
    if (keyword.isEmpty) {
      results = _allPets;
    } else {
      results = _allPets
          .where((pet) => pet['name'].toString().toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredPets = results;
    });
  }

  void _addPetToMyList(int petId, String petName) async {
    final result = await _vetPatientsService.addPatient(widget.vetId, petId);

    if (!mounted) return;

    if (result.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Hasta Ekle"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                labelText: 'Hayvan Adı Ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // LİSTE
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPets.isEmpty
                ? const Center(child: Text("Kayıt bulunamadı."))
                : ListView.builder(
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                final pet = _filteredPets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(pet['name'][0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                    title: Text(
                      "${pet['name']} (ID: ${pet['id']})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${pet['species']} (${pet['breed']})\nSahibi: ${pet['owner_name']}"),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () {
                        _addPetToMyList(pet['id'], pet['name']);
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}