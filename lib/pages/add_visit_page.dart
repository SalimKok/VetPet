import 'package:flutter/material.dart';
import '../models/medical_procedure.dart';
import '../models/medical_visit.dart';
import '../services/visits_service.dart';


class AddVisitPage extends StatefulWidget {
  final int petId;
  final int vetId;
  const AddVisitPage({Key? key, required this.petId,required this.vetId}) : super(key: key);

  @override
  State<AddVisitPage> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  final VisitService _api = VisitService();

  // Ana form kontrolleri
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dinamik olarak eklenecek işlemler listesi
  List<MedicalProcedure> _tempProcedures = [];

  // İşlem ekleme formu için geçici kontrolcüler
  final TextEditingController _procTitleController = TextEditingController();
  final TextEditingController _procCategoryController = TextEditingController();
  final TextEditingController _procDetailsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Backend'e gidecek nesneyi oluştur
    MedicalVisit newVisit = MedicalVisit(
      petId: widget.petId,
      vetId: widget.vetId,
      diagnosis: _diagnosisController.text,
      notes: _notesController.text,
      procedures: _tempProcedures,
    );

    bool success = await _api.createVisit(newVisit);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true); // Başarılı ise önceki sayfaya 'true' dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kaydetme sırasında bir hata oluştu.")),
      );
    }
  }

  // Listeye geçici işlem ekleyen küçük pencere
  void _showAddProcedureDialog() {
    _procTitleController.clear();
    _procCategoryController.clear();
    _procDetailsController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("İşlem / Aşı Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _procCategoryController, decoration: const InputDecoration(labelText: "Kategori (Örn: Aşı, Cerrahi)")),
            TextField(controller: _procTitleController, decoration: const InputDecoration(labelText: "Başlık (Örn: Kuduz Aşısı)")),
            TextField(controller: _procDetailsController, decoration: const InputDecoration(labelText: "Detay (Not)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (_procTitleController.text.isNotEmpty) {
                setState(() {
                  _tempProcedures.add(MedicalProcedure(
                    category: _procCategoryController.text,
                    title: _procTitleController.text,
                    // Detayları basit bir map olarak atıyoruz
                    details: {'info': _procDetailsController.text},
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Listeye Ekle"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Muayene Kaydı")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Ana Muayene Bilgileri ---
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: "Teşhis / Başlık",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (val) => val!.isEmpty ? "Lütfen bir teşhis girin" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Muayene Notları",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 2),

              // --- 2. Yapılan İşlemler (Dinamik Liste) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Yapılan İşlemler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                    onPressed: _showAddProcedureDialog,
                    tooltip: "İşlem Ekle",
                  )
                ],
              ),

              if (_tempProcedures.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Henüz işlem eklenmedi.", style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true, // ScrollView içinde ListView kullanımı için şart
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tempProcedures.length,
                  itemBuilder: (ctx, index) {
                    final proc = _tempProcedures[index];
                    return Card(
                      color: Colors.blue.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(proc.title),
                        subtitle: Text(proc.category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _tempProcedures.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: _isLoading ? null : _submitVisit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("KAYDET", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}