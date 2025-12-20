import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/clinic_service.dart';
import 'clinic_detail_page.dart';

class OwnerClinicSearchPage extends StatefulWidget {
  final int ownerId;
  const OwnerClinicSearchPage({required this.ownerId, Key? key}) : super(key: key);

  @override
  State<OwnerClinicSearchPage> createState() => _OwnerSearchPageState();
}

class _OwnerSearchPageState extends State<OwnerClinicSearchPage> {
  int? selectedCityId;
  int? selectedDistrictId;
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> foundClinics = [];
  bool isSearching = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    cities = await LocationService.getCities();
    setState(() {});
  }

  Future<void> _loadDistricts(int cityId) async {
    var d = await LocationService.getDistricts(cityId);
    setState(() {
      districts = d;
      selectedDistrictId = null;
    });
  }

  // --- Yeni Modern Dropdown Tasarımı ---
  Widget _buildCleanDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9), // Daha soft bir krem
      appBar: AppBar(
        title: const Text("Klinik Keşfet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor:const Color(0xFF22577A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Filtreleme Alanı (Daha Hafif) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildCleanDropdown<int>(
                  value: selectedCityId,
                  hint: "Şehir Seçin",
                  items: cities.map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['name']))).toList(),
                  onChanged: (val) {
                    setState(() => selectedCityId = val);
                    if (val != null) _loadDistricts(val);
                  },
                ),
                const SizedBox(height: 12),
                _buildCleanDropdown<int>(
                  value: selectedDistrictId,
                  hint: "İlçe Seçin (Opsiyonel)",
                  items: districts.map((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['name']))).toList(),
                  onChanged: (val) => setState(() => selectedDistrictId = val),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: isSearching ? null : () async {
                    if (selectedCityId == null) return;
                    setState(() { isSearching = true; hasSearched = true; });
                    foundClinics = await ClinicService.searchClinics(cityId: selectedCityId, districtId: selectedDistrictId);
                    setState(() { isSearching = false; });
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22577A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isSearching
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Klinikleri Listele", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Sonuçlar ---
          Expanded(
            child: foundClinics.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: foundClinics.length,
              itemBuilder: (context, index) => _buildModernClinicCard(foundClinics[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 80, color: Color(0xFF22577A)),
            const SizedBox(height: 10),
            Text(hasSearched ? "Sonuç bulunamadı" : "Hadi, yakındaki kliniklere bakalım!", style: const TextStyle(color: Colors.brown)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernClinicCard(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClinicDetailPage(clinic: c, ownerId: widget.ownerId))),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: const Color(0xFF22577A).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF22577A)),
        ),
        title: Text(c['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF22577A))),
        subtitle: Text("${c['city_name']} / ${c['district_name']}", style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}