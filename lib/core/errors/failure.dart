import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');
      case DioExceptionType.badResponse:
        return ServerFailure(
            'Received invalid status code: ${dioError.response?.statusCode}');
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was cancelled');
      case DioExceptionType.connectionError:
        return ServerFailure(
            'Connection to ApiServer failed due to internet connection');
      case DioExceptionType.badCertificate:
        return ServerFailure(
            'Connection to ApiServer failed due to a bad certificate');
      case DioExceptionType.unknown:
      default:
        return ServerFailure('Unknown error occurred: ${dioError.message}');
    }
  }

  // Factory method to create a ServerFailure instance from an HTTP response
  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 422) {
      return ServerFailure(response['message']);
    } else if (statusCode == 404) {
      return ServerFailure(response['error']);
      // return Server Failure ('Your request not found, Please try later!');
    } else if (statusCode == 500) {
      return ServerFailure('Internal Server error, Please try later');
    } else {
      return ServerFailure('Oops There was an Error, Please try again');
    }
  }
}
