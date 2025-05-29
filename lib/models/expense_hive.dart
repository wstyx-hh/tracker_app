import 'package:isar/isar.dart';
part 'expense_hive.g.dart';

@Collection()
class ExpenseHive {
  Id id = Isar.autoIncrement;
  late String category;
  late double amount;
  late String description;
  late DateTime date;

  ExpenseHive();
  ExpenseHive.create({required this.category, required this.amount, required this.description, required this.date});

  Map<String, dynamic> toJson() => {
    'category': category,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };
} 