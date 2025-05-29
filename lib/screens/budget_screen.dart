import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/isar_service.dart';
import '../models/budget.dart';
import '../models/expense_hive.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int _year;
  late int _month;
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  final _allLimitController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];
  bool _showAddCategory = false;

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
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final expenses = await IsarService().getExpenses();
    final cats = expenses.map((e) => e.category).toSet().toList();
    setState(() {
      _categories = cats;
      if (_categories.isNotEmpty) _selectedCategory = _categories.first;
    });
  }

  Future<void> _saveBudget(String category) async {
    final limit = double.tryParse(_limitController.text);
    if (limit == null || limit <= 0) {
      _showError('Please enter a valid limit');
      return;
    }
    
    final existing = await IsarService().getBudgetForCategory(category, _year, _month);
    if (existing != null) {
      existing.limit = limit;
      await IsarService().updateBudget(existing);
    } else {
      await IsarService().addBudget(Budget.create(
        category: category,
        limit: limit,
        year: _year,
        month: _month,
      ));
    }
    
    _limitController.clear();
    setState(() => _showAddCategory = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category limit saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _saveAllBudget() async {
    final limit = double.tryParse(_allLimitController.text);
    if (limit == null || limit <= 0) {
      _showError('Please enter a valid limit');
      return;
    }
    
    await IsarService().addBudget(Budget.create(
      category: 'all',
      limit: limit,
      year: _year,
      month: _month,
    ));
    
    _allLimitController.clear();
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Total budget saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add category limit',
            onPressed: _categories.isEmpty ? null : () => setState(() => _showAddCategory = !_showAddCategory),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          IsarService().getBudgets(year: _year, month: _month),
          IsarService().getExpenses(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          final budgets = snapshot.data![0] as List<Budget>;
          final expenses = snapshot.data![1] as List<ExpenseHive>;

          final Map<String, double> spentByCategory = {};
          double totalSpent = 0;
          for (final e in expenses) {
            if (e.date.year == _year && e.date.month == _month) {
              spentByCategory[e.category] = (spentByCategory[e.category] ?? 0) + e.amount;
              totalSpent += e.amount;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildMonthSelector(),
              const SizedBox(height: 24),
              _buildTotalBudgetCard(budgets, totalSpent),
              if (_showAddCategory && _categories.isNotEmpty)
                _buildAddCategoryCard(),
              const SizedBox(height: 24),
              _buildCategoryBudgets(budgets, spentByCategory),
              const SizedBox(height: 24),
              _buildAnalytics(spentByCategory),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final prevMonth = _month == 1 ? 12 : _month - 1;
                final prevYear = _month == 1 ? _year - 1 : _year;
                setState(() {
                  _month = prevMonth;
                  _year = prevYear;
                });
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final nextMonth = _month == 12 ? 1 : _month + 1;
                final nextYear = _month == 12 ? _year + 1 : _year;
                setState(() {
                  _month = nextMonth;
                  _year = nextYear;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard(List<Budget> budgets, double totalSpent) {
    final theme = Theme.of(context);
    final allBudget = budgets.where((b) => b.category == 'all').toList();
    
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
              'Total Budget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (allBudget.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allLimitController,
                      decoration: InputDecoration(
                        hintText: 'Enter total budget limit',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveAllBudget,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spent',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalSpent.toStringAsFixed(2),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Limit',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                allBudget.first.limit.toStringAsFixed(2),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await IsarService().deleteBudget(allBudget.first.id);
                                  setState(() {});
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Total budget deleted'),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildProgressBar(
                    spent: totalSpent,
                    limit: allBudget.first.limit,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryCard() {
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
              'Add Category Budget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(
                        _categoryIcons[cat] ?? Icons.category_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(cat),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _limitController,
                    decoration: InputDecoration(
                      labelText: 'Limit',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _selectedCategory == null || _limitController.text.isEmpty
                      ? null
                      : () => _saveBudget(_selectedCategory!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgets(List<Budget> budgets, Map<String, double> spentByCategory) {
    final theme = Theme.of(context);
    final categoryBudgets = budgets.where((b) => b.category != 'all').toList();
    
    if (categoryBudgets.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No category budgets yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add category budgets to track your spending by category',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Budgets',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...categoryBudgets.map((budget) {
          final spent = spentByCategory[budget.category] ?? 0;
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _categoryIcons[budget.category] ?? Icons.category_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.category,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Limit: ${budget.limit.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await IsarService().deleteBudget(budget.id);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(
                    spent: spent,
                    limit: budget.limit,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProgressBar({
    required double spent,
    required double limit,
  }) {
    final theme = Theme.of(context);
    final percent = (spent / limit).clamp(0.0, 1.0);
    final isExceeded = spent > limit;
    final color = isExceeded ? theme.colorScheme.error : theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withOpacity(0.8),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${spent.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (isExceeded)
              Text(
                'Exceeded by ${(spent - limit).toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'Remaining: ${(limit - spent).toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalytics(Map<String, double> spentByCategory) {
    final theme = Theme.of(context);
    final sortedCategories = spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedCategories.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _categoryIcons[entry.key] ?? Icons.category_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: theme.textTheme.titleMedium,
                ),
                trailing: Text(
                  entry.value.toStringAsFixed(2),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 