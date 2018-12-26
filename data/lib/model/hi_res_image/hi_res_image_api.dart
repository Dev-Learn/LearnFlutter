import 'dart:convert';

import 'package:data/keys.dart';
import 'package:data/model/hi_res_image/hi_res_image.dart';
import 'package:data/model/json_parser.dart';
import 'package:http/http.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

class HiResImageApi {
  Future<List<HiResImage>> getImages(int page, int limit) async {
    String url = "$UNSPLASH_URL/search?query=background&page=$page&per_page=$limit";

    print(url);
    var client = Client();

    try {
      var rawResponse = await client.get(
          url,
          headers: {'Authorization':'563492ad6f9170000100000191e44bb2f3f94b09bfb71eb3c2ad4aea'}
      ).whenComplete(client.close);

      if (rawResponse.statusCode == 200) {
        HiresImageResponse imageResponse = await parseJsonToSingle<HiresImageResponse>(rawResponse.body);
        return imageResponse.photos;
      }
    } catch (exception) {
      print(exception.toString());
    }
    return null;
  }
}
