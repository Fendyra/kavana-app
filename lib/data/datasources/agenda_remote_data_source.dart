import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kavana_app/common/logging.dart';
import 'package:kavana_app/core/api.dart';
import 'package:kavana_app/data/models/agenda_model.dart';

class AgendaRemoteDataSource {
  static Future<(bool, String)> add(AgendaModel agenda) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/add.php');
    try {
      final response = await http.post(url, body: agenda.toJsonRequest());
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];
      bool success = response.statusCode == 201;
      return (success, message);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - add',
        e.toString(),
      );
      return (false, 'Something went wrong');
    }
  }

  static Future<(bool, String, List<AgendaModel>?)> all(int userId) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/all.php');
    try {
      final response = await http.post(url, body: {
        'user_id': userId.toString(),
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        Map data = Map.from(resBody['data']);
        List agendasRaw = data['agendas'];
        List<AgendaModel> agendas =
            agendasRaw.map((e) => AgendaModel.fromJson(e)).toList();
        return (true, message, agendas);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - all',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }

  static Future<(bool, String)> delete(int id) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/delete.php?id=$id');
    try {
      final response = await http.get(url);
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];
      bool success = response.statusCode == 200;
      return (success, message);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - delete',
        e.toString(),
      );
      return (false, 'Something went wrong');
    }
  }

  static Future<(bool, String, AgendaModel?)> detail(int id) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/detail.php?id=$id');
    try {
      final response = await http.get(url);
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        Map data = Map.from(resBody['data']);
        Map agendaRaw = data['agenda'];
        AgendaModel agenda = AgendaModel.fromJson(Map.from(agendaRaw));
        return (true, message, agenda);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - detail',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }

  static Future<(bool, String, List<AgendaModel>?)> today(int userId) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/today.php');
    DateTime now = DateTime.now();
    String startDate = DateFormat('yyyy-MM-dd').format(
      DateTime(now.year, now.month, now.day),
    );
    try {
      final response = await http.post(url, body: {
        'user_id': userId.toString(),
        'start_date': startDate,
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        Map data = Map.from(resBody['data']);
        List agendasRaw = data['agendas'];
        List<AgendaModel> agendas =
            agendasRaw.map((e) => AgendaModel.fromJson(e)).toList();
        return (true, message, agendas);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - today',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }

  static Future<(bool, String, List?)> analytic(int userId) async {
    Uri url = Uri.parse('${API.baseURL}/api/agendas/analytic.php');
    DateTime now = DateTime.now();
    String startDate = DateFormat('yyyy-MM-dd').format(
      DateTime(now.year, now.month, 1),
    );
    try {
      final response = await http.post(url, body: {
        'user_id': userId.toString(),
        'start_date': startDate,
      });
      fdLog.response(response);

      final resBody = jsonDecode(response.body);
      String message = resBody['message'];

      if (response.statusCode == 200) {
        List agendas = resBody['data']['agendas'];
        return (true, message, agendas);
      }

      return (false, message, null);
    } catch (e) {
      fdLog.title(
        'AgendaRemoteDataSource - analytic',
        e.toString(),
      );
      return (false, 'Something went wrong', null);
    }
  }
}
