import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kamon/Features/auth/auth_login/login_resopnse.dart';
import 'package:kamon/Features/auth/auth_login/login_state.dart';
import 'package:kamon/constant.dart';

import '../../../core/errors/failure.dart';

class LoginCubit extends Cubit<LoginState> {
  final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  LoginCubit(this.dio) : super(LoginInitial());

  Future<void> login(String phone, String password) async {
    emit(LoginLoading());
    try {
      final response = await dio.post(
        'https://$baseUrl/admin/auth/customerLogin',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Store the token securely
        await secureStorage.write(key: 'token', value: loginResponse.token);

        // Decode the token and store data securely
        Map<String, dynamic> decodedToken =
            JwtDecoder.decode(loginResponse.token);
        await secureStorage.write(
            key: 'customer_id', value: decodedToken['customer_id'].toString());
        await secureStorage.write(
            key: 'customer_first_name',
            value: decodedToken['customer_first_name']);
        await secureStorage.write(
            key: 'customer_last_name',
            value: decodedToken['customer_last_name']);
        await secureStorage.write(
            key: 'account_id', value: decodedToken['account_id'].toString());
        await secureStorage.write(
            key: 'picture_path', value: decodedToken['picture_path']);

        // Calculate token expiration and store it
        DateTime expirationDate =
            JwtDecoder.getExpirationDate(loginResponse.token);
        await secureStorage.write(
            key: 'token_expiration',
            value: expirationDate.millisecondsSinceEpoch.toString());

        // debugPrint the expiration date
        debugPrint('Token Expiration Date: $expirationDate');

        emit(LoginSuccess(loginResponse));
      } else {
        emit(LoginFailure(
            ServerFailure.fromResponse(response.statusCode, response.data)));
      }
    } on DioException catch (e) {
      emit(LoginFailure(ServerFailure.fromDioError(e)));
    } catch (e) {
      emit(LoginFailure(ServerFailure(e.toString())));
    }
  }
}
