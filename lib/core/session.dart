import 'package:d_session/d_session.dart';
import 'package:kavana_app/data/models/user_model.dart';

class Session {
  static Future<bool> saveUser(Map<String, dynamic> data) async {
    return DSession.setUser(data);
  }

  static Future<UserModel?> getUser() async {
    final data = await DSession.getUser();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  static Future<bool> removeUser() async => DSession.removeUser();
}
