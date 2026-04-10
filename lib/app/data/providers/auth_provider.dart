import 'package:get/get.dart';
import 'base_provider.dart';
import '../api_constants.dart';

class AuthProvider extends BaseProvider {
  Future<Response> login(String email, String password) => post(
        ApiConstants.login,
        {
          'email': email,
          'password': password,
        },
      );
}
