import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/planned_payment.dart';
// import '../services/db_service.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<PlannedPayment> _plannedPayments = [];
  double _balance = 0.0;
  double _income = 0.0;
  double _expense = 0.0;

  List<Expense> get expenses => [..._expenses];
  List<PlannedPayment> get plannedPayments => [..._plannedPayments];
  double get balance => _balance;
  double get income => _income;
  double get expense => _expense;

  ExpenseProvider() {
    // loadExpenses();
  }

  Future<void> loadExpenses() async {
    // final dbExpenses = await DBService().getExpenses();
    // _expenses.clear();
    // _expenses.addAll(dbExpenses);
    // _updateTotals();
    // notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    // await DBService().insertExpense(expense);
    _expenses.insert(0, expense);
    _updateTotals();
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    // await DBService().deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    _updateTotals();
    notifyListeners();
  }

  void addPlannedPayment(PlannedPayment payment) {
    _plannedPayments.add(payment);
    notifyListeners();
  }

  void removePlannedPayment(String id) {
    _plannedPayments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void _updateTotals() {
    _income = _expenses
        .where((expense) => expense.type == TransactionType.income)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    
    _expense = _expenses
        .where((expense) => expense.type == TransactionType.expense)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    
    _balance = _income - _expense;
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start) && expense.date.isBefore(end))
        .toList();
  }
} 