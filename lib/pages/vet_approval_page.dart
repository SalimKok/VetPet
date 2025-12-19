import 'package:flutter/material.dart';
import 'package:petvet/services/admin_service.dart';

class VetApprovalPage extends StatefulWidget {
  const VetApprovalPage({Key? key}) : super(key: key);

  @override
  State<VetApprovalPage> createState() => _VetApprovalPageState();
}

class _VetApprovalPageState extends State<VetApprovalPage> {
  final AdminService _adminService = AdminService();
  List<dynamic> pendingVets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingVets();
  }

  Future<void> _loadPendingVets() async {
    try {
      final vets = await _adminService.fetchPendingVets();
      setState(() {
        pendingVets = vets;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleApprove(int id, int index) async {
    final approvedVet = pendingVets[index];
    setState(() {
      pendingVets.removeAt(index);
    });

    try {
      await _adminService.approveVet(id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veteriner başarıyla onaylandı ve erişimi açıldı."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => pendingVets.insert(index, approvedVet));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Onaylama hatası: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8D9),
      appBar: AppBar(
        title: const Text("Veteriner Onayları"),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingVets.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: pendingVets.length,
        itemBuilder: (context, index) {
          final vet = pendingVets[index];
          return _buildVetCard(vet, index);
        },
      ),
    );
  }

  Widget _buildVetCard(dynamic vet, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: const Icon(Icons.medical_services, color: Colors.orange),
              ),
              title: Text(
                vet['name'] ?? 'İsimsiz',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(vet['email'] ?? ''),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                  },
                  child: const Text("Detaylar", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleApprove(vet['id'], index),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Onayla"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )
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
          Icon(Icons.verified_user_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Bekleyen Başvuru Yok",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 5),
          Text(
            "Tüm veterinerler onaylanmış durumda.",
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}