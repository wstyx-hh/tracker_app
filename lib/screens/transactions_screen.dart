import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hive_service.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<Income> _filterIncomesByDateRange(List<Income> incomes) {
    return incomes.where((income) {
      return income.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             income.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<ExpenseHive> _filterExpensesByDateRange(List<ExpenseHive> expenses) {
    return expenses.where((expense) {
      return expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             expense.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allIncomes = HiveService().getIncomes();
    final allExpenses = HiveService().getExpenses();
    final accounts = HiveService().getAccounts();

    final incomes = _filterIncomesByDateRange(allIncomes);
    final expenses = _filterExpensesByDateRange(allExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range),
                  label: const Text('Change Date Range'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (incomes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Incomes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...incomes.map((i) => ListTile(
                        leading: const Icon(Icons.add, color: Colors.green),
                        title: Text('Salary'),
                        subtitle: Text(i.description),
                        trailing: Text('+\$${i.amount.toStringAsFixed(2)}'),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        subtitleTextStyle: const TextStyle(fontSize: 13),
                        onLongPress: () async {
                          await HiveService().deleteIncome(i.key as int);
                          setState(() {});
                        },
                      )),
                ],
                if (expenses.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...expenses.map((e) => ListTile(
                        leading: const Icon(Icons.remove, color: Colors.red),
                        title: Text(e.category),
                        subtitle: Text(e.description),
                        trailing: Text('-\$${e.amount.toStringAsFixed(2)}'),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        subtitleTextStyle: const TextStyle(fontSize: 13),
                        onLongPress: () async {
                          await HiveService().deleteExpense(e.key as int);
                          setState(() {});
                        },
                      )),
                ],
                if (accounts.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...accounts.map((a) => ListTile(
                        leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                        title: Text(a.name),
                        trailing: Text('+\$${a.balance.toStringAsFixed(2)}'),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      )),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '+\$${accounts.fold<double>(0, (sum, a) => sum + a.balance).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
                if (incomes.isEmpty && expenses.isEmpty && accounts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No operations for selected date range'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 