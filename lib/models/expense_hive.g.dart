// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseHiveAdapter extends TypeAdapter<ExpenseHive> {
  @override
  final int typeId = 2;

  @override
  ExpenseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseHive(
      category: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
