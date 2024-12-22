import 'package:bakryapp/provider/drug_monograph_hive.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'department_selection_state.dart';

class DepartmentSelectionCubit extends Cubit<DepartmentSelectionState> {
  DepartmentSelectionCubit() : super(DepartmentSelectionInitial());

  Future<void> initializeData() async {
    emit(DepartmentSelectionLoading());

    try {
      await syncWithFirestore();
      emit(DepartmentSelectionLoaded());
    } catch (e) {
      emit(DepartmentSelectionError('Failed to sync drug monographs: $e'));
    }
  }

  Future<void> syncWithFirestore() async {
    final drugMonographBox = Hive.box<DrugMonograph>('DrugMonograph');

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('drug_monographs').get();

      // Clear existing data before sync
      await drugMonographBox.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final drug = DrugMonograph(
          id: data['id'] ?? 0,
          vialConc: data['vial_conc'] ?? 0,
          finalConc: data['final_conc'] ?? '',
          dilution: data['dilution'] ?? 0,
          genericName: doc.id,
          category: data['category'],
          aware: _parseAwareValue(data['aware']),
        );
        await drugMonographBox.put(doc.id, drug);
      }
    } catch (e) {
      throw Exception('Firestore sync failed: $e');
    }
  }

  String? _parseAwareValue(dynamic awareValue) {
    return (awareValue is String && awareValue.isNotEmpty) ? awareValue : null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    emit(DepartmentSelectionLoggedOut());
  }
}
