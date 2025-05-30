import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/isar_service.dart';
import '../models/budget.dart';
import '../models/expense_hive.dart';
import '../l10n/app_localizations.dart';

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

  void _showEditBudgetDialog(Budget budget) {
    final editController = TextEditingController(text: budget.limit.toString());
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterLimit),
        content: TextField(
          controller: editController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.amount,
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final newLimit = double.tryParse(editController.text);
              if (newLimit == null || newLimit <= 0) {
                _showError('Please enter a valid limit');
                return;
              }
              budget.limit = newLimit;
              await IsarService().updateBudget(budget);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.themeChanged),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budget),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showAddCategory = true;
              });
            },
            tooltip: l10n.addCategoryLimit,
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
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
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
                setState(() {
                  if (_month == 1) {
                    _month = 12;
                    _year--;
                  } else {
                    _month--;
                  }
                });
              },
              tooltip: l10n.previousMonth,
            ),
            Text(
              '${DateFormat.MMMM(l10n.locale.toString()).format(DateTime(_year, _month))} $_year',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  if (_month == 12) {
                    _month = 1;
                    _year++;
                  } else {
                    _month++;
                  }
                });
              },
              tooltip: l10n.nextMonth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard(List<Budget> budgets, double totalSpent) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final allBudget = budgets.where((b) => b.category == 'all').toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalMonthlyLimit,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (allBudget.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditBudgetDialog(allBudget.first),
                    tooltip: l10n.edit,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (allBudget.isEmpty)
              TextField(
                controller: _allLimitController,
                decoration: InputDecoration(
                  labelText: l10n.enterLimit,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () async {
                      final limit = double.tryParse(_allLimitController.text);
                      if (limit != null) {
                        await IsarService().addBudget(
                          Budget.create(
                            category: 'all',
                            limit: limit,
                            year: _year,
                            month: _month,
                          ),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              )
            else
              InkWell(
                onTap: () => _showEditBudgetDialog(allBudget.first),
                child: _buildBudgetProgress(
                  spent: totalSpent,
                  limit: allBudget.first.limit,
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress({
    required double spent,
    required double limit,
    required ThemeData theme,
  }) {
    final l10n = AppLocalizations.of(context);
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isExceeded = spent > limit;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.spent,
              style: theme.textTheme.titleMedium,
            ),
            Text(
              spent.toStringAsFixed(2),
              style: theme.textTheme.titleMedium?.copyWith(
                color: isExceeded ? Colors.red : null,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(
              isExceeded ? Colors.red : theme.colorScheme.primary,
            ),
            minHeight: 8,
          ),
        ),
        if (isExceeded) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.limitExceeded} ${(spent - limit).toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddCategoryCard() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
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
    final l10n = AppLocalizations.of(context);
    final categoryBudgets = budgets.where((b) => b.category != 'all').toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categoryLimits,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...categoryBudgets.map((budget) {
          final spent = spentByCategory[budget.category] ?? 0;
          return _buildCategoryBudgetCard(budget, spent);
        }),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(Budget budget, double spent) {
    final theme = Theme.of(context);
    final progress = spent / budget.limit;
    final isExceeded = progress > 1;
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showEditBudgetDialog(budget),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _categoryIcons[budget.category] ?? Icons.category_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        budget.category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditBudgetDialog(budget),
                    tooltip: l10n.edit,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    isExceeded ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.spent}: \$${spent.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${l10n.limit}: \$${budget.limit.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isExceeded) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.limitExceeded} \$${(spent - budget.limit).toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics(Map<String, double> spentByCategory) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sortedCategories = spentByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedCategories.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.analytics,
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