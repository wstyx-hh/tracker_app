import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import '../models/account_transaction.dart';
import 'dart:convert';
import 'dart:io';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  static Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([
      IncomeSchema,
      ExpenseHiveSchema,
      AccountSchema,
      AccountTransactionSchema,
    ], directory: dir.path);
    return _isar!;
  }

  // INCOME
  Future<void> addIncome(Income income) async {
    final db = await isar;
    await db.writeTxn(() => db.incomes.put(income));
  }

  Future<List<Income>> getIncomes() async {
    final db = await isar;
    return db.incomes.where().sortByDateDesc().findAll();
  }

  Future<void> deleteIncome(int id) async {
    final db = await isar;
    await db.writeTxn(() => db.incomes.delete(id));
  }

  // EXPENSE
  Future<void> addExpense(ExpenseHive expense) async {
    final db = await isar;
    await db.writeTxn(() => db.expenseHives.put(expense));
  }

  Future<List<ExpenseHive>> getExpenses() async {
    final db = await isar;
    return db.expenseHives.where().sortByDateDesc().findAll();
  }

  Future<void> deleteExpense(int id) async {
    final db = await isar;
    await db.writeTxn(() => db.expenseHives.delete(id));
  }

  // ACCOUNT
  Future<void> addAccount(Account account) async {
    final db = await isar;
    await db.writeTxn(() => db.accounts.put(account));
  }

  Future<List<Account>> getAccounts() async {
    final db = await isar;
    return db.accounts.where().findAll();
  }

  Future<void> deleteAccount(int id) async {
    final db = await isar;
    await db.writeTxn(() => db.accounts.delete(id));
  }

  Future<void> clearAllData() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.incomes.clear();
      await db.expenseHives.clear();
      await db.accounts.clear();
    });
  }

  Future<String> exportData() async {
    final db = await isar;
    final incomes = await db.incomes.where().findAll();
    final expenses = await db.expenseHives.where().findAll();
    final accounts = await db.accounts.where().findAll();
    final data = {
      'incomes': incomes.map((e) => e.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonString) async {
    final db = await isar;
    final data = jsonDecode(jsonString);
    final incomes = (data['incomes'] as List).map((e) => Income()
      ..amount = e['amount']
      ..description = e['description']
      ..date = DateTime.parse(e['date'])).toList();
    final expenses = (data['expenses'] as List).map((e) => ExpenseHive()
      ..category = e['category']
      ..amount = e['amount']
      ..description = e['description']
      ..date = DateTime.parse(e['date'])).toList();
    final accounts = (data['accounts'] as List).map((e) => Account()
      ..name = e['name']
      ..balance = e['balance']).toList();
    await db.writeTxn(() async {
      await db.incomes.putAll(incomes);
      await db.expenseHives.putAll(expenses);
      await db.accounts.putAll(accounts);
    });
  }

  // ACCOUNT TRANSACTIONS
  Future<void> addAccountTransaction(AccountTransaction tx) async {
    final db = await isar;
    await db.writeTxn(() => db.accountTransactions.put(tx));
  }

  Future<List<AccountTransaction>> getAccountTransactions({int? accountId}) async {
    final db = await isar;
    if (accountId != null) {
      return db.accountTransactions.filter().accountIdEqualTo(accountId).sortByDateDesc().findAll();
    } else {
      return db.accountTransactions.where().sortByDateDesc().findAll();
    }
  }
} 