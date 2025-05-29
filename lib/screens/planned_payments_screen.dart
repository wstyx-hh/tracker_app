import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/planned_payment.dart';
import '../models/expense.dart';
import 'add_planned_payment_screen.dart';

class PlannedPaymentsScreen extends StatelessWidget {
  const PlannedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planned Payments'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final payments = provider.plannedPayments;
          if (payments.isEmpty) {
            return Center(
              child: Text('No planned payments'),
            );
          }
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (ctx, i) {
              final p = payments[i];
              return ListTile(
                leading: Icon(p.type == TransactionType.expense ? Icons.remove : Icons.add),
                title: Text(p.title),
                subtitle: Text('${p.category} • ${p.date.toLocal().toString().split(' ')[0]}'),
                trailing: Text('${p.type == TransactionType.expense ? '-' : '+'}4${p.amount.toStringAsFixed(2)}'),
                onLongPress: () => provider.removePlannedPayment(p.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlannedPaymentScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 