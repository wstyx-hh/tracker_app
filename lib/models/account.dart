import 'package:isar/isar.dart';
part 'account.g.dart';

@Collection()
class Account {
  Id id = Isar.autoIncrement;
  late String name;
  late double balance;

  Account();
  Account.create({required this.name, required this.balance, this.id = Isar.autoIncrement});

  Map<String, dynamic> toJson() => {
    'name': name,
    'balance': balance,
  };
} 