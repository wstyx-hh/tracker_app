import 'package:isar/isar.dart';
part 'income.g.dart';

@Collection()
class Income {
  Id id = Isar.autoIncrement;
  late double amount;
  late String description;
  late DateTime date;

  Income();
  Income.create({required this.amount, required this.description, required this.date});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };
} 