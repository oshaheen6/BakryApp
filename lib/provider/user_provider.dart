import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _department;

  String? get username => _username;
  String? get department => _department;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void clearUsername() {
    _username = null;
    notifyListeners();
  }

  void setDepartment(String department) {
    _department = department;
    notifyListeners();
  }

  void clearDepartment() {
    _department = null;
    notifyListeners();
  }
}
