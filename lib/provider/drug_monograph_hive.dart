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

  DrugMonograph(
      {required this.id,
      required this.genericName,
      this.category,
      required this.vialConc,
      required this.finalConc,
      required this.dilution,
      this.aware});
}
