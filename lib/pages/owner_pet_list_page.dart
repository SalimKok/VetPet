
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/pet_service.dart';
import '../vet/visit_history_page.dart';
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

  String? _constructImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;

    String finalUrl = rawUrl;

    if (!rawUrl.startsWith('http')) {
      if (rawUrl.startsWith('/')) {
        finalUrl = "${ApiService.baseUrl}$rawUrl";
      } else {
        finalUrl = "${ApiService.baseUrl}/$rawUrl";
      }
    }

    print("Resim URL: $finalUrl");
    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Evcil Dostlarım",style: TextStyle(color: const Color(0xFFFFFFFF)),),
        backgroundColor: const Color(0xFF22577A),
        automaticallyImplyLeading: false,
      ),
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
            final imageUrl = _constructImageUrl(pet['photo_url']);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF22577A).withOpacity(0.3),
                  child: ClipOval(
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Resim Yükleme Hatası: $error");
                          return const Icon(Icons.pets, color: Colors.brown, size: 30);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                      )
                          : const Icon(Icons.pets, color: Colors.brown, size: 30),
                    ),
                  ),
                ),
                // -------------------------------------
                title: Text(
                  "${pet['name'] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${pet['species'] ?? ''} - ${pet['breed'] ?? ''}",
                        style: const TextStyle(color: Colors.black54)),
                    Text("${pet['birth_date'] ?? ''}",
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: const Color(0xFF22577A),),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetFormPage(ownerId: widget.ownerId, pet: pet),
                          ),
                        );
                        if (updated == true) _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.healing, color: const Color(0xFF22577A),),
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
        backgroundColor: const Color(0xFF22577A),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PetFormPage(ownerId: widget.ownerId),
            ),
          );
          if (added == true) _refresh();
        },
        child: const Icon(Icons.add,color: const Color(0xFFFFFFFF),),
      ),
    );
  }
}
