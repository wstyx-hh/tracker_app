import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Show add budget dialog
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final expenses = expenseProvider.expenses;
          
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budget set',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a budget to start tracking your spending',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBudgetOverview(context, expenseProvider),
              const SizedBox(height: 24),
              Text(
                'Category Budgets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ..._buildCategoryBudgets(context, expenses),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBudgetOverview(BuildContext context, ExpenseProvider provider) {
    final totalBudget = 1000.0; // TODO: Get from provider
    final spent = provider.expense;
    final remaining = totalBudget - spent;
    final progress = spent / totalBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BudgetInfo(
                  label: 'Spent',
                  amount: spent,
                  color: Theme.of(context).colorScheme.error,
                ),
                _BudgetInfo(
                  label: 'Remaining',
                  amount: remaining,
                  color: Theme.of(context).colorScheme.primary,
                ),
                _BudgetInfo(
                  label: 'Total',
                  amount: totalBudget,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryBudgets(BuildContext context, List<Expense> expenses) {
    final categoryExpenses = <String, double>{};
    for (var expense in expenses) {
      if (expense.type == TransactionType.expense) {
        categoryExpenses[expense.category] =
            (categoryExpenses[expense.category] ?? 0) + expense.amount;
      }
    }

    return categoryExpenses.entries.map((entry) {
      final category = entry.key;
      final spent = entry.value;
      final budget = 200.0; // TODO: Get from provider
      final progress = spent / budget;

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _BudgetInfo extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BudgetInfo({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
} 