// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picu_condition_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PICUDoseConditionAdapter extends TypeAdapter<PICUDoseCondition> {
  @override
  final int typeId = 2;

  @override
  PICUDoseCondition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PICUDoseCondition(
      age: fields[0] as String?,
      weight: fields[1] as String?,
      weightCategory: fields[2] as String?,
      dose: fields[3] as int?,
      regimen: fields[4] as int?,
      route: fields[5] as String?,
      administration: fields[6] as String?,
      disease: fields[7] as String?,
      loadingDose: fields[8] as int?,
      maintenanceDose: fields[9] as int?,
      maxDose: fields[10] as int?,
      note: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PICUDoseCondition obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.age)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.weightCategory)
      ..writeByte(3)
      ..write(obj.dose)
      ..writeByte(4)
      ..write(obj.regimen)
      ..writeByte(5)
      ..write(obj.route)
      ..writeByte(6)
      ..write(obj.administration)
      ..writeByte(7)
      ..write(obj.disease)
      ..writeByte(8)
      ..write(obj.loadingDose)
      ..writeByte(9)
      ..write(obj.maintenanceDose)
      ..writeByte(10)
      ..write(obj.maxDose)
      ..writeByte(11)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PICUDoseConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
