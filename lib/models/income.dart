import 'package:hive/hive.dart';
part 'income.g.dart';

@HiveType(typeId: 1)
class Income extends HiveObject {
  @HiveField(0)
  double amount;
  @HiveField(1)
  String description;
  @HiveField(2)
  DateTime date;

  Income({required this.amount, required this.description, required this.date});
} 