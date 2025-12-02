import 'medical_procedure.dart';

class MedicalVisit {
  int? id;
  int petId;
  int vetId;
  String? vetName;
  String diagnosis;
  String? notes;
  DateTime? date;
  List<MedicalProcedure> procedures;

  MedicalVisit({
    this.id,
    required this.petId,
    required this.vetId,
    this.vetName,
    required this.diagnosis,
    this.notes,
    this.date,
    this.procedures = const [],
  });

  factory MedicalVisit.fromJson(Map<String, dynamic> json) {
    var list = json['procedures'] as List? ?? [];
    List<MedicalProcedure> proceduresList =
    list.map((i) => MedicalProcedure.fromJson(i)).toList();

    return MedicalVisit(
      id: json['id'],
      petId: json['pet_id'] ?? 0,
      // Listelemede bazen gelmeyebilir, dikkat
      vetId: json['vet_id'],
      vetName: json['vet_name'],
      diagnosis: json['diagnosis'],
      notes: json['notes'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      procedures: proceduresList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'vet_id': vetId,
      'diagnosis': diagnosis,
      'notes': notes,
      // Procedures listesini mapleyerek gönderiyoruz
      'procedures': procedures.map((p) => p.toJson()).toList(),
    };
  }
}