import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the User State
class UserState {
  final String username;
  final String permission;
  final String jobTitle;
  final List<String> units;

  UserState({
    this.username = '',
    this.permission = '',
    this.jobTitle = '',
    this.units = const [],
  });

  UserState copyWith({
    String? username,
    String? permission,
    String? jobTitle,
    List<String>? units,
  }) {
    return UserState(
      username: username ?? this.username,
      permission: permission ?? this.permission,
      jobTitle: jobTitle ?? this.jobTitle,
      units: units ?? this.units,
    );
  }
}

// Define the User Cubit
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState());

  Future<void> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    emit(state.copyWith(
      username: prefs.getString('username') ?? '',
      permission: prefs.getString('permission') ?? '',
      jobTitle: prefs.getString('jobTitle') ?? '',
      units: prefs.getStringList('units') ?? [],
    ));
  }

  Future<void> saveUserToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', state.username);
    await prefs.setString('permission', state.permission);
    await prefs.setString('jobTitle', state.jobTitle);
    await prefs.setStringList('units', state.units);
  }

  void setUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void setPermission(String permission) {
    emit(state.copyWith(permission: permission));
  }

  void setJobTitle(String jobTitle) {
    emit(state.copyWith(jobTitle: jobTitle));
  }

  void setUnits(List<String> units) {
    emit(state.copyWith(units: units));
  }
}
