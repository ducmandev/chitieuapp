/// Budget model for per-category spending limits
class BudgetModel {
  int? id;
  String category;
  double limit;
  String period; // 'monthly' or 'weekly'
  DateTime? startDate;
  bool? isActive;

  BudgetModel({
    this.id,
    required this.category,
    required this.limit,
    this.period = 'monthly',
    this.startDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'budget_limit': limit,
      'period': period,
      'start_date': startDate?.toIso8601String(),
      'is_active': isActive == true ? 1 : 0,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limit: map['budget_limit'],
      period: map['period'] ?? 'monthly',
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  BudgetModel copyWith({
    int? id,
    String? category,
    double? limit,
    String? period,
    DateTime? startDate,
    bool? isActive,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
