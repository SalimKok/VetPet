import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/pet_service.dart';

class PetFormPage extends StatefulWidget {
  final int ownerId;
  final Map<String, dynamic>? pet;

  const PetFormPage({required this.ownerId, this.pet, Key? key}) : super(key: key);

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? birthday;
  File? photoFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      nameController.text = widget.pet!['name'] ?? '';
      speciesController.text = widget.pet!['species'] ?? '';
      breedController.text = widget.pet!['breed'] ?? '';
      notesController.text = widget.pet!['notes'] ?? '';
      if (widget.pet!['birth_date'] != null) {
        birthday = DateTime.parse(widget.pet!['birth_date']);
      }
    }
  }

  // --- Yardımcı Widgetlar ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF22577A)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.brown),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // --- Fonksiyonlar ---

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => birthday = picked);
  }

  Future<void> _pickPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) setState(() => photoFile = File(pickedFile.path));
  }

  void _save() async {
    final String name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen pet ismini giriniz!")));
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İsim alanı sayı içeremez!")));
      return;
    }

    final petData = {
      "owner_id": widget.ownerId,
      "name": name,
      "species": speciesController.text.trim(),
      "breed": breedController.text.trim(),
      "notes": notesController.text.trim(),
      "birth_date": birthday?.toIso8601String(),
      "photo_file": photoFile,
    };

    bool success = widget.pet != null
        ? await PetService.updatePet(widget.pet!['id'], petData)
        : await PetService.addPet(petData);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İşlem başarısız!")));
    }
  }

  ImageProvider? _getPetImage() {
    if (photoFile != null) return FileImage(photoFile!);
    if (widget.pet != null && widget.pet!['photo_url'] != null) {
      String url = widget.pet!['photo_url'];
      if (!url.startsWith("http")) url = "${ApiService.baseUrl}$url";
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: Text(widget.pet != null ? "Pet Düzenle" : "Yeni Pet Ekle",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF22577A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Fotoğraf Bölümü
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: const Color(0xFF22577A).withOpacity(0.2),
                    backgroundImage: _getPetImage(),
                    child: _getPetImage() == null
                        ? const Icon(Icons.pets, size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF22577A),
                        child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Alanları
            _buildTextField(controller: nameController, label: "Pet İsmi", icon: Icons.badge),
            _buildTextField(controller: speciesController, label: "Tür (Kedi, Köpek vb.)", icon: Icons.category),
            _buildTextField(controller: breedController, label: "Cins", icon: Icons.pets),

            // Doğum Tarihi Seçici (Özel Tasarım)
            GestureDetector(
              onTap: _pickBirthday,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF22577A)),
                    const SizedBox(width: 12),
                    const Text("Doğum Tarihi:", style: TextStyle(color: Colors.brown, fontSize: 16)),
                    const Spacer(),
                    Text(
                      birthday != null ? "${birthday!.day}/${birthday!.month}/${birthday!.year}" : "Seçiniz",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22577A)),
                    ),
                  ],
                ),
              ),
            ),

            _buildTextField(controller: notesController, label: "Notlar", icon: Icons.notes, maxLines: 3),

            const SizedBox(height: 20),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Kaydet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22577A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),

            // Silme Butonu (Sadece düzenlemede)
            if (widget.pet != null)
              TextButton.icon(
                onPressed: () async {
                  final deleted = await PetService.deletePet(widget.pet!['id']);
                  if (deleted) Navigator.pop(context, true);
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Pet'i Sil", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}