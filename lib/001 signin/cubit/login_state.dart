part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic> userData;

  LoginSuccess(this.userData);
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}

class PasswordResetSent extends LoginState {}
