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
      debugPrint(e.toString());
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
      _showCustomSnackBar(result['message'], Colors.green);
    } else {
      _showCustomSnackBar("Bir hata oluştu.", Colors.red);
    }
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9), // Tema Kremi
      appBar: AppBar(
        title: const Text("Yeni Hasta Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- ARAMA PANELİ ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFF22577A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _runFilter(value),
                decoration: InputDecoration(
                  hintText: 'Hasta ismi ile ara...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF22577A)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // --- HASTA LİSTESİ ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22577A)))
                : _filteredPets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                final pet = _filteredPets[index];
                return _buildSearchPetCard(pet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPetCard(dynamic pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF22577A).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF22577A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              (pet['name'] != null && pet['name'].toString().isNotEmpty)
                  ? pet['name'].toString()[0].toUpperCase()
                  : "?",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22577A), fontSize: 20),
            ),
          ),
        ),
        title: Text(
          "${pet['name']}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22577A), fontSize: 19),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSmallDetail(Icons.pets, "${pet['species']} • ${pet['breed']}"),
              const SizedBox(height: 2),
              _buildSmallDetail(Icons.person, "Sahibi: ${pet['owner_name']}"),
            ],
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22577A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(0),
            minimumSize: const Size(45, 45),
          ),
          onPressed: () => _addPetToMyList(pet['id'], pet['name']),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildSmallDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.brown),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.brown)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.brown.withOpacity(0.2)),
          const SizedBox(height: 10),
          const Text("Eşleşen hasta bulunamadı.", style: TextStyle(color: Colors.brown)),
        ],
      ),
    );
  }
}