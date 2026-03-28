import 'package:flutter/material.dart';

/// Wallet model for managing multiple accounts/wallets
class WalletModel {
  int? id;
  String name;
  double balance;
  String type; // 'cash', 'bank', 'credit', 'savings'
  String? icon;
  Color? color;
  bool isDefault;

  WalletModel({
    this.id,
    required this.name,
    this.balance = 0.0,
    this.type = 'cash',
    this.icon,
    this.color,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
      'icon': icon,
      'color': color?.toARGB32(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      name: map['name'],
      balance: map['balance'] ?? 0.0,
      type: map['type'] ?? 'cash',
      icon: map['icon'],
      color: map['color'] != null ? Color(map['color']) : null,
      isDefault: map['is_default'] == 1,
    );
  }

  /// Get display type name
  String getDisplayName(String Function(String) localize) {
    switch (type) {
      case 'cash':
        return localize('cash');
      case 'bank':
        return localize('bank');
      case 'credit':
        return localize('credit');
      case 'savings':
        return localize('savings');
      default:
        return type;
    }
  }

  /// Get default icon for wallet type
  IconData get defaultIcon {
    switch (type) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.wallet;
    }
  }

  WalletModel copyWith({
    int? id,
    String? name,
    double? balance,
    String? type,
    String? icon,
    Color? color,
    bool? isDefault,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
