// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug_monograph_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrugMonographAdapter extends TypeAdapter<DrugMonograph> {
  @override
  final int typeId = 0;

  @override
  DrugMonograph read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrugMonograph(
      id: fields[0] as int,
      genericName: fields[1] as String,
      category: fields[2] as String?,
      vialConc: fields[4] as int,
      finalConc: fields[5] as String,
      dilution: fields[6] as int,
      aware: fields[3] as String?,
      nicuDose: fields[7] as String?,
      renalAdjustmentNicu: fields[8] as String?,
      picuAdverseEffect: fields[9] as String?,
      nicuAdverseEffect: fields[10] as String?,
      administration: fields[11] as String?,
      stability: fields[12] as String?,
      csf: fields[13] as String?,
      nicuConditions: (fields[14] as List?)?.cast<NICUDoseCondition>(),
      picuConditions: (fields[15] as List?)?.cast<PICUDoseCondition>(),
    );
  }

  @override
  void write(BinaryWriter writer, DrugMonograph obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.genericName)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.aware)
      ..writeByte(4)
      ..write(obj.vialConc)
      ..writeByte(5)
      ..write(obj.finalConc)
      ..writeByte(6)
      ..write(obj.dilution)
      ..writeByte(7)
      ..write(obj.nicuDose)
      ..writeByte(8)
      ..write(obj.renalAdjustmentNicu)
      ..writeByte(9)
      ..write(obj.picuAdverseEffect)
      ..writeByte(10)
      ..write(obj.nicuAdverseEffect)
      ..writeByte(11)
      ..write(obj.administration)
      ..writeByte(12)
      ..write(obj.stability)
      ..writeByte(13)
      ..write(obj.csf)
      ..writeByte(14)
      ..write(obj.nicuConditions)
      ..writeByte(15)
      ..write(obj.picuConditions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugMonographAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
