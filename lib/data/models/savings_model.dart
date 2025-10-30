class SavingsModel {
  final int? id;
  final int userId;
  final double amount;
  final String note;
  final DateTime createdAt;

  SavingsModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsModel.fromJson(Map<String, dynamic> json) {
    return SavingsModel(
      id: json['id'],
      userId: json['user_id'],
      amount: double.parse(json['amount'].toString()),
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, String> toJsonRequest() {
    return {
      if (id != null) 'id': id.toString(),
      'user_id': userId.toString(),
      'amount': amount.toString(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}