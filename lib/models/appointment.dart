class Appointment {
  final int id;
  final int petId;
  final int ownerId;
  final int vetId;
  final DateTime date;
  final String reason;
  final String status;

  Appointment({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.vetId,
    required this.date,
    required this.reason,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      petId: json['pet_id'],
      ownerId: json['owner_id'],
      vetId: json['vet_id'],
      date: DateTime.parse(json['date']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
