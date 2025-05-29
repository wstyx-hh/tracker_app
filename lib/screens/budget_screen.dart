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
    if (limit == null || limit <= 0) return;
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category limit saved')));
  }

  Future<void> _saveAllBudget() async {
    final limit = double.tryParse(_allLimitController.text);
    if (limit == null || limit <= 0) return;
    await IsarService().addBudget(Budget.create(
      category: 'all',
      limit: limit,
      year: _year,
      month: _month,
    ));
    _allLimitController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total budget saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: FutureBuilder(
        future: Future.wait([
          IsarService().getBudgets(year: _year, month: _month),
          IsarService().getExpenses(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final budgets = snapshot.data![0] as List<Budget>;
          final expenses = snapshot.data![1] as List<ExpenseHive>;

          // Group expenses by category
          final Map<String, double> spentByCategory = {};
          double totalSpent = 0;
          for (final e in expenses) {
            if (e.date.year == _year && e.date.month == _month) {
              spentByCategory[e.category] = (spentByCategory[e.category] ?? 0) + e.amount;
              totalSpent += e.amount;
            }
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Budget for ${DateFormat('MMMM yyyy').format(DateTime(_year, _month))}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  // Общий лимит
                  Text('Total monthly limit', style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allLimitController,
                          decoration: const InputDecoration(hintText: 'Enter limit'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveAllBudget,
                        child: const Text('Save'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete total limit',
                        onPressed: () async {
                          final allBudget = budgets.where((b) => b.category == 'all').toList();
                          if (allBudget.isNotEmpty) {
                            await IsarService().deleteBudget(allBudget.first.id);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total budget deleted')));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final allBudget = budgets.where((b) => b.category == 'all').toList();
                    if (allBudget.isNotEmpty) {
                      final limit = allBudget.first.limit;
                      final percent = (totalSpent / limit).clamp(0, 1).toDouble();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: percent, minHeight: 8),
                          const SizedBox(height: 4),
                          Text('Spent: ${totalSpent.toStringAsFixed(2)} / ${limit.toStringAsFixed(2)}'),
                          if (totalSpent > limit)
                            Text('Limit exceeded!', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      );
                    }
                    return const SizedBox();
                  }),
                  const Divider(),
                  // Лимиты по категориям
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Category limits', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Add category limit',
                        onPressed: _categories.isEmpty ? null : () => setState(() => _showAddCategory = !_showAddCategory),
                      ),
                    ],
                  ),
                  if (_categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Add an expense first to set category limits', style: TextStyle(color: Colors.grey)),
                    ),
                  if (_showAddCategory && _categories.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val),
                            decoration: const InputDecoration(hintText: 'Category'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _limitController,
                            decoration: const InputDecoration(hintText: 'Limit'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectedCategory == null || _limitController.text.isEmpty ? null : () async {
                            await _saveBudget(_selectedCategory!);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  ...budgets.where((b) => b.category != 'all').map((b) {
                    final spent = spentByCategory[b.category] ?? 0;
                    final percent = (spent / b.limit).clamp(0, 1).toDouble();
                    return Card(
                      child: ListTile(
                        title: Text(b.category),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: percent, minHeight: 8),
                            const SizedBox(height: 4),
                            Text('Spent: ${spent.toStringAsFixed(2)} / ${b.limit.toStringAsFixed(2)}'),
                            if (spent > b.limit)
                              Text('Limit exceeded!', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await IsarService().deleteBudget(b.id);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                  // Аналитика
                  Text('Analytics', style: Theme.of(context).textTheme.titleMedium),
                  ...spentByCategory.entries.map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text(e.value.toStringAsFixed(2)),
                      )),
                  const SizedBox(height: 16),
                  // История бюджетов (по месяцам)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final prevMonth = _month == 1 ? 12 : _month - 1;
                          final prevYear = _month == 1 ? _year - 1 : _year;
                          setState(() {
                            _month = prevMonth;
                            _year = prevYear;
                          });
                        },
                        child: const Text('← Previous month'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final nextMonth = _month == 12 ? 1 : _month + 1;
                          final nextYear = _month == 12 ? _year + 1 : _year;
                          setState(() {
                            _month = nextMonth;
                            _year = nextYear;
                          });
                        },
                        child: const Text('Next month →'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
} 