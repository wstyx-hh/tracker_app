import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/hive_service.dart';
import '../models/expense_hive.dart';
import '../models/income.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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

  List<ExpenseHive> _filterExpensesByDateRange(List<ExpenseHive> expenses) {
    return expenses.where((expense) {
      return expense.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             expense.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Income> _filterIncomesByDateRange(List<Income> incomes) {
    return incomes.where((income) {
      return income.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             income.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, double> _getCategoryTotals(List<ExpenseHive> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  List<FlSpot> _getDailyExpenses(List<ExpenseHive> expenses) {
    final Map<int, double> dailyTotals = {};
    for (var expense in expenses) {
      final day = expense.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }
    return dailyTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  final List<Color> _pieChartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final allExpenses = HiveService().getExpenses();
    final allIncomes = HiveService().getIncomes();
    
    final expenses = _filterExpensesByDateRange(allExpenses);
    final incomes = _filterIncomesByDateRange(allIncomes);
    
    final categoryTotals = _getCategoryTotals(expenses);
    final dailyExpenses = _getDailyExpenses(expenses);

    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncomes = incomes.fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Income'),
                            Text(
                              '+\$${totalIncomes.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Expenses'),
                            Text(
                              '-\$${totalExpenses.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (expenses.isNotEmpty) ...[
              Text(
                'Expenses by Category',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      final percentage = (entry.value / totalExpenses * 100).toStringAsFixed(1);
                      final colorIndex = categoryTotals.keys.toList().indexOf(entry.key) % _pieChartColors.length;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '$percentage%',
                        radius: 100,
                        color: _pieChartColors[colorIndex],
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...categoryTotals.entries.map((entry) {
                final percentage = (entry.value / totalExpenses * 100).toStringAsFixed(1);
                final colorIndex = categoryTotals.keys.toList().indexOf(entry.key) % _pieChartColors.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: _pieChartColors[colorIndex],
                            margin: const EdgeInsets.only(right: 8),
                          ),
                          Text(entry.key),
                        ],
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)} ($percentage%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            if (expenses.isNotEmpty) ...[
              Text(
                'Daily Expenses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyExpenses,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (expenses.isEmpty && incomes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No data for selected date range'),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 