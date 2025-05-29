import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'expense.dart';

enum PaymentRepeat { once, daily, weekly, monthly, yearly }

class PlannedPayment {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String? note;
  final PaymentRepeat repeat;
  final bool reminder;

  PlannedPayment({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.note,
    this.repeat = PaymentRepeat.once,
    this.reminder = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type.toString(),
      'note': note,
      'repeat': repeat.toString(),
      'reminder': reminder ? 1 : 0,
    };
  }

  factory PlannedPayment.fromMap(Map<String, dynamic> map) {
    return PlannedPayment(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      type: map['type'] == 'TransactionType.income'
          ? TransactionType.income
          : TransactionType.expense,
      note: map['note'],
      repeat: PaymentRepeat.values.firstWhere(
        (e) => e.toString() == map['repeat'],
        orElse: () => PaymentRepeat.once,
      ),
      reminder: map['reminder'] == 1,
    );
  }
} 