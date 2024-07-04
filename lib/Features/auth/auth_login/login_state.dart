import 'package:kamon/Features/auth/auth_login/login_resopnse.dart';
import 'package:meta/meta.dart';
import '../../../core/errors/failure.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  LoginSuccess(this.loginResponse);
}

class LoginFailure extends LoginState {
  final Failure failure;

  LoginFailure(this.failure);
}
