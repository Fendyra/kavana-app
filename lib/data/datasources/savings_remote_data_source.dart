import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kavana_app/common/logging.dart';
import 'package:kavana_app/core/api.dart';
import 'package:kavana_app/data/models/savings_model.dart';

class SavingsRemoteDataSource {
  static Future<(bool, String)> add(SavingsModel savings) async {
    Uri url = Uri.parse('${API.baseURL}/api/savings/add.php');
    try {
      final response = await http.post(url, body: savings.toJsonRequest());
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];
      bool success = response.statusCode == 201;
      return (success, message);
    } catch (e) {
      fdLog.title('SavingsRemoteDataSource - add', e.toString());
      return (false, 'Something went wrong');
    }
  }

  static Future<(bool, String, Map?)> getSavingsSummary(int userId) async {
    Uri url = Uri.parse('${API.baseURL}/api/savings/summary.php');
    try {
      final response = await http.post(url, body: {
        'user_id': userId.toString(),
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        Map data = Map.from(resBody['data']);
        List recentSavingsRaw = data['recent_savings'] ?? [];
        List<SavingsModel> recentSavings =
            recentSavingsRaw.map((e) => SavingsModel.fromJson(e)).toList();

        return (
          true,
          message,
          {
            'total_savings': double.parse(data['total_savings'].toString()),
            'monthly_total': double.parse(data['monthly_total'].toString()),
            'savings_days': int.parse(data['savings_days'].toString()),
            'recent_savings': recentSavings,
          }
        );
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title('SavingsRemoteDataSource - getSavingsSummary', e.toString());
      return (false, 'Something went wrong', null);
    }
  }

  static Future<(bool, String, List<SavingsModel>?)> getHistory(
      int userId) async {
    Uri url = Uri.parse('${API.baseURL}/api/savings/history.php');
    try {
      final response = await http.post(url, body: {
        'user_id': userId.toString(),
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        Map data = Map.from(resBody['data']);
        List savingsRaw = data['savings'];
        List<SavingsModel> savings =
            savingsRaw.map((e) => SavingsModel.fromJson(e)).toList();
        return (true, message, savings);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title('SavingsRemoteDataSource - getHistory', e.toString());
      return (false, 'Something went wrong', null);
    }
  }
}