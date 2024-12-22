import 'package:bakryapp/002 department/logic/department_selection_screen.dart';
import 'package:bakryapp/sign-up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../001 SignIn_and_department/cubit/user_cubit.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _loginUser(BuildContext context, LoginData data) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data()!['isApproved'] == true) {
        final userData = userDoc.data()!;

        // Update the UserCubit state
        final userCubit = context.read<UserCubit>();
        userCubit.setUsername(userData['username'] ?? '');
        userCubit.setPermission(userData['permission'] ?? '');
        userCubit.setJobTitle(userData['jobTitle'] ?? '');
        userCubit.setUnits(List<String>.from(userData['unit'] ?? []));

        // Save the updated state to SharedPreferences
        await userCubit.saveUserToPreferences();

        return null; // Successful login
      } else {
        return 'Your account is not approved yet. Please wait for admin approval.';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent the layout from resizing
      body: Stack(
        children: [
          FlutterLogin(
            title: 'Bakry App',
            logo: const AssetImage('assets/images/final 1.png'),
            onLogin: (loginData) => _loginUser(context, loginData),
            onRecoverPassword: _recoverPassword,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => DepartmentSelectionScreen(),
              ));
            },
            messages: LoginMessages(
              userHint: 'Email',
              passwordHint: 'Password',
              confirmPasswordHint: 'Confirm Password',
              loginButton: 'LOGIN',
              signupButton: 'SIGN UP',
              forgotPasswordButton: 'Forgot Password?',
              recoverPasswordButton: 'RECOVER',
              goBackButton: 'BACK',
              recoverPasswordIntro: 'Enter your email to recover your password',
              recoverPasswordDescription:
                  'We will send you an email to reset it.',
            ),
            theme: LoginTheme(
              primaryColor: const Color.fromARGB(255, 142, 236, 200),
              accentColor: Colors.teal,
              buttonTheme: LoginButtonTheme(
                backgroundColor: Colors.green,
                highlightColor: Colors.teal[800],
                splashColor: Colors.tealAccent,
                elevation: 8.0,
              ),
              cardTheme: const CardTheme(
                color: Color.fromARGB(255, 255, 255, 255),
                elevation: 8.0,
                shadowColor: Colors.grey,
              ),
              inputTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[200],
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              textFieldStyle: const TextStyle(
                color: Colors.black,
              ),
              titleStyle: const TextStyle(
                color: Color.fromARGB(255, 12, 73, 10),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              buttonStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ));
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
