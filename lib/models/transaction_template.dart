/// Transaction template model for quick add functionality
class TransactionTemplateModel {
  String? id; // UUID for web support
  String name;
  double amount;
  String category;
  String type; // 'income' or 'expense'
  String? note;
  DateTime createdAt;
  int usageCount;

  TransactionTemplateModel({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.type = 'expense',
    this.note,
    DateTime? createdAt,
    this.usageCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'type': type,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'usage_count': usageCount,
    };
  }

  factory TransactionTemplateModel.fromMap(Map<String, dynamic> map) {
    return TransactionTemplateModel(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      type: map['type'] ?? 'expense',
      note: map['note'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      usageCount: map['usage_count'] ?? 0,
    );
  }

  void incrementUsage() {
    usageCount++;
  }

  TransactionTemplateModel copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? type,
    String? note,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return TransactionTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
