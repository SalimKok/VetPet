import 'package:flutter/material.dart';
import '../services/clinic_service.dart';
import '../services/location_service.dart';

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

  // Klinikleri API'den çek
  void _loadClinics() async {
    setState(() => isLoading = true);
    clinics = await ClinicService.getVetClinics(widget.vetId);
    setState(() => isLoading = false);
  }

  // Ekleme/Düzenleme Dialog'unu aç
  Future<void> _showClinicDialog({Map<String, dynamic>? clinic}) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (context) => _ClinicFormDialog(
        vetId: widget.vetId,
        existingClinic: clinic,
        onSave: _loadClinics, // Başarılı olursa listeyi güncelle
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EE),
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

          // Adres gösterimi: İl / İlçe - Detay
          String fullDisplayAddress = "";
          if (c['city_name'] != null) fullDisplayAddress += "${c['city_name']} / ";
          if (c['district_name'] != null) fullDisplayAddress += "${c['district_name']}\n";
          // 'address_details' yeni yapı, 'address' eski yapı (yedek)
          fullDisplayAddress += c['address_details'] ?? c['address'] ?? '';

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                c['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "$fullDisplayAddress\n\n📞 ${c['phone'] ?? '-'}\n🕒 ${c['working_hours'] ?? '-'}",
                  style: const TextStyle(color: Colors.black87),
                ),
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

// --- FORM DIALOG (Ayrı Widget) ---
// Dropdown state yönetimini kolaylaştırmak için ayrı bir StatefulWidget yaptık.
class _ClinicFormDialog extends StatefulWidget {
  final int vetId;
  final Map<String, dynamic>? existingClinic;
  final VoidCallback onSave;

  const _ClinicFormDialog({
    required this.vetId,
    this.existingClinic,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  State<_ClinicFormDialog> createState() => _ClinicFormDialogState();
}

class _ClinicFormDialogState extends State<_ClinicFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController addressDetailsController;
  late TextEditingController phoneController;
  late TextEditingController hoursController;

  // Seçili ID'ler
  int? selectedCityId;
  int? selectedDistrictId;

  // Dropdown Listeleri
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> districts = [];

  bool isLoadingData = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingClinic;

    // Controller'ları doldur
    nameController = TextEditingController(text: c?['name'] ?? '');
    // Backend 'address_details' döner, yoksa eski 'address' verisini kullan
    addressDetailsController = TextEditingController(text: c?['address_details'] ?? c?['address'] ?? '');
    phoneController = TextEditingController(text: c?['phone'] ?? '');
    hoursController = TextEditingController(text: c?['working_hours'] ?? '');

    // Seçili ID'leri ata
    selectedCityId = c?['city_id'];
    selectedDistrictId = c?['district_id'];

    // Verileri yükle
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoadingData = true);

    // 1. GERÇEK VERİTABANINDAN ŞEHİRLERİ ÇEK
    cities = await LocationService.getCities();

    // 2. Eğer düzenleme modundaysak ve bir il seçiliyse, o ilin İLÇELERİNİ ÇEK
    if (selectedCityId != null) {
      await _loadDistricts(selectedCityId!);
    }

