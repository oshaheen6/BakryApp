// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nicu_condition_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NICUDoseConditionAdapter extends TypeAdapter<NICUDoseCondition> {
  @override
  final int typeId = 1;

  @override
  NICUDoseCondition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NICUDoseCondition(
      minGA: fields[0] as int?,
      maxGA: fields[1] as int?,
      minPNA: fields[2] as int?,
      maxPNA: fields[3] as int?,
      minWeight: fields[4] as double?,
      maxWeight: fields[5] as double?,
      weightCategory: fields[6] as String?,
      dose: fields[7] as double?,
      regimen: fields[8] as int?,
      route: fields[9] as String?,
      administration: fields[10] as String?,
      disease: fields[11] as String?,
      loadingDose: fields[12] as int?,
      maintenanceDose: fields[13] as int?,
      maxDose: fields[14] as int?,
      note: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NICUDoseCondition obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.minGA)
      ..writeByte(1)
      ..write(obj.maxGA)
      ..writeByte(2)
      ..write(obj.minPNA)
      ..writeByte(3)
      ..write(obj.maxPNA)
      ..writeByte(4)
      ..write(obj.minWeight)
      ..writeByte(5)
      ..write(obj.maxWeight)
      ..writeByte(6)
      ..write(obj.weightCategory)
      ..writeByte(7)
      ..write(obj.dose)
      ..writeByte(8)
      ..write(obj.regimen)
      ..writeByte(9)
      ..write(obj.route)
      ..writeByte(10)
      ..write(obj.administration)
      ..writeByte(11)
      ..write(obj.disease)
      ..writeByte(12)
      ..write(obj.loadingDose)
      ..writeByte(13)
      ..write(obj.maintenanceDose)
      ..writeByte(14)
      ..write(obj.maxDose)
      ..writeByte(15)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NICUDoseConditionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
