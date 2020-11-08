import 'dart:convert';
import 'package:app_final/config/client.dart';
import 'package:http/http.dart';

class HasuraAuth {
  final http = Config.httpClient;

  Future<String> login(String username, String password) async {
    String _token;

    Map credentials = {
      "username": username,
      "password": password,
    };

    Response response = await http
      .post(
        "${Config.apiBaseUrl}/auth/login",
        headers: {"content-type": "application/json"},
        body: jsonEncode(credentials),
      )
      .catchError((onError) {
        print(onError);
        return null;
      });

    if (response == null) {
      return null;
    }

    _token = jsonDecode(response.body)["token"];
    return _token;
  }

  Future<bool> signup(String username, String password) async {
    bool success = false;

    Map credentials = {
      "username": username,
      "password": password,
    };

    Response response = await http
      .post(
        "${Config.apiBaseUrl}/auth/signup",
        headers: {"content-type": "application/json"},
        body: jsonEncode(credentials),
      )
      .catchError((onError) {
        return null;
      });

    if (response == null) {
      return success;
    }

    success = jsonDecode(response.body)["id"] != null;
    return success;
  }
}

HasuraAuth hasuraAuth = new HasuraAuth();
