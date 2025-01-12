import "package:bakryapp/login_screen.dart";
import "package:bakryapp/provider/user_provider.dart";
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import "package:shared_preferences/shared_preferences.dart";

Future<void> logout(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  // Clear Provider data
  userProvider.clear();

  // Clear cached data
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Navigate to login screen
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}
