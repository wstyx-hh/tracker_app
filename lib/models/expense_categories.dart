import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExpenseCategories {
  static List<String> getExpenseCategories(BuildContext context) {
    return [
      'Bills',
      'Shopping',
      'Entertainment',
      // Add other categories as needed
    ];
  }

  static List<String> getIncomeCategories(BuildContext context) {
    return [
      'Income',
      // Add other income categories as needed
    ];
  }

  static String getLocalizedCategory(BuildContext context, String category) {
    return category;
  }
} 