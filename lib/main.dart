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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

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

    // Restore user data into UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _restoreUserProvider(userProvider);

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

  Future<void> _restoreUserProvider(UserProvider userProvider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userProvider.setUsername(prefs.getString('username') ?? '');
    userProvider.setPermission(prefs.getString('permission') ?? '');
    userProvider.setJobTitle(prefs.getString('jobTitle') ?? '');
    userProvider.setUnits(prefs.getStringList('units') ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ),
    );
  }
}
