import 'package:bakryapp/provider/nicu_condition_hive.dart';
import 'package:bakryapp/provider/picu_condition_hive.dart';
import 'package:hive/hive.dart';

part 'drug_monograph_hive.g.dart';

@HiveType(typeId: 0)
class DrugMonograph {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String genericName;
  @HiveField(2)
  String? category;
  @HiveField(3)
  String? aware;
  @HiveField(4)
  final int vialConc;
  @HiveField(5)
  final String finalConc;
  @HiveField(6)
  final int dilution;
  @HiveField(7)
  String? nicuDose;
  @HiveField(8)
  String? unit;
  @HiveField(9)
  String? renalAdjustmentNicu;
  @HiveField(10)
  String? picuAdverseEffect;
  @HiveField(11)
  String? nicuAdverseEffect;
  @HiveField(12)
  String? administration;
  @HiveField(13)
  String? stability;
  @HiveField(14)
  String? csf;
  @HiveField(15)
  List<NICUDoseCondition>? nicuConditions;
  @HiveField(16)
  List<PICUDoseCondition>? picuConditions;

  DrugMonograph({
    required this.id,
    required this.genericName,
    this.category,
    required this.vialConc,
    required this.finalConc,
    required this.dilution,
    this.aware,
    this.nicuDose,
    this.unit,
    this.renalAdjustmentNicu,
    this.picuAdverseEffect,
    this.nicuAdverseEffect,
    this.administration,
    this.stability,
    this.csf,
    this.nicuConditions,
    this.picuConditions,
  });
}
