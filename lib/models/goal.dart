import 'package:flutter/material.dart';

/// Savings goal model for tracking financial targets
class GoalModel {
  int? id;
  String name;
  double targetAmount;
  double currentAmount;
  DateTime deadline;
  String? icon;
  Color? color;

  GoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'icon': icon,
      'color': color?.toARGB32(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      currentAmount: map['current_amount'] ?? 0.0,
      deadline: DateTime.parse(map['deadline']),
      icon: map['icon'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }

  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining {
    final now = DateTime.now();
    return deadline.difference(now).inDays + 1;
  }

  GoalModel copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? icon,
    Color? color,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
