part of '../app.dart';

class AccountApi {
  const AccountApi({this.client = const ApiClient()});
  final ApiClient client;
  Future<ApiResult<AppUser>> profile() async {
    final result = await client.get('account/profile');
    final data = result.data?['data'];
    final user = data is Map<String, dynamic>
        ? AppUser.fromJson(data).copyWith(token: UserSession.user?.token)
        : UserSession.user;
    return ApiResult(
      success: result.success,
      message: result.message,
      data: user,
      statusCode: result.statusCode,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> updateProfile({
    required String username,
    required String phone,
  }) => client.postForm('account/profile', {
    'username': username,
    'phone': phone,
  });
  Future<ApiResult<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => client.postForm('account/change-password', {
    'current_password': currentPassword,
    'new_password': newPassword,
  });
}
