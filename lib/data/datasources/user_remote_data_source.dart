import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kavana_app/common/logging.dart';
import 'package:kavana_app/core/api.dart';
import 'package:kavana_app/data/models/user_model.dart';

class UserRemoteDataSource {
  static Future<(bool, String)> register(
    String name,
    String email,
    String password,
  ) async {
    Uri url = Uri.parse('${API.baseURL}/api/register.php');
    try {
      final response = await http.post(url, body: {
        'name': name,
        'email': email,
        'password': password,
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];
      bool success = response.statusCode == 201;
      return (success, message);
    } catch (e) {
      fdLog.title(
        'UserRemoteDataSource - register',
        e.toString(),
      );
      return (false, 'Something went wrong');
    }
  }

  static Future<(bool, String, UserModel?)> login(
    String email,
    String password,
  ) async {
    Uri url = Uri.parse('${API.baseURL}/api/login.php');
    try {
      final response = await http.post(url, body: {
        'email': email,
        'password': password,
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        final data = resBody['data'];
        final user = UserModel.fromJson(data['user']);
        return (true, message, user);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'UserRemoteDataSource - login',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }

  static Future<(bool, String, UserModel?)> updateProfile({
    required int userId,
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
    File? profilePicture,
  }) async {
    Uri url = Uri.parse('${API.baseURL}/api/update_profile.php');
    try {
      var request = http.MultipartRequest('POST', url);
      
      request.fields['user_id'] = userId.toString();
      
      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }
      
      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }
      
      if (currentPassword != null && currentPassword.isNotEmpty) {
        request.fields['current_password'] = currentPassword;
      }
      
      if (newPassword != null && newPassword.isNotEmpty) {
        request.fields['new_password'] = newPassword;
      }
      
      if (profilePicture != null) {
        var stream = http.ByteStream(profilePicture.openRead());
        var length = await profilePicture.length();
        var multipartFile = http.MultipartFile(
          'profile_picture',
          stream,
          length,
          filename: profilePicture.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        final data = resBody['data'];
        final user = UserModel.fromJson(data['user']);
        return (true, message, user);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'UserRemoteDataSource - updateProfile',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }
}