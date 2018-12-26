import 'package:data/auth/auth_manager.dart';
import 'package:data/keys.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:data/model/json_parser.dart';
import 'package:http/http.dart';

class ComicApi {
  Future<List<ComicImage>> getComicImages(int page, int limit, int idComic) async {
    String url = "$FIVE_URL/getComicImage/$idComic?after=$page&limit=$limit";

    print(url);
    var client = AuthManager().oauthClient;

    try {
      var response = await client.get(url,).whenComplete(client.close);

      if (response.statusCode == 200) {
        List<ComicImage> future = await parseJsonToList<ComicImage>(response.body);
        return future;
      }
    } catch (exception) {
      print(exception.toString());
      return null;
    }
    return null;
  }
}



