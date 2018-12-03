import 'dart:io';

import 'package:base/exception/exceptions.dart';
import 'package:http/http.dart' as http;

class NetworkStatusMixin {

  Future checkOnline() async{
    bool haveConnection = await _connectedWithInternet();
    if (!haveConnection) throw ConnectionException();
  }

  bool responseSuccessful(http.Response response) =>
      response != null && response.statusCode >= 200 && response.statusCode < 300;

  Future<bool> _connectedWithInternet() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}