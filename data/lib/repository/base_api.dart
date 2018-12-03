import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:base/exception/exceptions.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:base/network/network_status_mixin.dart';

enum Method { GET, POST, PUT, DELETE, PATCH }

class BaseAPI with NetworkStatusMixin{
  @protected
  Future<dynamic> sendRequest({@required http.Client client, @required Method method, @required String url, Map<String, dynamic> body}) async {
    await checkOnline();
    http.Response rawResponse = await _send(client, method, url, body).catchError((e, stackTrace) {
      throw e;
    });
    if (_responseSuccessful(rawResponse)) {
      if (rawResponse.body == null || rawResponse.body.isEmpty) return null;
      return json.decode(rawResponse.body);
    } else {
      throw HandledHttpException(rawResponse.statusCode, json.decode(rawResponse.body));
    }
  }

  Future<http.Response> _send(http.Client client, Method method, String url, Map<String, dynamic> body) async {
    assert(() {
      print("$method --> $url");
      if (body != null) print("BODY: $body");
      return true;
    }());
    http.Response response;
    Future<http.Response> responseFuture;
    switch (method) {
      case Method.POST:
        responseFuture = client.post(url, body: body);
        break;
      case Method.PUT:
        responseFuture = client.put(url, body: body);
        break;
      case Method.PATCH:
        responseFuture = client.patch(url, body: body);
        break;
      case Method.DELETE:
        responseFuture = client.delete(url);
        break;
      default:
        responseFuture = client.get(url);
        break;
    }
    response = await responseFuture.catchError((e, stackTrace) {
      print('error: $e - $stackTrace');
      throw SocketException.closed();
    }).timeout(Duration(seconds: 15), onTimeout: () {
      throw TimeoutException("");
    });
    assert(() {
      print("${response.statusCode} <-- $url");
      print("RESPONSE: ${response.body}");
      return true;
    }());
    if (response.statusCode == 401) {
      throw Exception('401');
    }
    return response;
  }

  bool _responseSuccessful(http.Response response) =>
      response != null && response.statusCode >= 200 && response.statusCode < 300;

}