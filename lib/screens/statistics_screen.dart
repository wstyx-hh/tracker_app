import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min, max;
import '../models/expense_hive.dart';
import '../models/income.dart';
import '../services/isar_service.dart';

final dateFormat = DateFormat('dd.MM.yyyy');

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
    return Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
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
    const Color(0xFF6B4EFF), // Purple
    const Color(0xFF32D74B), // Green
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFF69B4), // Pink
    const Color(0xFF845EC2), // Deep Purple
    const Color(0xFF00B8D9), // Blue
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FutureBuilder(
      future: Future.wait([
        IsarService().getExpenses(),
        IsarService().getIncomes(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Statistics')),
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        final allExpenses = snapshot.data![0] as List<ExpenseHive>;
        final allIncomes = snapshot.data![1] as List<Income>;
        final expenses = _filterExpensesByDateRange(allExpenses);
        final incomes = _filterIncomesByDateRange(allIncomes);
        final categoryTotals = _getCategoryTotals(expenses);
        final dailyExpenses = _getDailyExpenses(expenses);
        final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final totalIncomes = incomes.fold<double>(0, (sum, i) => sum + i.amount);
        final balance = totalIncomes - totalExpenses;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: _selectDateRange,
                tooltip: 'Select Date Range',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  totalIncomes: totalIncomes,
                  totalExpenses: totalExpenses,
                  balance: balance,
                ),
                if (expenses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildCategoryChart(categoryTotals, totalExpenses),
                  const SizedBox(height: 24),
                  _buildDailyExpensesChart(dailyExpenses),
                ] else
                  _buildEmptyState(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required double totalIncomes,
    required double totalExpenses,
    required double balance,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
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
                  'Financial Summary',
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
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.arrow_upward,
                    label: 'Income',
                    amount: totalIncomes,
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.arrow_downward,
                    label: 'Expenses',
                    amount: totalExpenses,
                    isPositive: false,
                  ),
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
                widthFactor: totalIncomes == 0 ? 0 : (balance / totalIncomes).clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        balance >= 0 ? Colors.green : Colors.red,
                        balance >= 0 ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
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
                  (balance >= 0 ? '+' : '') + balance.toStringAsFixed(2),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: balance >= 0 ? Colors.green : Colors.red,
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
    required IconData icon,
    required String label,
    required double amount,
    required bool isPositive,
  }) {
    final theme = Theme.of(context);
    final color = isPositive ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (isPositive ? '+' : '-') + amount.toStringAsFixed(2),
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categoryTotals, double totalExpenses) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categoryTotals.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses * 100);
                    final colorIndex = categoryTotals.keys.toList().indexOf(entry.key) % _pieChartColors.length;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 130,
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
            const SizedBox(height: 24),
            ...categoryTotals.entries.map((entry) {
              final percentage = (entry.value / totalExpenses * 100);
              final colorIndex = categoryTotals.keys.toList().indexOf(entry.key) % _pieChartColors.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _pieChartColors[colorIndex],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toStringAsFixed(2),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpensesChart(List<FlSpot> dailyExpenses) {
    final theme = Theme.of(context);
    final maxY = dailyExpenses.isEmpty ? 100.0 : dailyExpenses.map((e) => e.y).reduce(max) * 1.2;
    final minY = dailyExpenses.isEmpty ? 0.0 : dailyExpenses.map((e) => e.y).reduce(min) * 0.8;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'Daily Expenses',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: maxY / 10,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.15),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.05),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Amount',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxY / 5,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Day of Month',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                value.toStringAsFixed(0),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    minX: dailyExpenses.isEmpty ? 0 : dailyExpenses.map((e) => e.x).reduce(min),
                    maxX: dailyExpenses.isEmpty ? 30 : dailyExpenses.map((e) => e.x).reduce(max),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyExpenses,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        preventCurveOverShooting: true,
                        color: theme.colorScheme.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: theme.colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: theme.colorScheme.surface,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.3),
                              theme.colorScheme.primary.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.8],
                          ),
                        ),
                        shadow: Shadow(
                          color: theme.colorScheme.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: theme.colorScheme.surface,
                        tooltipRoundedRadius: 16,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        tooltipMargin: 16,
                        tooltipBorder: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final date = DateTime(_startDate.year, _startDate.month, barSpot.x.toInt());
                            return LineTooltipItem(
                              '${dateFormat.format(date)}\n',
                              TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: barSpot.y.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: [const FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        // Можно добавить дополнительную интерактивность здесь
                      },
                      handleBuiltInTouches: true,
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              strokeWidth: 2,
                              dashArray: [3, 3],
                            ),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 8,
                                  color: theme.colorScheme.surface,
                                  strokeWidth: 3,
                                  strokeColor: theme.colorScheme.primary,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding expenses to see your statistics',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 