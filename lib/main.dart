import 'package:bakryapp/department_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:bakryapp/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
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

    // Check if user is logged in by checking SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false; // Default to false if not found
    int? loginTimestamp = prefs.getInt('loginTimestamp');

    if (isLoggedIn && loginTimestamp != null) {
      // Check if the login timestamp is within the allowed period (2 days in milliseconds)
      const int expirationPeriod =
          2 * 24 * 60 * 60 * 1000; // 2 days in milliseconds
      final int currentTime = DateTime.now().millisecondsSinceEpoch;

      // If the time difference is greater than the expiration period, consider login expired
      if ((currentTime - loginTimestamp) > expirationPeriod) {
        prefs.remove('isLoggedIn');
        prefs.remove('loginTimestamp');
        isLoggedIn = false; // Set to false to show the login screen
      }
    }

    // If there's no internet connection and the user has logged in before, go to the DepartmentSelectionScreen
    if (!hasConnection && isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DepartmentSelectionScreen()),
      );
    }
    // If user is logged in, navigate to DepartmentSelectionScreen
    else if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DepartmentSelectionScreen()),
      );
    }
    // If no user is logged in, show the LoginScreen
    else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircularProgressIndicator()), // Show loading while checking
    );
  }
}
