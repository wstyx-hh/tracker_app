import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class TransactionTile extends StatelessWidget {
  final Expense expense;

  const TransactionTile({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = expense.type == TransactionType.expense;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<ExpenseProvider>(context, listen: false).removeExpense(expense.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isExpense
                ? theme.colorScheme.error.withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(
              isExpense ? Icons.remove : Icons.add,
              color: isExpense
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          title: Text(
            expense.title,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            '${expense.category} • ${DateFormat('MMM d, y').format(expense.date)}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            '${isExpense ? '-' : '+'}\$${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isExpense
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            // TODO: Show transaction details
          },
        ),
      ),
    );
  }
}
