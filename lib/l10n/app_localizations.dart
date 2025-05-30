import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'translations/en.dart';
import 'translations/ru.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'ru': ru,
  };

  String get language {
    return _localizedValues[locale.languageCode]?['language'] ?? 'English';
  }

  String get settings {
    return _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  }

  String get expenses {
    return _localizedValues[locale.languageCode]?['expenses'] ?? 'Expenses';
  }

  String get income {
    return _localizedValues[locale.languageCode]?['income'] ?? 'Income';
  }

  String get statistics {
    return _localizedValues[locale.languageCode]?['statistics'] ?? 'Statistics';
  }

  String get categories {
    return _localizedValues[locale.languageCode]?['categories'] ?? 'Categories';
  }

  String get amount {
    return _localizedValues[locale.languageCode]?['amount'] ?? 'Amount';
  }

  String get date {
    return _localizedValues[locale.languageCode]?['date'] ?? 'Date';
  }

  String get category {
    return _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  }

  String get description {
    return _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  }

  String get save {
    return _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  }

  String get cancel {
    return _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  }

  String get delete {
    return _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  }

  String get edit {
    return _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  }

  String get addExpense {
    return _localizedValues[locale.languageCode]?['addExpense'] ?? 'Add Expense';
  }

  String get addIncome {
    return _localizedValues[locale.languageCode]?['addIncome'] ?? 'Add Income';
  }

  String get total {
    return _localizedValues[locale.languageCode]?['total'] ?? 'Total';
  }

  String get balance {
    return _localizedValues[locale.languageCode]?['balance'] ?? 'Balance';
  }

  String get darkMode {
    return _localizedValues[locale.languageCode]?['darkMode'] ?? 'Dark Mode';
  }

  String get currency {
    return _localizedValues[locale.languageCode]?['currency'] ?? 'Currency';
  }

  String get appTheme {
    return _localizedValues[locale.languageCode]?['appTheme'] ?? 'App Theme';
  }

  String get preferences {
    return _localizedValues[locale.languageCode]?['preferences'] ?? 'Preferences';
  }

  String get notifications {
    return _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  }

  String get enableExpenseReminders {
    return _localizedValues[locale.languageCode]?['enableExpenseReminders'] ?? 'Enable expense reminders';
  }

  String get transactions {
    return _localizedValues[locale.languageCode]?['transactions'] ?? 'Transactions';
  }

  String get budget {
    return _localizedValues[locale.languageCode]?['budget'] ?? 'Budget';
  }

  String get blue {
    return _localizedValues[locale.languageCode]?['blue'] ?? 'Blue';
  }

  String get purple {
    return _localizedValues[locale.languageCode]?['purple'] ?? 'Purple';
  }

  String get green {
    return _localizedValues[locale.languageCode]?['green'] ?? 'Green';
  }

  String get orange {
    return _localizedValues[locale.languageCode]?['orange'] ?? 'Orange';
  }

  String get teal {
    return _localizedValues[locale.languageCode]?['teal'] ?? 'Teal';
  }

  String get pink {
    return _localizedValues[locale.languageCode]?['pink'] ?? 'Pink';
  }

  String get deepPurple {
    return _localizedValues[locale.languageCode]?['deepPurple'] ?? 'Deep Purple';
  }

  String get lightMode {
    return _localizedValues[locale.languageCode]?['lightMode'] ?? 'Light Mode';
  }

  String get themeChanged {
    return _localizedValues[locale.languageCode]?['themeChanged'] ?? 'Theme changed';
  }

  String get data {
    return _localizedValues[locale.languageCode]?['data'] ?? 'Data';
  }

  String get exportData {
    return _localizedValues[locale.languageCode]?['exportData'] ?? 'Export Data';
  }

  String get importData {
    return _localizedValues[locale.languageCode]?['importData'] ?? 'Import Data';
  }

  String get accountName {
    return _localizedValues[locale.languageCode]?['accountName'] ?? 'Account Name';
  }

  String get version {
    return _localizedValues[locale.languageCode]?['version'] ?? 'Version';
  }

  String get privacyPolicy {
    return _localizedValues[locale.languageCode]?['privacyPolicy'] ?? 'Privacy Policy';
  }

  String get termsOfService {
    return _localizedValues[locale.languageCode]?['termsOfService'] ?? 'Terms of Service';
  }

  String get selectCurrency {
    return _localizedValues[locale.languageCode]?['selectCurrency'] ?? 'Select Currency';
  }

  String get analytics {
    return _localizedValues[locale.languageCode]?['analytics'] ?? 'Analytics';
  }

  String get budgetLimits {
    return _localizedValues[locale.languageCode]?['budgetLimits'] ?? 'Budget Limits';
  }

  String get addCategoryLimit {
    return _localizedValues[locale.languageCode]?['addCategoryLimit'] ?? 'Add Category Limit';
  }

  String get limit {
    return _localizedValues[locale.languageCode]?['limit'] ?? 'Limit';
  }

  String get spent {
    return _localizedValues[locale.languageCode]?['spent'] ?? 'Spent';
  }

  String get limitExceeded {
    return _localizedValues[locale.languageCode]?['limitExceeded'] ?? 'Limit exceeded by';
  }

  String get repeat {
    return _localizedValues[locale.languageCode]?['repeat'] ?? 'Repeat';
  }

  String get reminder {
    return _localizedValues[locale.languageCode]?['reminder'] ?? 'Reminder';
  }

  String get title {
    return _localizedValues[locale.languageCode]?['title'] ?? 'Title';
  }

  String get enterTitle {
    return _localizedValues[locale.languageCode]?['enterTitle'] ?? 'Enter title';
  }

  String get areYouSure {
    return _localizedValues[locale.languageCode]?['areYouSure'] ?? 'Are you sure?';
  }

  String get thisActionCannot {
    return _localizedValues[locale.languageCode]?['thisActionCannot'] ?? 'This action cannot be undone';
  }

  String get noData => _localizedValues[locale.languageCode]?['noData'] ?? 'No data available';

  String get selectDate => _localizedValues[locale.languageCode]?['selectDate'] ?? 'Select Date';

  String get selectCategory {
    return _localizedValues[locale.languageCode]?['selectCategory'] ?? 'Select Category';
  }

  String get enterAmount {
    return _localizedValues[locale.languageCode]?['enterAmount'] ?? 'Enter Amount';
  }

  String get enterDescription {
    return _localizedValues[locale.languageCode]?['enterDescription'] ?? 'Enter Description';
  }

  String get dailyExpenses {
    return _localizedValues[locale.languageCode]?['dailyExpenses'] ?? 'Daily Expenses';
  }

  String get monthlyExpenses {
    return _localizedValues[locale.languageCode]?['monthlyExpenses'] ?? 'Monthly Expenses';
  }

  String get yearlyExpenses {
    return _localizedValues[locale.languageCode]?['yearlyExpenses'] ?? 'Yearly Expenses';
  }

  String get expensesByCategory {
    return _localizedValues[locale.languageCode]?['expensesByCategory'] ?? 'Expenses by Category';
  }

  String get overview {
    return _localizedValues[locale.languageCode]?['overview'] ?? 'Overview';
  }

  String get all {
    return _localizedValues[locale.languageCode]?['all'] ?? 'All';
  }

  String get incomes {
    return _localizedValues[locale.languageCode]?['incomes'] ?? 'Incomes';
  }

  String get totalMonthlyLimit {
    return _localizedValues[locale.languageCode]?['totalMonthlyLimit'] ?? 'Total Monthly Limit';
  }

  String get enterLimit {
    return _localizedValues[locale.languageCode]?['enterLimit'] ?? 'Enter Limit';
  }

  String get categoryLimits {
    return _localizedValues[locale.languageCode]?['categoryLimits'] ?? 'Category Limits';
  }

  String get budgetFor {
    return _localizedValues[locale.languageCode]?['budgetFor'] ?? 'Budget for';
  }

  String get previousMonth {
    return _localizedValues[locale.languageCode]?['previousMonth'] ?? 'Previous Month';
  }

  String get nextMonth {
    return _localizedValues[locale.languageCode]?['nextMonth'] ?? 'Next Month';
  }

  String get changeDateRange {
    return _localizedValues[locale.languageCode]?['changeDateRange'] ?? 'Change Date Range';
  }

  String get clearData {
    return _localizedValues[locale.languageCode]?['clearData'] ?? 'Clear Data';
  }

  String get leftFromIncomes {
    return _localizedValues[locale.languageCode]?['leftFromIncomes'] ?? 'Left from incomes';
  }

  String get bills {
    return _localizedValues[locale.languageCode]?['bills'] ?? 'Bills';
  }

  String get shopping {
    return _localizedValues[locale.languageCode]?['shopping'] ?? 'Shopping';
  }

  String get entertainment {
    return _localizedValues[locale.languageCode]?['entertainment'] ?? 'Entertainment';
  }

  String get health {
    return _localizedValues[locale.languageCode]?['Health'] ?? 'Health';
  }

  String get transportation {
    return _localizedValues[locale.languageCode]?['Transportation'] ?? 'Transportation';
  }

  String get food {
    return _localizedValues[locale.languageCode]?['Food'] ?? 'Food';
  }

  String get education {
    return _localizedValues[locale.languageCode]?['Education'] ?? 'Education';
  }

  String get other {
    return _localizedValues[locale.languageCode]?['Other'] ?? 'Other';
  }

  String get card {
    return _localizedValues[locale.languageCode]?['Card'] ?? 'Card';
  }

  String get cash {
    return _localizedValues[locale.languageCode]?['Cash'] ?? 'Cash';
  }

  String get about {
    return _localizedValues[locale.languageCode]?['about'] ?? 'About';
  }

  String get profile {
    return _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  }

  String get addYourFirstTransaction {
    return _localizedValues[locale.languageCode]?['addYourFirstTransaction'] ?? 'Add your first transaction';
  }

  String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: locale.languageCode == 'ru' ? 'ru_RU' : 'en_US',
      symbol: _currency,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  String get _currency {
    switch (locale.languageCode) {
      case 'ru':
        return '₽';
      default:
        return '\$';
    }
  }
} 