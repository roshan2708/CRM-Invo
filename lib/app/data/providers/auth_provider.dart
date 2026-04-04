import 'package:get/get.dart';
import '../api_constants.dart';
import '../models/user_model.dart';

class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    super.onInit();
  }

  Future<Response> login(String email, String password) => post(
        ApiConstants.login,
        {
          'email': email,
          'password': password,
        },
      );
}
