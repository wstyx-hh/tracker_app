import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import '../models/account_transaction.dart';
import '../services/isar_service.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Income
  final _incomeAmountController = TextEditingController();
  final _incomeDescController = TextEditingController();
  DateTime _incomeDate = DateTime.now();

  // Expense
  final _expenseAmountController = TextEditingController();
  final _expenseDescController = TextEditingController();
  String _expenseCategory = 'Entertainment';
  DateTime _expenseDate = DateTime.now();
  final List<String> _expenseCategories = [
    'Entertainment', 'Health', 'Shopping', 'Bills', 'Transportation', 'Food', 'Education', 'Other',
  ];

  // Account
  final _accountNameController = TextEditingController();
  final _accountBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeAmountController.dispose();
    _incomeDescController.dispose();
    _expenseAmountController.dispose();
    _expenseDescController.dispose();
    _accountNameController.dispose();
    _accountBalanceController.dispose();
    super.dispose();
  }

  void _addIncome() async {
    if (_incomeAmountController.text.isEmpty) return;
    final amount = double.tryParse(_incomeAmountController.text);
    if (amount == null) return;
    final income = Income.create(
      amount: amount,
      description: _incomeDescController.text,
      date: _incomeDate,
    );
    await IsarService().addIncome(income);
    final accounts = await IsarService().getAccounts();
    if (accounts.isNotEmpty) {
      await IsarService().addAccountTransaction(AccountTransaction.create(
        accountId: accounts.first.id,
        amount: amount,
        description: _incomeDescController.text,
        date: _incomeDate,
        type: 'deposit',
      ));
    }
    Navigator.of(context).pop();
  }

  void _addExpense() async {
    if (_expenseAmountController.text.isEmpty) return;
    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null) return;
    final expense = ExpenseHive.create(
      category: _expenseCategory,
      amount: amount,
      description: _expenseDescController.text,
      date: _expenseDate,
    );
    await IsarService().addExpense(expense);
    final accounts = await IsarService().getAccounts();
    if (accounts.isNotEmpty) {
      await IsarService().addAccountTransaction(AccountTransaction.create(
        accountId: accounts.first.id,
        amount: amount,
        description: _expenseDescController.text,
        date: _expenseDate,
        type: 'withdrawal',
      ));
    }
    Navigator.of(context).pop();
  }

  void _addAccount() async {
    if (_accountNameController.text.isEmpty || _accountBalanceController.text.isEmpty) return;
    final balance = double.tryParse(_accountBalanceController.text);
    if (balance == null) return;
    final account = Account.create(
      name: _accountNameController.text,
      balance: balance,
    );
    await IsarService().addAccount(account);
    await IsarService().addAccountTransaction(AccountTransaction.create(
      accountId: account.id,
      amount: balance,
      description: 'Начальный баланс',
      date: DateTime.now(),
      type: 'deposit',
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // INCOME
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Only Salary can be added as income.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _incomeAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _incomeDescController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(dateFormat.format(_incomeDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _incomeDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _incomeDate = date);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addIncome,
                  child: const Text('Add Income'),
                ),
              ],
            ),
          ),
          // EXPENSE
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _expenseCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _expenseCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _expenseCategory = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expenseAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expenseDescController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(dateFormat.format(_expenseDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expenseDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _expenseDate = date);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: const Text('Add Expense'),
                ),
              ],
            ),
          ),
          // ACCOUNT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _accountNameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountBalanceController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addAccount,
                  child: const Text('Add Account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
