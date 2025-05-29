import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/isar_service.dart';
import '../models/income.dart';
import '../models/expense_hive.dart';
import '../models/account.dart';
import '../models/account_transaction.dart';
import 'add_transaction_screen.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Incomes'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllTab(),
            _buildIncomesTab(),
            _buildExpensesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    return FutureBuilder(
      future: Future.wait([
        IsarService().getIncomes(),
        IsarService().getExpenses(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allIncomes = snapshot.data![0] as List<Income>;
        final allExpenses = snapshot.data![1] as List<ExpenseHive>;
        final incomes = _filterIncomesByDateRange(allIncomes);
        final expenses = _filterExpensesByDateRange(allExpenses);
        final allTx = [
          ...incomes.map((i) => {'type': 'income', 'date': i.date, 'amount': i.amount, 'desc': i.description}),
          ...expenses.map((e) => {'type': 'expense', 'date': e.date, 'amount': e.amount, 'desc': e.description, 'cat': e.category}),
        ]..sort((a, b) {
          final ad = a['date'] as DateTime?;
          final bd = b['date'] as DateTime?;
          if (ad == null || bd == null) return 0;
          return bd.compareTo(ad);
        });
        final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final total = totalIncome - totalExpenses;
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: allTx.map((tx) => ListTile(
                      leading: Icon(
                        tx['type'] == 'income' ? Icons.add : Icons.remove,
                        color: tx['type'] == 'income' ? Colors.green : Colors.red,
                      ),
                      title: Text(tx['type'] == 'income' ? 'Salary' : (tx['cat'] as String? ?? '')),
                      subtitle: Text('${dateFormat.format(tx['date'] as DateTime)} — ${(tx['desc'] as String?) ?? ''}'),
                      trailing: Text(
                        (tx['type'] == 'income' ? '+' : '-') + ((tx['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'),
                        style: TextStyle(
                          color: tx['type'] == 'income' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Income:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('+${totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Expenses:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('-${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: totalIncome == 0 ? 0 : (total / totalIncome).clamp(0, 1),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: total >= 0 ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            (total >= 0 ? '+' : '-') + total.abs().toStringAsFixed(2),
                            style: TextStyle(
                              color: total >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                    setState(() {});
                  },
                  child: const Icon(Icons.add, size: 20),
                  mini: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncomesTab() {
    return FutureBuilder(
      future: Future.wait([
        IsarService().getIncomes(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allIncomes = snapshot.data![0] as List<Income>;
        final incomes = _filterIncomesByDateRange(allIncomes);
        final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Incomes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _selectDateRange,
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                    setState(() {});
                  },
                  child: const Icon(Icons.add, size: 20),
                  mini: true,
                ),
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
                      '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '+${totalIncome.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
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
                            trailing: Text('+${i.amount.toStringAsFixed(2)}'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            subtitleTextStyle: const TextStyle(fontSize: 13),
                            onLongPress: () async {
                              await IsarService().deleteIncome(i.id);
                              setState(() {});
                            },
                          )),
                    ],
                    if (incomes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No incomes for selected date range'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab() {
    return FutureBuilder(
      future: Future.wait([
        IsarService().getExpenses(),
        IsarService().getIncomes(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allExpenses = snapshot.data![0] as List<ExpenseHive>;
        final allIncomes = snapshot.data![1] as List<Income>;
        final expenses = _filterExpensesByDateRange(allExpenses);
        final totalIncomes = _filterIncomesByDateRange(allIncomes).fold<double>(0, (sum, i) => sum + i.amount);
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final left = totalIncomes - totalExpenses;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Expenses'),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _selectDateRange,
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                    setState(() {});
                  },
                  child: const Icon(Icons.add, size: 20),
                  mini: true,
                ),
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
                      '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '-${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (expenses.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...expenses.map((e) => ListTile(
                            leading: const Icon(Icons.remove, color: Colors.red),
                            title: Text(e.category),
                            subtitle: Text(e.description),
                            trailing: Text('-${e.amount.toStringAsFixed(2)}'),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            subtitleTextStyle: const TextStyle(fontSize: 13),
                            onLongPress: () async {
                              await IsarService().deleteExpense(e.id);
                              setState(() {});
                            },
                          )),
                    ],
                    if (expenses.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No expenses for selected date range'),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Left from incomes:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      (left >= 0 ? '+' : '-') + left.abs().toStringAsFixed(2),
                      style: TextStyle(
                        color: left >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 