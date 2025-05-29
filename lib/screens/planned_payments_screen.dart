import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/planned_payment.dart';
import '../models/expense.dart';
import 'add_planned_payment_screen.dart';

class PlannedPaymentsScreen extends StatelessWidget {
  const PlannedPaymentsScreen({super.key});

  final Map<String, IconData> _categoryIcons = const {
    'Food': Icons.restaurant_outlined,
    'Transportation': Icons.directions_car_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Bills': Icons.receipt_outlined,
    'Entertainment': Icons.movie_outlined,
    'Health': Icons.favorite_outline,
    'Education': Icons.school_outlined,
    'Other': Icons.more_horiz_outlined,
    'Salary': Icons.work_outline,
    'Business': Icons.business_center_outlined,
    'Gift': Icons.card_giftcard_outlined,
    'Interest': Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planned Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add planned payment',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPlannedPaymentScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final payments = provider.plannedPayments;
          
          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No planned payments',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first planned payment',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddPlannedPaymentScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group payments by month
          final Map<String, List<PlannedPayment>> groupedPayments = {};
          for (final payment in payments) {
            final monthKey = DateFormat('MMMM yyyy').format(payment.date);
            if (!groupedPayments.containsKey(monthKey)) {
              groupedPayments[monthKey] = [];
            }
            groupedPayments[monthKey]!.add(payment);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedPayments.length,
            itemBuilder: (context, index) {
              final monthKey = groupedPayments.keys.elementAt(index);
              final monthPayments = groupedPayments[monthKey]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      monthKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ...monthPayments.map((payment) => _buildPaymentCard(context, payment, provider)),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PlannedPayment payment, ExpenseProvider provider) {
    final theme = Theme.of(context);
    final isExpense = payment.type == TransactionType.expense;
    final color = isExpense ? theme.colorScheme.error : Colors.green;
    
    return Dismissible(
      key: Key(payment.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.error,
        ),
      ),
      onDismissed: (direction) {
        provider.removePlannedPayment(payment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Planned payment removed'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcons[payment.category] ?? Icons.category_outlined,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.category,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isExpense ? '-' : '+'}${payment.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d').format(payment.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.repeat != PaymentRepeat.once || payment.reminder) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (payment.repeat != PaymentRepeat.once)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              payment.repeat.name[0].toUpperCase() + payment.repeat.name.substring(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (payment.repeat != PaymentRepeat.once && payment.reminder)
                      const SizedBox(width: 8),
                    if (payment.reminder)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '3 days before',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              if (payment.note != null) ...[
                const SizedBox(height: 12),
                Text(
                  payment.note!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 