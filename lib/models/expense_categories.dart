import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExpenseCategories {
  static List<String> getExpenseCategories(BuildContext context) {
    return [
      'Bills',
      'Shopping',
      'Entertainment',
      'Health',
      'Transportation',
      'Food',
      'Education',
      'Other',
    ];
  }

  static List<String> getIncomeCategories(BuildContext context) {
    return [
      'Card',
      'Cash',
    ];
  }

  static String getLocalizedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case 'Bills':
        return l10n.bills;
      case 'Shopping':
        return l10n.shopping;
      case 'Entertainment':
        return l10n.entertainment;
      case 'Health':
        return l10n.health;
      case 'Transportation':
        return l10n.transportation;
      case 'Food':
        return l10n.food;
      case 'Education':
        return l10n.education;
      case 'Other':
        return l10n.other;
      case 'Card':
        return l10n.card;
      case 'Cash':
        return l10n.cash;
      default:
        return category;
    }
  }
} 