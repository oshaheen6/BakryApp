import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bakryapp/patient_list_screen.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Duration get loginTime => Duration(milliseconds: 2250);

  // Mock method to simulate login delay
  Future<String?> _loginUser(LoginData data) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the Firebase error message
    }
  }

  // Mock method to simulate registration delay
  Future<String?> _registerUser(SignupData data) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the Firebase error message
    }
  }

  // Method for password recovery
  Future<String?> _recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the Firebase error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Bakry App',
      logo: AssetImage('assets/logo.png'), // Optional: Add a logo in assets
      onLogin: _loginUser,
      onSignup: _registerUser,
      onRecoverPassword: _recoverPassword,
      theme: LoginTheme(
        primaryColor: Colors.blueAccent,
        accentColor: Colors.blueAccent,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PatientListScreen(),
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
        recoverPasswordDescription: 'We will send you an email to reset it.',
      ),
    );
  }
}
