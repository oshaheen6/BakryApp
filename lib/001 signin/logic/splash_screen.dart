import 'package:bakryapp/department_screen.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/user_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLogin();
  }

  Future<void> _checkConnectivityAndLogin() async {
    // Check network connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;

    // Access SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userCubit = context.read<UserCubit>();
    await userCubit.loadUserFromPreferences();

    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    int? loginTimestamp = prefs.getInt('loginTimestamp');

    if (isLoggedIn && loginTimestamp != null) {
      // Check if login is still valid (2 days in milliseconds)
      const int expirationPeriod = 2 * 24 * 60 * 60 * 1000;
      final int currentTime = DateTime.now().millisecondsSinceEpoch;

      if ((currentTime - loginTimestamp) > expirationPeriod) {
        prefs.remove('isLoggedIn');
        prefs.remove('loginTimestamp');
        isLoggedIn = false; // Mark login as expired
      }
    }

    // Navigate based on login state and connectivity
    if (!hasConnection && isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DepartmentSelectionScreen()),
      );
    } else if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DepartmentSelectionScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
