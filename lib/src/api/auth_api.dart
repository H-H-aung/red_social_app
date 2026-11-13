part of '../app.dart';

class AuthApi {
  const AuthApi({this.client = const ApiClient()});
  final ApiClient client;
  Future<ApiResult<Map<String, dynamic>>> login({required String email, required String password}) => client.postForm('auth/login', {'email': email, 'password': password});
  Future<ApiResult<Map<String, dynamic>>> requestSignupCode(String email) => client.postForm('auth/signup/request-code', {'email': email});
  Future<ApiResult<Map<String, dynamic>>> verifySignupCode({required String username, required String email, required String password, required String code}) => client.postForm('auth/signup/verify-code', {'username': username, 'email': email, 'password': password, 'code': code});
  Future<ApiResult<Map<String, dynamic>>> requestForgotCode(String email) => client.postForm('auth/forgot-password/request-code', {'email': email});
  Future<ApiResult<Map<String, dynamic>>> resetPassword({required String email, required String password, required String code}) => client.postForm('auth/forgot-password/reset', {'email': email, 'password': password, 'code': code});
}
