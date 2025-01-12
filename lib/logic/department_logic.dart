import 'package:bakryapp/provider/drug_monograph_hive.dart';
import 'package:bakryapp/provider/nicu_condition_hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DepartmentLogic {
  static Future<void> syncWithFirestore(
      Box<DrugMonograph> drugMonographBox) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('drug_monographs').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final nicuConditions = <NICUDoseCondition>[];
        for (var i = 1; i <= 12; i++) {
          final conditionKey = 'NICU_condition_$i';
          if (data.containsKey(conditionKey)) {
            final conditionString = data[conditionKey] as String?;

            if (conditionString != null && conditionString.isNotEmpty) {
              final conditionData = conditionString
                  .split(';')
                  .fold<Map<String, String>>({}, (map, field) {
                final keyValue = field.split(':').map((e) => e.trim()).toList();
                if (keyValue.length == 2 && keyValue[1].isNotEmpty) {
                  map[keyValue[0]] = keyValue[1];
                }
                return map;
              });

              final condition = NICUDoseCondition(
                minGA: _parseRangeValue(conditionData['GA'], 0),
                maxGA: _parseRangeValue(conditionData['GA'], 1),
                minPNA: _parseRangeValue(conditionData['PNA'], 0),
                maxPNA: _parseRangeValue(conditionData['PNA'], 1),
                minWeight: _parseDoubleRangeValue(conditionData['Weight'], 0),
                maxWeight: _parseDoubleRangeValue(conditionData['Weight'], 1),
                weightCategory: conditionData['WeightCategory'],
                dose: _parseDoubleRangeValue(conditionData['Dose'], 0),
                regimen: int.tryParse(conditionData['Regimen'] ?? ''),
                route: conditionData['Route'],
                administration: conditionData['Administration'],
                disease: conditionData['Disease'],
                loadingDose: int.tryParse(conditionData['LD'] ?? ''),
                maintenanceDose: int.tryParse(conditionData['MD'] ?? ''),
                maxDose: int.tryParse(conditionData['MaxDose'] ?? ''),
                note: conditionData['Note'],
              );

              nicuConditions.add(condition);
            }
          }
        }

        // Create a DrugMonograph object and store it in Hive
        final drug = DrugMonograph(
          id: data['id'] ?? 0,
          vialConc: data['vial_conc'] ?? 0,
          finalConc: data['final_conc'] ?? '',
          dilution: data['dilution'] ?? 0,
          genericName: doc.id,
          category: data['category'],
          aware: _parseAwareValue(data['aware']),
          nicuDose: data['NICU_dose'],
          unit: data['unit'],
          renalAdjustmentNicu: data['renal_adjustment_NICU'],
          picuAdverseEffect: data['PICU_adverse_effect'],
          nicuAdverseEffect: data['NICU_adverse_effect'],
          administration: data['Administration'],
          stability: data['Stability'],
          csf: data['CSF'],
          nicuConditions: nicuConditions,
        );

        await drugMonographBox.put(doc.id, drug);
      }
    } catch (e) {
      throw Exception('Firestore sync failed: $e');
    }
  }

  // Helper functions
  static int? _parseRangeValue(String? range, int index) {
    if (range == null || range.isEmpty) return null;
    final parts = range.split('-');
    if (parts.length > index) {
      return int.tryParse(parts[index].trim());
    }
    return null;
  }

  static double? _parseDoubleRangeValue(String? range, int index) {
    if (range == null || range.isEmpty) return null;
    final parts = range.split('-');
    if (parts.length > index) {
      return double.tryParse(parts[index].trim());
    }
    return null;
  }

  static String? _parseAwareValue(dynamic awareValue) {
    return (awareValue is String && awareValue.isNotEmpty) ? awareValue : null;
  }

  // Generate a daily passcode and store it in Firestore
  static Future<String?> getDailyPasscode() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final docRef = firestore.collection('dailyPasscodes').doc(today);

    final doc = await docRef.get();
    if (doc.exists) {
      return doc.data()!['passcode'];
    } else {
      // Generate a new passcode
      final passcode =
          (100 + Random().nextInt(900)).toString(); // Random 3-digit code

      // Set expiration time to 2 PM the next day
      final now = DateTime.now();
      final nextDay2PM =
          DateTime(now.year, now.month, now.day + 1, 14, 0); // 2 PM next day

      // Save passcode and expiration time in Firestore
      await docRef.set({
        'passcode': passcode,
        'expirationTime': nextDay2PM.toIso8601String(),
      });

      return passcode;
    }
  }

  // Check if the entered passcode is valid
  static Future<bool> isPasscodeValid(String enteredPasscode) async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final docRef = firestore.collection('dailyPasscodes').doc(today);

    final doc = await docRef.get();
    if (doc.exists) {
      final storedPasscode = doc.data()!['passcode'];
      final expirationTime = DateTime.parse(doc.data()!['expirationTime']);

      // Check if the passcode matches and the current time is before expiration
      return enteredPasscode == storedPasscode &&
          DateTime.now().isBefore(expirationTime);
    }
    return false;
  }

  // Save physician's access state
  static Future<void> savePhysicianAccess(bool hasAccess) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('physicianAccess', hasAccess);
  }

  // Get physician's access state
  static Future<bool> getPhysicianAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('physicianAccess') ?? false;
  }

  // Reset physician access if expired
  static Future<void> resetPhysicianAccessIfExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccessTime = prefs.getString('lastAccessTime');
    if (lastAccessTime != null) {
      final expirationTime = DateTime.parse(lastAccessTime);
      if (DateTime.now().isAfter(expirationTime)) {
        await prefs.setBool('physicianAccess', false);
      }
    }
  }
}
