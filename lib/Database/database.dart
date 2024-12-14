import 'package:bakryapp/provider/drug_monograph_hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

Future<void> fetchDrugMonographsToHive() async {
  final box = Hive.box('DrugMonograph');

  final querySnapshot =
      await FirebaseFirestore.instance.collection('drug_monographs').get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final awareValue = data['aware'];
    String? aware;
    if (awareValue is String && awareValue.isNotEmpty) {
      aware = awareValue; // Use the value if it's a valid non-empty string
    } else {
      aware = null; // Default to null or handle as required
    }
    final drug = DrugMonograph(
      id: data['id'],
      vialConc: data['vial_conc'],
      finalConc: data['final_conc'],
      dilution: data['dilution'],
      genericName: doc.id,
      category: data['category'],
      aware: aware,
    );
    await box.put(doc.id, drug);
  }
}
