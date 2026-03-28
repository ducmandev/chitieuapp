/// Recurring transaction model for automated periodic transactions
class RecurringTransactionModel {
  int? id;
  String title;
  double amount;
  String category;
  String type; // 'income' or 'expense'
  String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  DateTime nextDueDate;
  DateTime? endDate;
  bool isActive;
  String? note;
  int? dayOfMonth; // For monthly payments (1-31)
  int? dayOfWeek; // For weekly payments (0-6, 0=Monday)

  RecurringTransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.type = 'expense',
    this.frequency = 'monthly',
    required this.nextDueDate,
    this.endDate,
    this.isActive = true,
    this.note,
    this.dayOfMonth,
    this.dayOfWeek,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'frequency': frequency,
      'next_due_date': nextDueDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'note': note,
      'day_of_month': dayOfMonth,
      'day_of_week': dayOfWeek,
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      type: map['type'] ?? 'expense',
      frequency: map['frequency'] ?? 'monthly',
      nextDueDate: DateTime.parse(map['next_due_date']),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : null,
      isActive: map['is_active'] == 1,
      note: map['note'],
      dayOfMonth: map['day_of_month'],
      dayOfWeek: map['day_of_week'],
    );
  }

  /// Calculate the next due date based on frequency
  DateTime calculateNextDueDate() {
    DateTime base = nextDueDate;

    switch (frequency) {
      case 'daily':
        return base.add(const Duration(days: 1));
      case 'weekly':
        return base.add(const Duration(days: 7));
      case 'monthly':
        // Try to keep the same day of month
        final nextMonth = DateTime(base.year, base.month + 1, base.day);
        // If the day doesn't exist (e.g., Feb 31), use last day of month
        if (nextMonth.day != base.day) {
          return DateTime(base.year, base.month + 2, 0);
        }
        return nextMonth;
      case 'yearly':
        return DateTime(base.year + 1, base.month, base.day);
      default:
        return base;
    }
  }

  /// Check if this recurring transaction should end
  bool shouldEnd() {
    if (endDate == null) return false;
    return nextDueDate.isAfter(endDate!);
  }

  RecurringTransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    String? frequency,
    DateTime? nextDueDate,
    DateTime? endDate,
    bool? isActive,
    String? note,
    int? dayOfMonth,
    int? dayOfWeek,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }
}
