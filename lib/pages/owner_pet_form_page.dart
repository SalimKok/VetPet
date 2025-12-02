import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/pet_service.dart';

class PetFormPage extends StatefulWidget {
  final int ownerId;
  final Map<String, dynamic>? pet; // null ise yeni ekleme

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
    final petData = {
      "owner_id": widget.ownerId,
      "name": nameController.text.trim(),
      "species": speciesController.text.trim(),
      "breed": breedController.text.trim(),
      "notes": notesController.text.trim(),
      "birth_date": birthday?.toIso8601String(),
      "photo_file": photoFile, // Multipart gönderilecek
    };

    bool success;
    if (widget.pet != null) {
      success = await PetService.updatePet(widget.pet!['id'], petData);
    } else {
      success = await PetService.addPet(petData);
    }

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İşlem başarısız!")),
      );
    }
  }

  ImageProvider? _getPetImage() {
    if (photoFile != null) {
      return FileImage(photoFile!);
    } else if (widget.pet != null && widget.pet!['photo_url'] != null) {
      String url = widget.pet!['photo_url'];
      if (!url.startsWith("http")) {
        url = "${ApiService.baseUrl}$url"; // relative path’i mutlak yap
      }
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet != null ? "Pet Düzenle" : "Yeni Pet Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _getPetImage(),
                child: _getPetImage() == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "İsim")),
            TextField(controller: speciesController, decoration: const InputDecoration(labelText: "Tür")),
            TextField(controller: breedController, decoration: const InputDecoration(labelText: "Cins")),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Doğum Tarihi: "),
                Text(
                  birthday != null
                      ? "${birthday!.day}/${birthday!.month}/${birthday!.year}"
                      : "Seçilmedi",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _pickBirthday, child: const Text("Seç")),
              ],
            ),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: "Notlar")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Kaydet")),
            if (widget.pet != null)
              TextButton(
                onPressed: () async {
                  final deleted = await PetService.deletePet(widget.pet!['id']);
                  if (deleted) Navigator.pop(context, true);
                },
                child: const Text("Sil", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
