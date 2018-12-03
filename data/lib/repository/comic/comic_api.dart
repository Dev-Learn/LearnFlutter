import 'package:data/auth/auth_manager.dart';
import 'package:data/keys.dart';
import 'package:data/model/comic/comic.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:data/repository/base_api.dart';
import 'package:data/repository/json_parser.dart';

class ComicAPI extends BaseAPI{
  Future<List<Comic>> getComics(int after, int limit) async{
    String url = '$BASE_URL/getComic?after=$after&limit=$limit';
    var rawResponse = await sendRequest(client: AuthManager().oauthClient, method: Method.GET, url: url);
    return JsonParser().repo.listFrom<Comic>(rawResponse);
  }

  Future<List<ComicImage>> getComicImages(int comicId, int after, int limit) async{
    String url = '$BASE_URL/getComicImage/$comicId?after=$after&limit=$limit';
    var rawResponse = await sendRequest(client: AuthManager().oauthClient, method: Method.GET, url: url);
    return JsonParser().repo.listFrom<ComicImage>(rawResponse);
  }
}