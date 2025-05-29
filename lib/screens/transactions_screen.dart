import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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

  void _selectDateRange() async {
    final l10n = AppLocalizations.of(context);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
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
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.transactions),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDateRange,
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Incomes'),
              Tab(text: 'Expenses'),
            ],
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllTab(),
            _buildIncomesTab(),
            _buildExpensesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
            );
            setState(() {});
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Transaction'),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final theme = Theme.of(context);
    final isIncome = tx['type'] == 'income';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isIncome ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIncome ? 'Income' : (tx['cat'] as String? ?? 'Expense'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(tx['date'] as DateTime)} — ${(tx['desc'] as String?) ?? ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              (isIncome ? '+' : '-') + ((tx['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalIncome,
    required double totalExpenses,
    required double total,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  label: 'Income',
                  amount: totalIncome,
                  isPositive: true,
                ),
                _buildSummaryItem(
                  label: 'Expenses',
                  amount: totalExpenses,
                  isPositive: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: totalIncome == 0 ? 0 : (total / totalIncome).clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        total >= 0 ? Colors.green : Colors.red,
                        total >= 0 ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  (total >= 0 ? '+' : '') + total.toStringAsFixed(2),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: total >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required bool isPositive,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          (isPositive ? '+' : '-') + amount.toStringAsFixed(2),
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        final allIncomes = snapshot.data![0] as List<Income>;
        final allExpenses = snapshot.data![1] as List<ExpenseHive>;
        final incomes = _filterIncomesByDateRange(allIncomes);
        final expenses = _filterExpensesByDateRange(allExpenses);
        
        final allTx = [
          ...incomes.map((i) => {
            'type': 'income',
            'date': i.date,
            'amount': i.amount,
            'desc': i.description
          }),
          ...expenses.map((e) => {
            'type': 'expense',
            'date': e.date,
            'amount': e.amount,
            'desc': e.description,
            'cat': e.category
          }),
        ]..sort((a, b) {
          final ad = a['date'] as DateTime?;
          final bd = b['date'] as DateTime?;
          if (ad == null || bd == null) return 0;
          return bd.compareTo(ad);
        });

        final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final total = totalIncome - totalExpenses;

        if (allTx.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: [
            _buildSummaryCard(
              totalIncome: totalIncome,
              totalExpenses: totalExpenses,
              total: total,
            ),
            ...allTx.map(_buildTransactionCard),
            const SizedBox(height: 80), // FAB spacing
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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        final allIncomes = snapshot.data![0] as List<Income>;
        final incomes = _filterIncomesByDateRange(allIncomes);
        final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade200,
                        Colors.green.shade50,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Income',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalIncome.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _selectDateRange,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
            if (incomes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 64,
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No income records yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your earnings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final income = incomes[index];
                    final isFirst = index == 0;
                    final isLast = index == incomes.length - 1;
                    
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, isFirst ? 16 : 8, 16, isLast ? 80 : 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onLongPress: () async {
                            await IsarService().deleteIncome(income.id);
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Salary',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(income.date),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '+${income.amount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (income.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Text(
                                    income.description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: incomes.length,
                ),
              ),
          ],
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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        final allExpenses = snapshot.data![0] as List<ExpenseHive>;
        final allIncomes = snapshot.data![1] as List<Income>;
        final expenses = _filterExpensesByDateRange(allExpenses);
        final totalIncomes = _filterIncomesByDateRange(allIncomes).fold<double>(0, (sum, i) => sum + i.amount);
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final left = totalIncomes - totalExpenses;

        // Group expenses by category
        final Map<String, List<ExpenseHive>> expensesByCategory = {};
        for (final expense in expenses) {
          if (!expensesByCategory.containsKey(expense.category)) {
            expensesByCategory[expense.category] = [];
          }
          expensesByCategory[expense.category]!.add(expense);
        }

        // Calculate total for each category
        final Map<String, double> categoryTotals = {};
        expensesByCategory.forEach((category, expenses) {
          categoryTotals[category] = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );
        });

        // Sort categories by total amount
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade200,
                        Colors.red.shade50,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Expenses',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          totalExpenses.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        Text(
                          '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                        if (totalIncomes > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Left from income: ${left.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: left >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _selectDateRange,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
            if (expenses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.red.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your spending',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ...sortedCategories.map((entry) {
                          final category = entry.key;
                          final total = entry.value;
                          final percentage = (total / totalExpenses * 100).toStringAsFixed(1);
                          
                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _categoryIcons[category] ?? Icons.category_outlined,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                title: Text(category),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      total.toStringAsFixed(2),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (category != sortedCategories.last.key)
                                const Divider(height: 1, indent: 56),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              ...sortedCategories.map((entry) {
                final category = entry.key;
                final categoryExpenses = expensesByCategory[category]!;
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = categoryExpenses[index];
                        final isFirst = index == 0;
                        final isLast = index == categoryExpenses.length - 1;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isFirst) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                child: Text(
                                  category,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onLongPress: () async {
                                  await IsarService().deleteExpense(expense.id);
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _categoryIcons[category] ?? Icons.category_outlined,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expense.description.isEmpty ? category : expense.description,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              dateFormat.format(expense.date),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '-${expense.amount.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: categoryExpenses.length,
                    ),
                  ),
                );
              }),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80),
              ),
            ],
          ],
        );
      },
    );
  }
} 