    setState(() => isLoadingData = false);
  }

  // Seçilen şehre göre ilçeleri getir
  Future<void> _loadDistricts(int cityId) async {
    // GERÇEK VERİTABANINDAN İLÇELERİ ÇEK
    // Yükleniyor durumunu göstermek isterseniz burada ufak bir setState yapabilirsiniz
    // ama dropdown akıcı olsun diye genelde gerek duyulmaz.

    var fetchedDistricts = await LocationService.getDistricts(cityId);

    setState(() {
      districts = fetchedDistricts;

      // Eğer il değiştiyse ve eski seçili ilçe yeni listede yoksa seçimi kaldır
      // (Bu hata almamak için önemlidir)
      if (selectedDistrictId != null) {
        bool exists = districts.any((d) => d['id'] == selectedDistrictId);
        if (!exists) selectedDistrictId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingClinic == null ? "Yeni Klinik Ekle" : "Kliniği Düzenle"),
      content: isLoadingData
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- KLİNİK ADI ---
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Klinik Adı",
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 15),

              // --- İL SEÇİMİ (DROPDOWN) ---
              DropdownButtonFormField<int>(
                value: selectedCityId,
                decoration: const InputDecoration(
                  labelText: "İl Seçiniz",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
                items: cities.map((city) {
                  return DropdownMenuItem<int>(
                    value: city['id'],
                    child: Text(city['name']),
                  );
                }).toList(),
                onChanged: (val) async {
                  setState(() {
                    selectedCityId = val;
                    selectedDistrictId = null; // İl değişti, ilçeyi sıfırla
                    districts = []; // İlçe listesini temizle
                  });
                  if (val != null) {
                    await _loadDistricts(val); // Yeni ilçeleri çek
                  }
                },
                validator: (value) => value == null ? "Lütfen il seçiniz" : null,
              ),
              const SizedBox(height: 15),

              // --- İLÇE SEÇİMİ (DROPDOWN) ---
              DropdownButtonFormField<int>(
                value: selectedDistrictId,
                decoration: const InputDecoration(
                  labelText: "İlçe Seçiniz",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: districts.map((dist) {
                  return DropdownMenuItem<int>(
                    value: dist['id'],
                    child: Text(dist['name']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDistrictId = val;
                  });
                },
                validator: (value) => value == null ? "Lütfen ilçe seçiniz" : null,
              ),
              const SizedBox(height: 15),

              // --- ADRES DETAYI ---
              TextField(
                controller: addressDetailsController,
                decoration: const InputDecoration(
                  labelText: "Adres Detayı (Mahalle, Sokak, No)",
                  hintText: "Örn: Lale Sokak, No:5 Daire:2",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),

              // --- TELEFON ---
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Telefon",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // --- ÇALIŞMA SAATLERİ ---
              TextField(
                controller: hoursController,
                decoration: const InputDecoration(
                  labelText: "Çalışma Saatleri",
                  hintText: "Örn: 09:00 - 18:00",
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // SİL BUTONU (Sadece düzenleme modundaysa)
        if (widget.existingClinic != null)
          TextButton(
            onPressed: () async {
              // Onay Dialogu
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Emin misiniz?"),
                  content: const Text("Bu kliniği silmek istediğinize emin misiniz?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hayır")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Evet", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await ClinicService.deleteClinic(widget.existingClinic!['id']);
                if (success) {
                  widget.onSave(); // Ana listeyi yenile
                  Navigator.pop(context); // Dialogu kapat
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Klinik başarıyla silindi.")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silme işlemi başarısız!")));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),

        // İPTAL BUTONU
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("İptal"),
        ),

        // KAYDET/GÜNCELLE BUTONU
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty || selectedCityId == null || selectedDistrictId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen zorunlu alanları doldurun (Ad, İl, İlçe)")));
              return;
            }

            bool success;
            if (widget.existingClinic == null) {
              // --- YENİ KAYIT ---
              success = await ClinicService.createClinic(
                vetId: widget.vetId,
                name: nameController.text,
                cityId: selectedCityId,
                districtId: selectedDistrictId,
                addressDetails: addressDetailsController.text,
                phone: phoneController.text,
                workingHours: hoursController.text,
              );
            } else {
              // --- GÜNCELLEME ---
              success = await ClinicService.updateClinic(
                clinicId: widget.existingClinic!['id'],
                name: nameController.text,
                cityId: selectedCityId,
                districtId: selectedDistrictId,
                addressDetails: addressDetailsController.text,
                phone: phoneController.text,
                workingHours: hoursController.text,
              );
            }

            if (success) {
              widget.onSave(); // Ana listeyi yenile
              Navigator.pop(context); // Dialogu kapat
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.existingClinic == null ? "Klinik başarıyla eklendi!" : "Klinik güncellendi!")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İşlem başarısız oldu!")));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.existingClinic == null ? "Kaydet" : "Güncelle"),
        ),
      ],
    );
  }
}