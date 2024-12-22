part of 'department_selection_cubit.dart';

abstract class DepartmentSelectionState {}

class DepartmentSelectionInitial extends DepartmentSelectionState {}

class DepartmentSelectionLoading extends DepartmentSelectionState {}

class DepartmentSelectionLoaded extends DepartmentSelectionState {}

class DepartmentSelectionError extends DepartmentSelectionState {
  final String message;

  DepartmentSelectionError(this.message);
}

class DepartmentSelectionLoggedOut extends DepartmentSelectionState {}
