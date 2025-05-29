import 'package:isar/isar.dart';
part 'budget.g.dart';

@Collection()
class Budget {
  Id id = Isar.autoIncrement;
  late String category; // 'all' для общего лимита
  late double limit;
  late int year;
  late int month;

  Budget();
  Budget.create({required this.category, required this.limit, required this.year, required this.month});

  Map<String, dynamic> toJson() => {
    'category': category,
    'limit': limit,
    'year': year,
    'month': month,
  };
} 