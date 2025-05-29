import 'package:hive/hive.dart';
part 'expense_hive.g.dart';

@HiveType(typeId: 2)
class ExpenseHive extends HiveObject {
  @HiveField(0)
  String category;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String description;
  @HiveField(3)
  DateTime date;

  ExpenseHive({required this.category, required this.amount, required this.description, required this.date});
} 