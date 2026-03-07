import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CategoryUtils {
  static IconData getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
      case 'ĂN UỐNG':
        return Icons.fastfood;
      case 'GAMES':
      case 'GAME':
        return Icons.sports_esports;
      case 'RIDES':
      case 'ĐI LẠI':
        return Icons.directions_car;
      case 'COFFEE':
      case 'CÀ PHÊ':
        return Icons.local_cafe;
      case 'INCOME':
      case 'THU NHẬP':
        return Icons.account_balance_wallet;
      case 'TRAVEL':
      case 'DU LỊCH':
        return Icons.train;
      default:
        return Icons.payments;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
      case 'ĂN UỐNG':
        return NeoColors.tertiary;
      case 'GAMES':
      case 'GAME':
        return NeoColors.primary;
      case 'RIDES':
      case 'ĐI LẠI':
        return NeoColors.secondary;
      case 'COFFEE':
      case 'CÀ PHÊ':
        return NeoColors.tertiary;
      case 'INCOME':
      case 'THU NHẬP':
        return NeoColors.success;
      case 'TRAVEL':
      case 'DU LỊCH':
        return NeoColors.primary;
      default:
        return Colors.white;
    }
  }
}
