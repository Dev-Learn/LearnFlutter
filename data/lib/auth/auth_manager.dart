import 'dart:async';
import 'dart:convert';

import 'package:data/common/shared_preferences_manager.dart';

import 'package:data/keys.dart';
import 'package:http/http.dart';

class AuthManager {

  AuthManager._internal();

  static final AuthManager _singleton = AuthManager._internal();

  factory AuthManager() => _singleton;

  OauthClient get oauthClient => _oauthClient;
  String get token => _token;

  final Client _client = new Client();

  OauthClient _oauthClient;
  String _token;

  SharedPreferencesManager _prefs;
  SharedPreferencesManager get sharedPreferences => _prefs;

  Future init() async {
     _prefs = await SharedPreferencesManager
        .getInstance();
    _oauthClient = new OauthClient(_client, _prefs.token);
  }

  Future logout() async {
    _prefs.reset();
  }

  Future<bool> _saveTokens(String ownerName, String oauthToken, String password) async {
    _prefs.token = oauthToken;
    _prefs.owner = ownerName;
    _prefs.password = password;
    _token = _prefs.token;
    _oauthClient = new OauthClient(_client, oauthToken);
    return true;
  }

  Future<bool> login(String email, String password, {bool isRemember = false}) async {
    final requestBody = json.encode({
      'email': email,
      'password': password,
    });
    
    final loginResponse = await _client
        .post('$FIVE_URL/login',
        headers: {'Content-Type':'application/json'},
        body: requestBody);
//        .whenComplete(_client.close);

    if (loginResponse.statusCode == 200) {
      final bodyJson = json.decode(loginResponse.body);
      return await _saveTokens(email, bodyJson, isRemember ? password : null);
    }

    return false;
  }

}

class OauthClient extends _AuthClient {
  OauthClient(Client client, String token) : super(client, '$token');
}

abstract class _AuthClient extends BaseClient {
  final Client _client;
  final String _authorization;

  _AuthClient(this._client, this._authorization);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers.putIfAbsent('Content-Type', () => 'application/json');
    request.headers.putIfAbsent('token', () => _authorization);
    return _client.send(request);
  }
}
