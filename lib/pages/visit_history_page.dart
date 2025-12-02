import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_visit.dart';
import '../services/visits_service.dart';
import 'add_visit_page.dart';

class VisitHistoryPage extends StatefulWidget {
  final int petId;
  final int? vetId;
  final String petName;
  final bool isVet;

  const VisitHistoryPage({
    Key? key,
    required this.petId,
    this.vetId,
    this.isVet = false,
    required this.petName,
  }) : super(key: key);

  @override
  State<VisitHistoryPage> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryPage> {
  final VisitService _api = VisitService();
  late Future<List<MedicalVisit>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _historyFuture = _api.getPetHistory(widget.petId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.petName} - Muayene Geçmişi')),
      floatingActionButton: (widget.isVet && widget.vetId != null)
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                if (widget.vetId == null) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddVisitPage(petId: widget.petId, vetId: widget.vetId!),
                  ),
                );
                if (result == true) {
                  _refreshList();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Muayene başarıyla eklendi.")),
                  );
                }
              },
            )
          : null,
      body: FutureBuilder<List<MedicalVisit>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Henüz kayıt bulunmamaktadır."));
          }

          final visits = snapshot.data!;

          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final dateStr = visit.date != null
                  ? DateFormat('dd MMM yyyy HH:mm').format(visit.date!)
                  : '-';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                  ),
                  title: Text(
                    visit.diagnosis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tarih: $dateStr"),
                      // Veteriner ismini yazdırıyoruz
                      Text(
                        "Vet: ${visit.vetName ?? 'Bilinmiyor'}",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (visit.notes != null && visit.notes!.isNotEmpty)
                            Text(
                              "Notlar: ${visit.notes}",
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const Divider(),
                          const Text(
                            "Yapılan İşlemler:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...visit.procedures.map(
                            (proc) => ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.check_circle_outline,
                                size: 20,
                              ),
                              title: Text(proc.title),
                              subtitle: Text(
                                "${proc.category} - ${proc.details.toString()}",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
