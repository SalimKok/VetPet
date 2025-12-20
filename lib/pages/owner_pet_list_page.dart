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
      finalUrl = rawUrl.startsWith('/') ? "${ApiService.baseUrl}$rawUrl" : "${ApiService.baseUrl}/$rawUrl";
    }
    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9), // Ana Tema Krem
      appBar: AppBar(
        title: const Text("Evcil Dostlarım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF22577A)))
            : pets.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 80),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            final imageUrl = _constructImageUrl(pet['photo_url']);

            return _buildPetCard(pet, imageUrl);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22577A),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PetFormPage(ownerId: widget.ownerId)),
          );
          if (added == true) _refresh();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni Dost Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- Modern Pet Kart Tasarımı ---
  Widget _buildPetCard(Map<String, dynamic> pet, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Daha yuvarlak hatlar
        // --- 1. UFAK ÇERÇEVE (BORDER) ---
        border: Border.all(
          color: const Color(0xFF22577A).withOpacity(0.4), // Çok hafif lacivert çerçeve
          width: 1.5,
        ),
        // --- 2. GÖLGE (SHADOW) ---
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Daha belirgin ama yumuşak gölge
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Pet Fotoğrafı (Yuvarlatılmış Kare Tasarımı)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22577A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, color: Color(0xFF22577A), size: 40),
                    )
                        : const Icon(Icons.pets, color: Color(0xFF22577A), size: 40),
                  ),
                ),
                const SizedBox(width: 16),
                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? 'İsimsiz',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22577A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category_outlined, size: 14, color: Colors.brown),
                          const SizedBox(width: 4),
                          Text("${pet['species']} • ${pet['breed']}", style: const TextStyle(color: Colors.brown, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.cake_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(pet['birth_date'] ?? 'Bilinmiyor', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Alt Butonlar Alanı
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF22577A).withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(23), bottomRight: Radius.circular(23)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCardButton(
                  icon: Icons.edit_note_rounded,
                  label: "Düzenle",
                  color: const Color(0xFF22577A),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PetFormPage(ownerId: widget.ownerId, pet: pet)),
                    );
                    if (updated == true) _refresh();
                  },
                ),
                Container(width: 1, height: 20, color: Colors.black12),
                _buildCardButton(
                  icon: Icons.history_edu_rounded,
                  label: "Geçmiş",
                  color: Colors.orange.shade800,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitHistoryPage(petId: pet['id'], petName: pet['name'] ?? 'Pet', isVet: false),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: Colors.brown.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("Henüz bir dostun eklenmemiş!", style: TextStyle(color: Colors.brown, fontSize: 16)),
        ],
      ),
    );
  }
}