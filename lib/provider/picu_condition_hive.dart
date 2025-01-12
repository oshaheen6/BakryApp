import 'package:hive/hive.dart';

part 'picu_condition_hive.g.dart';

@HiveType(typeId: 2)
class PICUDoseCondition {
  @HiveField(0)
  final String? age; // e.g., "3 months - 4 years"
  @HiveField(1)
  final String? weight; // Specific weight (if applicable)
  @HiveField(2)
  final String? weightCategory; // Weight category (e.g., VLBW, LBW)
  @HiveField(3)
  final int? dose; // Dose (mg/kg/dose)
  @HiveField(4)
  final int? regimen; // Frequency (hours)
  @HiveField(5)
  final String? route; // IV, Oral, etc.
  @HiveField(6)
  final String? administration; // Infusion time or method
  @HiveField(7)
  final String? disease; // Specific disease
  @HiveField(8)
  final int? loadingDose; // Loading dose
  @HiveField(9)
  final int? maintenanceDose; // Maintenance dose
  @HiveField(10)
  final int? maxDose; // Maximum dose
  @HiveField(11)
  final String? note; // Extra notes

  PICUDoseCondition({
    this.age,
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
