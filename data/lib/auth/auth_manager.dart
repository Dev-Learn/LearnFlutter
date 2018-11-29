import 'dart:async';
import 'dart:convert';

import 'package:data/common/shared_preferences_manager.dart';

import 'keys.dart';
import 'package:http/http.dart';

class AuthManager {

  OauthClient get oauthClient => _oauthClient;
  String get token => _token;

  final Client _client = new Client();

  OauthClient _oauthClient;
  String _token;

  static AuthManager _singleton;

  static AuthManager getInstance() {
    if (_singleton == null) {
      _singleton = new AuthManager._internal();
    }
    return _singleton;
  }

  Future init() async {
    SharedPreferencesManager prefs = await SharedPreferencesManager
        .getInstance();
    _oauthClient = new OauthClient(_client, prefs.token);
  }

  AuthManager._internal();

  Future logout() async {
    SharedPreferencesManager sharedPreferencesManager =
    await SharedPreferencesManager.getInstance();
    sharedPreferencesManager.reset();
  }

  Future<bool> _saveTokens(String ownerName, String oauthToken, String password) async {
    SharedPreferencesManager prefs = await SharedPreferencesManager.getInstance();
    prefs.token = oauthToken;
    prefs.owner = ownerName;
    prefs.password = password;
    _token = prefs.token;
    _oauthClient = new OauthClient(_client, oauthToken);
    return true;
  }

  Future<bool> login(String email, String password, {bool isRemember = false}) async {
    final requestBody = json.encode({
      'email': email,
      'password': password,
    });

    final loginResponse = await _client
        .post('$BASE_URL/login',
        body: requestBody)
        .whenComplete(_client.close);

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
    request.headers['token'] = _authorization;
    return _client.send(request);
  }
}
