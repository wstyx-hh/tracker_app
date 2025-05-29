import 'package:hive/hive.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // Incomes
  Future<void> addIncome(Income income) async {
    final box = Hive.box('incomes');
    await box.add(income);
    print('[DEBUG] Income transaction added: amount=[32m[1m[4m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m[0m');
  }

  List<Income> getIncomes() {
    final box = Hive.box('incomes');
    return box.values.cast<Income>().toList();
  }

  Future<void> deleteIncome(int key) async {
    final box = Hive.box('incomes');
    await box.delete(key);
  }

  // Expenses
  Future<void> addExpense(ExpenseHive expense) async {
    final box = Hive.box('expenses');
    await box.add(expense);
    print('[DEBUG] Expense transaction added: category=${expense.category}, amount=${expense.amount}');
  }

  List<ExpenseHive> getExpenses() {
    final box = Hive.box('expenses');
    return box.values.cast<ExpenseHive>().toList();
  }

  Future<void> deleteExpense(int key) async {
    final box = Hive.box('expenses');
    await box.delete(key);
  }

  // Accounts
  Future<void> addAccount(Account account) async {
    final box = Hive.box('accounts');
    await box.add(account);
    print('[DEBUG] Account added: name=${account.name}, balance=${account.balance}');
  }

  List<Account> getAccounts() {
    final box = Hive.box('accounts');
    return box.values.cast<Account>().toList();
  }

  Future<void> deleteAccount(int key) async {
    final box = Hive.box('accounts');
    await box.delete(key);
  }
} 