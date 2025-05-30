import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import '../models/account_transaction.dart';
import '../services/isar_service.dart';
import '../models/expense_categories.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _expenseFormKey = GlobalKey<FormState>();
  final _incomeFormKey = GlobalKey<FormState>();

  // Income
  final _incomeAmountController = TextEditingController();
  final _incomeDescController = TextEditingController();
  String _incomeSource = 'Card';
  DateTime _incomeDate = DateTime.now();

  // Expense
  final _expenseAmountController = TextEditingController();
  final _expenseDescController = TextEditingController();
  String _expenseCategory = 'Entertainment';
  DateTime _expenseDate = DateTime.now();

  final Map<String, IconData> _categoryIcons = {
    'Entertainment': Icons.movie_outlined,
    'Health': Icons.favorite_outline,
    'Shopping': Icons.shopping_bag_outlined,
    'Bills': Icons.receipt_outlined,
    'Transportation': Icons.directions_car_outlined,
    'Food': Icons.restaurant_outlined,
    'Education': Icons.school_outlined,
    'Other': Icons.more_horiz_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeAmountController.dispose();
    _incomeDescController.dispose();
    _expenseAmountController.dispose();
    _expenseDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabController.index == 0 ? l10n.addExpense : l10n.addIncome),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              // Clear forms when switching tabs
              if (index == 0) {
                _expenseAmountController.clear();
                _expenseDescController.clear();
                _expenseDate = DateTime.now();
              } else {
                _incomeAmountController.clear();
                _incomeDescController.clear();
                _incomeDate = DateTime.now();
              }
            });
          },
          tabs: [
            Tab(text: l10n.expenses),
            Tab(text: l10n.income),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseForm(),
          _buildIncomeForm(),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _expenseFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _expenseAmountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _expenseCategory,
              decoration: InputDecoration(
                labelText: l10n.category,
              ),
              items: ExpenseCategories.getExpenseCategories(context)
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(ExpenseCategories.getLocalizedCategory(context, category)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _expenseCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expenseDescController,
              decoration: InputDecoration(
                labelText: l10n.description,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterDescription;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.date),
              subtitle: Text(l10n.formatDate(_expenseDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(true),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _saveExpense(),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeForm() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _incomeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _incomeAmountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _incomeSource,
              decoration: InputDecoration(
                labelText: l10n.category,
              ),
              items: ExpenseCategories.getIncomeCategories(context)
                  .map((source) => DropdownMenuItem(
                        value: source,
                        child: Text(ExpenseCategories.getLocalizedCategory(context, source)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _incomeSource = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incomeDescController,
              decoration: InputDecoration(
                labelText: l10n.description,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterDescription;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.date),
              subtitle: Text(l10n.formatDate(_incomeDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _saveIncome(),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isExpense) async {
    final l10n = AppLocalizations.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isExpense ? _expenseDate : _incomeDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isExpense) {
          _expenseDate = picked;
        } else {
          _incomeDate = picked;
        }
      });
    }
  }

  void _saveExpense() async {
    if (_expenseFormKey.currentState!.validate()) {
      final amount = double.parse(_expenseAmountController.text);
      final transaction = AccountTransaction()
        ..accountId = 1  // Default account ID
        ..amount = amount
        ..category = _expenseCategory
        ..description = _expenseDescController.text
        ..date = _expenseDate
        ..type = 'withdrawal'
        ..isExpense = true;

      await IsarService().addAccountTransaction(transaction);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _saveIncome() async {
    if (_incomeFormKey.currentState!.validate()) {
      final amount = double.parse(_incomeAmountController.text);
      final transaction = AccountTransaction()
        ..accountId = 1  // Default account ID
        ..amount = amount
        ..category = _incomeSource
        ..description = _incomeDescController.text
        ..date = _incomeDate
        ..type = 'deposit'
        ..isExpense = false;

      await IsarService().addAccountTransaction(transaction);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
