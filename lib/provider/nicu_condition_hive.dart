import 'package:hive/hive.dart';

part 'nicu_condition_hive.g.dart';

@HiveType(typeId: 1)
class NICUDoseCondition {
  @HiveField(0)
  final int? minGA; // Minimum gestational age (weeks)
  @HiveField(1)
  final int? maxGA; // Maximum gestational age (weeks)
  @HiveField(2)
  final int? minPNA; // Minimum postnatal age (days)
  @HiveField(3)
  final int? maxPNA; // Maximum postnatal age (days)
  @HiveField(4)
  final String? weight; // Specific weight (if applicable)
  @HiveField(5)
  final String? weightCategory; // Weight category (e.g., VLBW, LBW)
  @HiveField(6)
  final int? dose; // Dose (mg/kg/dose)
  @HiveField(7)
  final int? regimen; // Frequency (hours)
  @HiveField(8)
  final String? route; // IV, Oral, etc.
  @HiveField(9)
  final String? administration; // Infusion time or method
  @HiveField(10)
  final String? disease; // Specific disease
  @HiveField(11)
  final int? loadingDose; // Loading dose
  @HiveField(12)
  final int? maintenanceDose; // Maintenance dose
  @HiveField(13)
  final int? maxDose; // Maximum dose
  @HiveField(14)
  final String? note; // Extra notes

  NICUDoseCondition({
    this.minGA,
    this.maxGA,
    this.minPNA,
    this.maxPNA,
    this.weight,
    this.weightCategory,
    this.dose,
    this.regimen,
    this.route,
    this.administration,
    this.disease,
    this.loadingDose,
    this.maintenanceDose,
    this.maxDose,
    this.note,
  });
}
