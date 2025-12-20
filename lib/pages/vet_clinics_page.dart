import 'package:flutter/material.dart';
import '../../services/clinic_service.dart';
import '../../services/location_service.dart';

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

  Widget _buildCompactBadge(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text(
          "Kliniklerim",
          style: TextStyle(color: const Color(0xFFFFFFFF)),
        ),
        backgroundColor: const Color(0xFF22577A),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22577A),
        onPressed: () => _showClinicDialog(),
        child: const Icon(Icons.add, color: const Color(0xFFFFFFFF)),
      ),
      body: clinics.isEmpty
          ? const Center(child: Text("Henüz klinik eklenmedi!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final c = clinics[index];

                String cityDistrict =
                    "${c['city_name'] ?? ''} / ${c['district_name'] ?? ''}";
                String details = c['address_details'] ?? c['address'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF22577A).withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 16),
                              // Orta: İsim ve Adres
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['name'],
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF22577A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cityDistrict,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      details,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Sağ Üst: Düzenle Butonu
                              GestureDetector(
                                onTap: () => _showClinicDialog(clinic: c),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF22577A,
                                    ).withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: Color(0xFF22577A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Alt Kısım: İletişim Etiketleri
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22577A).withOpacity(0.03),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildCompactBadge(
                                Icons.phone,
                                c['phone'] ?? '-',
                                Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              _buildCompactBadge(
                                Icons.access_time_rounded,
                                c['working_hours'] ?? '-',
                                Colors.orange.shade800,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

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
    addressDetailsController = TextEditingController(
      text: c?['address_details'] ?? c?['address'] ?? '',
    );
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

  Widget _buildStyledField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF22577A)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFECE8D9),
      // Tema Kremi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.existingClinic == null ? "Yeni Klinik Ekle" : "Kliniği Düzenle",
        style: const TextStyle(
          color: Color(0xFF22577A),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: isLoadingData
          ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF22577A)),
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStyledField(
                      controller: nameController,
                      label: "Klinik Adı",
                      icon: Icons.local_hospital,
                    ),

                    // İl Seçimi
                    _buildStyledDropdown<int>(
                      value: selectedCityId,
                      label: "İl Seçiniz",
                      icon: Icons.map,
                      items: cities
                          .map(
                            (city) => DropdownMenuItem<int>(
                              value: city['id'],
                              child: Text(city['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (val) async {
                        setState(() {
                          selectedCityId = val;
                          selectedDistrictId = null;
                          districts = [];
                        });
                        if (val != null) await _loadDistricts(val);
                      },
                    ),

                    // İlçe Seçimi
                    _buildStyledDropdown<int>(
                      value: selectedDistrictId,
                      label: "İlçe Seçiniz",
                      icon: Icons.location_city,
                      items: districts
                          .map(
                            (dist) => DropdownMenuItem<int>(
                              value: dist['id'],
                              child: Text(dist['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedDistrictId = val),
                    ),

                    _buildStyledField(
                      controller: addressDetailsController,
                      label: "Adres Detayı",
                      icon: Icons.home,
                      maxLines: 2,
                    ),
                    _buildStyledField(
                      controller: phoneController,
                      label: "Telefon",
                      icon: Icons.phone,
                      type: TextInputType.phone,
                    ),
                    _buildStyledField(
                      controller: hoursController,
                      label: "Çalışma Saatleri",
                      icon: Icons.access_time,
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
                  content: const Text(
                    "Bu kliniği silmek istediğinize emin misiniz?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Hayır"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Evet",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final success = await ClinicService.deleteClinic(
                  widget.existingClinic!['id'],
                );
                if (success) {
                  widget.onSave(); // Ana listeyi yenile
                  Navigator.pop(context); // Dialogu kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Klinik başarıyla silindi.")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Silme işlemi başarısız!")),
                  );
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
            final String phone = phoneController.text.trim();

            if (nameController.text.isEmpty ||
                selectedCityId == null ||
                selectedDistrictId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Lütfen zorunlu alanları doldurun (Ad, İl, İlçe)",
                  ),
                ),
              );
              return;
            }

            if (phone.length < 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Telefon numarası en az 10 haneli olmalıdır!"),
                ),
              );
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
                SnackBar(
                  content: Text(
                    widget.existingClinic == null
                        ? "Klinik başarıyla eklendi!"
                        : "Klinik güncellendi!",
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("İşlem başarısız oldu!")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22577A),
            foregroundColor: const Color(0xFFFFFFFF),
          ),
          child: Text(widget.existingClinic == null ? "Kaydet" : "Güncelle"),
        ),
      ],
    );
  }
}

Widget _buildStyledDropdown<T>({
  required T? value,
  required String label,
  required IconData icon,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF22577A)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
    ),
  );
}
