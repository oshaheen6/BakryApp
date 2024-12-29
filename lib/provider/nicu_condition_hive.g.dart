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
      weight: fields[4] as String?,
      weightCategory: fields[5] as String?,
      dose: fields[6] as int?,
      regimen: fields[7] as int?,
      route: fields[8] as String?,
      administration: fields[9] as String?,
      disease: fields[10] as String?,
      loadingDose: fields[11] as int?,
      maintenanceDose: fields[12] as int?,
      maxDose: fields[13] as int?,
      note: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NICUDoseCondition obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.minGA)
      ..writeByte(1)
      ..write(obj.maxGA)
      ..writeByte(2)
      ..write(obj.minPNA)
      ..writeByte(3)
      ..write(obj.maxPNA)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.weightCategory)
      ..writeByte(6)
      ..write(obj.dose)
      ..writeByte(7)
      ..write(obj.regimen)
      ..writeByte(8)
      ..write(obj.route)
      ..writeByte(9)
      ..write(obj.administration)
      ..writeByte(10)
      ..write(obj.disease)
      ..writeByte(11)
      ..write(obj.loadingDose)
      ..writeByte(12)
      ..write(obj.maintenanceDose)
      ..writeByte(13)
      ..write(obj.maxDose)
      ..writeByte(14)
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
