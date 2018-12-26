import 'dart:async';
import 'dart:convert';

import 'package:data/auth/auth_manager.dart';
import 'package:data/keys.dart';
import 'package:data/model/json_parser.dart';
import 'package:data/model/user/user.dart';
import 'package:http/http.dart' as http;
import 'package:jaguar_serializer/jaguar_serializer.dart';
class UserAPI{
//  @override
//  String getBaseUrl() {
//    return 'https://api.github.com/';
//  }
//
//  @override
//  Map<String, String> getHeaders() {
//    return {
//      'Content-Type': 'application/json',
//      'Authorization':
//      'Bearer ${AuthManager.getInstance().token}',
//    };
//  }

//  StreamSubscription fetchUsers(String url, void onData(List<User> photos), void onSubscribe(), Function onError, void onDone()) {
//    return subscribeGet(url, (responseBody) {
//      onData(responseBody.map<User>((map) => new User.fromJson(map)).toList());
//    }, onError: onError, onDone: onDone);
//  }

//  getFollowing(StreamController<User> sc,
//      int pageNumber, int pageSize, String userName) async {
//    userName = 'dutn158';
//    String url =
//        "$BASE_URL/users/$userName/following?page=$pageNumber&per_page=$pageSize";
//
//    var client = AuthManager.getInstance().oauthClient;
//
//    var req = new http.Request('get', Uri.parse(url));
//
//    var streamedRes = await client.send(req);
//
//    streamedRes.stream
//        .transform(utf8.decoder)
//        .transform(json.decoder)
//        .expand((e) => e)
//        .map((map) => User.fromJson(map))
//        .pipe(sc);
//  }

  Future<List<User>> getFollowers(
      int pageNumber, int pageSize) async {
    String userName = 'dutn158';
    String url =
        "$BASE_URL/users/$userName/following?page=$pageNumber&per_page=$pageSize";

    print(url);
    var client =  http.Client();

    try {
      var response = await client.get(url).whenComplete(client.close);

      if (response.statusCode == 200) {
        List<User> future = await parseJsonToList<User>(response.body);
        return future;
      }
    } catch (exception) {
      print(exception.toString());
    }
    return null;
  }
}