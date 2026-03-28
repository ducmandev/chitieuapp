import 'package:flutter/material.dart';

/// Model for a spending/income category
class CategoryModel {
  int? id;
  String name;
  String nameVI; // Vietnamese translation
  IconData icon;
  Color color;
  String type; // 'income' or 'expense'
  bool isDefault; // Built-in categories cannot be deleted
  int sortOrder;

  CategoryModel({
    this.id,
    required this.name,
    required this.nameVI,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  /// Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameVI': nameVI,
      'iconCode': icon.codePoint,
      'colorValue': color.toARGB32(),
      'type': type,
      'isDefault': isDefault ? 1 : 0,
      'sortOrder': sortOrder,
    };
  }

  /// Create from database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      nameVI: map['nameVI'] ?? map['name'],
      icon: IconData(map['iconCode'] ?? 0xe3a4, fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue'] ?? 0xFFFFFFFF),
      type: map['type'] ?? 'expense',
      isDefault: map['isDefault'] == 1,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  /// Create a copy with modified fields
  CategoryModel copyWith({
    int? id,
    String? name,
    String? nameVI,
    IconData? icon,
    Color? color,
    String? type,
    bool? isDefault,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVI: nameVI ?? this.nameVI,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // Built-in default categories
  static List<CategoryModel> getDefaults() {
    return [
      // Expense categories
      CategoryModel(
        id: 1,
        name: 'FOOD',
        nameVI: 'ĂN UỐNG',
        icon: Icons.fastfood,
        color: const Color(0xFF00E5FF), // Cyan
        type: 'expense',
        isDefault: true,
        sortOrder: 1,
      ),
      CategoryModel(
        id: 2,
        name: 'GAMES',
        nameVI: 'GAME',
        icon: Icons.sports_esports,
        color: const Color(0xFFFFD600), // Yellow
        type: 'expense',
        isDefault: true,
        sortOrder: 2,
      ),
      CategoryModel(
        id: 3,
        name: 'RIDES',
        nameVI: 'ĐI LẠI',
        icon: Icons.directions_car,
        color: const Color(0xFFFF6B9D), // Pink
        type: 'expense',
        isDefault: true,
        sortOrder: 3,
      ),
      CategoryModel(
        id: 4,
        name: 'COFFEE',
        nameVI: 'CÀ PHÊ',
        icon: Icons.local_cafe,
        color: const Color(0xFF00E5FF), // Cyan
        type: 'expense',
        isDefault: true,
        sortOrder: 4,
      ),
      CategoryModel(
        id: 5,
        name: 'TRAVEL',
        nameVI: 'DU LỊCH',
        icon: Icons.train,
        color: const Color(0xFFFFD600), // Yellow
        type: 'expense',
        isDefault: true,
        sortOrder: 5,
      ),
      // Income category
      CategoryModel(
        id: 100,
        name: 'INCOME',
        nameVI: 'THU NHẬP',
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF00E676), // Green
        type: 'income',
        isDefault: true,
        sortOrder: 100,
      ),
    ];
  }

  // Available icons for custom categories
  static const availableIcons = [
    Icons.fastfood,
    Icons.sports_esports,
    Icons.directions_car,
    Icons.local_cafe,
    Icons.train,
    Icons.shopping_cart,
    Icons.movie,
    Icons.music_note,
    Icons.book,
    Icons.fitness_center,
    Icons.home,
    Icons.phone,
    Icons.medical_services,
    Icons.pets,
    Icons.school,
    Icons.work,
    Icons.card_giftcard,
    Icons.camera_alt,
    Icons.headphones,
    Icons.watch,
    Icons.favorite,
    Icons.child_care,
    Icons.plumbing,
    Icons.electrical_services,
    Icons.carpenter,
    Icons.cleaning_services,
    Icons.more_horiz,
  ];

  // Available colors for custom categories
  static const availableColors = [
    Color(0xFFFFD600), // Primary (Yellow)
    Color(0xFFFF6B9D), // Secondary (Pink)
    Color(0xFF00E5FF), // Tertiary (Cyan)
    Color(0xFF00E676), // Success (Green)
    Color(0xFFFF5252), // Error (Red)
    Color(0xFF7C4DFF), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFFE91E63), // Pink
  ];
}
