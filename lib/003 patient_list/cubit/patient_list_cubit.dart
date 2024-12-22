import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'patient_list_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final FirebaseFirestore firestore;

  PatientCubit({required this.firestore}) : super(PatientInitial());

  Future<void> fetchPatients(String department) async {
    emit(PatientLoading());
    try {
      final patients = await firestore
          .collection('departments')
          .doc(department)
          .collection('patients')
          .where('state', isEqualTo: 'current')
          .get();
      emit(PatientLoaded(patients.docs));
    } catch (e) {
      emit(PatientError('Failed to fetch patients: $e'));
    }
  }

  Future<bool> checkForTpnParameters(
      String department, String patientId) async {
    try {
      final tpnRef = firestore
          .collection('departments')
          .doc(department)
          .collection('patients')
          .doc(patientId)
          .collection('tpnParameters');
      final tpnSnapshot = await tpnRef.get();
      return tpnSnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking TPN parameters: $e');
      }
      return false;
    }
  }
}
