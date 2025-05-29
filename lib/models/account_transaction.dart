import 'package:isar/isar.dart';
part 'account_transaction.g.dart';

@Collection()
class AccountTransaction {
  Id id = Isar.autoIncrement;
  late int accountId;
  late double amount;
  late String description;
  late DateTime date;
  late String type; // 'deposit', 'withdrawal', 'transfer'
  late String category;
  late bool isExpense;

  AccountTransaction();
  AccountTransaction.create({
    required this.accountId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    required this.isExpense,
  });

  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
    'type': type,
    'category': category,
    'isExpense': isExpense,
  };
} 