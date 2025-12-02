// owner_pet_list_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pet_service.dart';
import 'visit_history_page.dart';
import 'owner_pet_form_page.dart';

class PetListPage extends StatefulWidget {
  final int ownerId;
  const PetListPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  List<Map<String, dynamic>> pets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() async {
    setState(() => isLoading = true);
    pets = await PetService.getPets(widget.ownerId);
    setState(() => isLoading = false);
  }

  void _refresh() => _loadPets();

  ImageProvider? _getPetImage(Map<String, dynamic> pet, File? photoFile) {
    if (photoFile != null) return FileImage(photoFile);
    if (pet['photo_url'] != null && pet['photo_url'].toString().isNotEmpty) {
      final url = pet['photo_url'].toString().startsWith('http')
          ? pet['photo_url']
          : "${ApiService.baseUrl}${pet['photo_url']}";
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pets.isEmpty
            ? const Center(child: Text("Henüz bir pet eklenmemiş!"))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                  const Color(0xFF81C784).withOpacity(0.3),
                  backgroundImage: _getPetImage(pet, null),
                  child: _getPetImage(pet, null) == null
                      ? const Icon(Icons.pets,
                      color: Colors.brown, size: 30)
                      : null,
                ),
                title: Text(
                  "${pet['name'] ?? ''} (${pet['id'] ?? ''})",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${pet['species'] ?? ''} - ${pet['breed'] ?? ''}",
                        style: const TextStyle(color: Colors.black54)),
                    Text("${pet['birth_date'] ?? ''}",
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.brown),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetFormPage(
                                ownerId: widget.ownerId, pet: pet),
                          ),
                        );
                        if (updated == true) _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.healing, color: Colors.brown),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitHistoryPage(
                              petId: pet['id'],
                              petName: pet['name'] ?? 'Pet',
                              isVet: false,
                          ),
                          ),
                        );
                        if (updated == true) _refresh();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF81C784),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetFormPage(ownerId: widget.ownerId),
            ),
          );
          if (added == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
