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
  String? renalAdjustmentNicu;
  @HiveField(9)
  String? picuAdverseEffect;
  @HiveField(10)
  String? nicuAdverseEffect;
  @HiveField(11)
  String? administration;
  @HiveField(12)
  String? stability;
  @HiveField(13)
  String? csf;
  @HiveField(14)
  List<NICUDoseCondition>? nicuConditions;
  @HiveField(15)
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
