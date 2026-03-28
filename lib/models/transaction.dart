class TransactionModel {
  int? id;
  String title;
  double amount;
  DateTime date;
  String category;
  String type; // 'income' or 'expense'
  int? walletId;
  String? note;
  String? tags; // Comma-separated tags
  String? templateId;
  String? receiptPath; // Path to receipt/payment image
  String? locationName; // Location name
  String? locationAddress; // Full address
  double? latitude; // GPS latitude
  double? longitude; // GPS longitude

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.type = 'expense',
    this.walletId,
    this.note,
    this.tags,
    this.templateId,
    this.receiptPath,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'wallet_id': walletId,
      'note': note,
      'tags': tags,
      'template_id': templateId,
      'receipt_path': receiptPath,
      'location_name': locationName,
      'location_address': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'] ?? 'expense',
      walletId: map['wallet_id'],
      note: map['note'],
      tags: map['tags'],
      templateId: map['template_id'],
      receiptPath: map['receipt_path'],
      locationName: map['location_name'],
      locationAddress: map['location_address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    int? walletId,
    String? note,
    String? tags,
    String? templateId,
    String? receiptPath,
    String? locationName,
    String? locationAddress,
    double? latitude,
    double? longitude,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      templateId: templateId ?? this.templateId,
      receiptPath: receiptPath ?? this.receiptPath,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
