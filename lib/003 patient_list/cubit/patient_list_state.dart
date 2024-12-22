import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PatientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<QueryDocumentSnapshot> patients;

  PatientLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientError extends PatientState {
  final String errorMessage;

  PatientError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
