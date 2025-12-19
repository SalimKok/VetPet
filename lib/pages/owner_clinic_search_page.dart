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

  bool isLoadingLocations = false;
  bool isSearching = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => isLoadingLocations = true);
    cities = await LocationService.getCities();
    setState(() => isLoadingLocations = false);
  }

  Future<void> _loadDistricts(int cityId) async {
    var d = await LocationService.getDistricts(cityId);
    setState(() {
      districts = d;
      selectedDistrictId = null;
    });
  }

  Future<void> _search() async {
    if (selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen en azından bir İl seçiniz.")),
      );
      return;
    }

    setState(() {
      isSearching = true;
      hasSearched = true;
      foundClinics = [];
    });

    // Servise istek at
    final results = await ClinicService.searchClinics(
      cityId: selectedCityId,
      districtId: selectedDistrictId,
    );

    setState(() {
      foundClinics = results;
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Klinik Bul",style: TextStyle(color:  const Color(0xFFFFFFFF))),
        backgroundColor: const Color(0xFF22577A),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // --- FİLTRELEME ALANI ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: selectedCityId,
                  decoration: const InputDecoration(
                    labelText: "İl Seçiniz",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      districts = [];
                      selectedDistrictId = null;
                    });
                    if (val != null) await _loadDistricts(val);
                  },
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  value: selectedDistrictId,
                  decoration: const InputDecoration(
                    labelText: "İlçe Seçiniz (İsteğe Bağlı)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  items: districts.map((dist) {
                    return DropdownMenuItem<int>(
                      value: dist['id'],
                      child: Text(dist['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedDistrictId = val);
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSearching ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22577A),
                      foregroundColor: Colors.white,
                    ),
                    child: isSearching
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("KLİNİK ARA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isSearching
                ? const Center(child: Text("Aranıyor..."))
                : foundClinics.isEmpty
                ? Center(
              child: Text(
                hasSearched
                    ? "Aradığınız kriterlere uygun veteriner bulunamadı."
                    : "Arama yapmak için yukarıdan seçim yapınız.",
                style: const TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foundClinics.length,
              itemBuilder: (context, index) {
                final c = foundClinics[index];

                String locationStr = "${c['city_name']} / ${c['district_name']}";

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.pets, color: Colors.orange),
                    ),
                    title: Text(
                      c['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("📍 $locationStr"),
                        Text("🏠 ${c['address_details'] ?? ''}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text("📞 ${c['phone'] ?? 'Tel Yok'}"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClinicDetailPage(
                            clinic: c,
                            ownerId: widget.ownerId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}