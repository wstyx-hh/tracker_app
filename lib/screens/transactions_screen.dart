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
              Tab(text: 'Incomes'),
              Tab(text: 'Expenses'),
              Tab(text: 'Accounts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Incomes Tab (как было)
            _buildIncomesTab(),
            // Expenses Tab (как было)
            _buildExpensesTab(),
            // Accounts Tab (новая история)
            FutureBuilder<List<AccountTransaction>>(
              future: IsarService().getAccountTransactions(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final txs = snapshot.data!;
                if (txs.isEmpty) {
                  return const Center(child: Text('No account history yet.'));
                }
                return ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final tx = txs[i];
                    return ListTile(
                      leading: Icon(
                        tx.type == 'deposit'
                            ? Icons.arrow_downward
                            : tx.type == 'withdrawal'
                                ? Icons.arrow_upward
                                : Icons.swap_horiz,
                        color: tx.type == 'deposit'
                            ? Colors.green
                            : tx.type == 'withdrawal'
                                ? Colors.red
                                : Colors.blue,
                      ),
                      title: Text(
                        (tx.type == 'deposit'
                            ? 'Пополнение'
                            : tx.type == 'withdrawal'
                                ? 'Снятие'
                                : 'Перевод') +
                        ' на счет ID ${tx.accountId}',
                      ),
                      subtitle: Text('${dateFormat.format(tx.date)} — ${tx.description}'),
                      trailing: Text(
                        (tx.type == 'deposit' ? '+' : '-') + tx.amount.toStringAsFixed(2),
                        style: TextStyle(
                          color: tx.type == 'deposit'
                              ? Colors.green
                              : tx.type == 'withdrawal'
                                  ? Colors.red
                                  : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomesTab() {
    return FutureBuilder(
      future: Future.wait([
        IsarService().getIncomes(),
        IsarService().getAccounts(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allIncomes = snapshot.data![0] as List<Income>;
        final accounts = snapshot.data![1] as List<Account>;
        final incomes = _filterIncomesByDateRange(allIncomes);

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
                      '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
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
                              await IsarService().deleteIncome(i.id);
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
                    if (incomes.isEmpty && accounts.isEmpty)
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
      },
    );
  }

  Widget _buildExpensesTab() {
    return FutureBuilder(
      future: Future.wait([
        IsarService().getExpenses(),
        IsarService().getAccounts(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allExpenses = snapshot.data![0] as List<ExpenseHive>;
        final accounts = snapshot.data![1] as List<Account>;
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
                      '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
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
                              await IsarService().deleteExpense(e.id);
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
                              '-\$${accounts.fold<double>(0, (sum, a) => sum + a.balance).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (expenses.isEmpty && accounts.isEmpty)
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
      },
    );
  }
} 