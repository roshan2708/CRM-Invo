import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_constants.dart';

class BaseProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    
    // Global request modifier to add Authorization header
    httpClient.addRequestModifier<dynamic>((request) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      return request;
    });

    // Global response modifier for error handling (e.g., 401 Unauthorized)
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        // Force logout or refresh token logic can go here
        debugPrint('Unauthorized! Token might be expired.');
      }
      return response;
    });

    super.onInit();
  }
}
