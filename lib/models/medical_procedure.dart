class MedicalProcedure {
  int? id;
  String category;
  String title;
  Map<String, dynamic> details; // Python'daki JSONB/Dict karşılığı

  MedicalProcedure({
    this.id,
    required this.category,
    required this.title,
    required this.details,
  });

  // JSON'dan Dart objesine
  factory MedicalProcedure.fromJson(Map<String, dynamic> json) {
    return MedicalProcedure(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      details: json['details'] ?? {},
    );
  }

  // Dart objesinden JSON'a (Backend'e gönderirken)
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'details': details,
    };
  }
}