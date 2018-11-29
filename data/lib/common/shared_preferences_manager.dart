import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  static const String KEY_OWNER_NAME = 'KEY_OWNER_NAME';
  static const String KEY_OAUTH_TOKEN = 'KEY_AUTH_TOKEN';
  static const String KEY_PASSWORD = 'KEY_PASSWORD';

  static SharedPreferencesManager _singleton;

  static SharedPreferences _sharedPreferences;

  SharedPreferencesManager._internal();

  static Future<SharedPreferencesManager> getInstance() async {
    if (_singleton == null) {
      _singleton = new SharedPreferencesManager._internal();
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _singleton;
  }

  set owner(String owner) {
    _sharedPreferences.setString(KEY_OWNER_NAME, owner);
  }

  String get owner => _sharedPreferences.getString(KEY_OWNER_NAME);

  set token(String token) {
    _sharedPreferences.setString(KEY_OAUTH_TOKEN, token);
  }

  String get token => _sharedPreferences.getString(KEY_OAUTH_TOKEN);

  set password(String password) {
    _sharedPreferences.setString(KEY_PASSWORD, password);
  }

  String get password => _sharedPreferences.getString(KEY_PASSWORD);

  bool get isRemember => password != null && password.isNotEmpty;

  bool get loggedIn => token != null;

  void reset() {
    _sharedPreferences.clear();
  }
}
