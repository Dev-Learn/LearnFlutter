import 'dart:convert';
import 'dart:isolate';

import 'package:data/model/comic_image/comic_image.dart';
import 'package:data/model/hi_res_image/hi_res_image.dart';
import 'package:data/model/user/user.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

class JsonParser {
  static final JsonParser _singleton = JsonParser._internal();

  factory JsonParser() => _singleton;

  JsonRepo jsonRepo;

  JsonParser._internal()
      : jsonRepo = JsonRepo()
    ..add(ComicImageSerializer())
    ..add(ComicImageRequestSerializer())
    ..add(ComicImageResponseSerializer())
    ..add(HiResImageSerializer())
    ..add(HiResImageUrlsSerializer())
    ..add(HiresImageResponseSerializer())
    ..add(UserSerializer());
}

Future<List<T>> parseJsonToList<T>(String responseBody) async{

  ReceivePort receive = ReceivePort();

  ParseJsonMessage<T> message = ParseJsonMessage<T>(receive.sendPort, responseBody, JsonType.List);

  Isolate iso = await Isolate.spawn(parseJson, message);

  var result = await receive.first;

  receive.close();
  iso.kill();

  return result;
}

Future<T> parseJsonToSingle<T>(String responseBody) async{

  ReceivePort receive = ReceivePort();

  ParseJsonMessage<T> message = ParseJsonMessage<T>(receive.sendPort, responseBody, JsonType.Single);

  Isolate iso = await Isolate.spawn(parseJson, message);

  var result = await receive.first;

  receive.close();
  iso.kill();

  return result;
}

void parseJson(ParseJsonMessage message){
  var result;
  if(message.type == JsonType.List)
    result = message.parseList(message.body);
  else
    result = message.parseSingle(message.body);
  message.sendPort.send(result);
}

class ParseJsonMessage<T>{
  SendPort sendPort;
  String body;
  JsonType type;

  ParseJsonMessage(this.sendPort, this.body, this.type);

  List<T> parseList(String body){
    List<T> result = JsonParser().jsonRepo.listFrom<T>(json.decode(body));
    return result;
  }

  T parseSingle(String body){
    T result = JsonParser().jsonRepo.oneFrom<T>(json.decode(body));
    return result;
  }
}

enum JsonType{
  Single,
  List
}
