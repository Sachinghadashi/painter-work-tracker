// lib/models/work_record.dart

class WorkRecord {
  final String id;        // MongoDB _id
  final DateTime date;
  final String place;
  final double amount;
  final String notes;

  WorkRecord({
    required this.id,
    required this.date,
    required this.place,
    required this.amount,
    required this.notes,
  });

  // For local use if needed
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'place': place,
      'amount': amount,
      'notes': notes,
    };
  }

  // Build from MongoDB JSON
  factory WorkRecord.fromJson(Map<String, dynamic> json) {
    return WorkRecord(
      id: json['_id'] as String,
      date: DateTime.parse(json['date'] as String),
      place: json['place'] as String,
      amount: (json['amount'] as num).toDouble(),
      notes: (json['notes'] ?? '') as String,
    );
  }
}
