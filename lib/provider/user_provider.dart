import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _department;
  String? _permission;
  String? _jobTitle;
  List<String>? _units;

  String? get username => _username;
  String? get department => _department;
  String? get permission => _permission;
  String? get jobTitle => _jobTitle;
  List<String>? get units => _units;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPermission(String permission) {
    _permission = permission;
    notifyListeners();
  }

  void setJobTitle(String jobTitle) {
    _jobTitle = jobTitle;
    notifyListeners();
  }

  void setUnits(List<String> units) {
    _units = units;
    notifyListeners();
  }

  void setDepartment(String department) {
    _department = department;
    notifyListeners();
  }

  void clear() {
    _username = null;
    _department = null;
    _permission = null;
    _jobTitle = null;
    _units = null;
    notifyListeners();
  }
}
