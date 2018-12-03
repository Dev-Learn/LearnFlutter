import 'package:data/model/comic/comic.dart';
import 'package:data/repository/comic/comic_api.dart';

class ComicRepo{
  ComicAPI _comicAPI;

  ComicRepo(){
    _comicAPI = ComicAPI();
  }

  Future<List<Comic>> getComics(int after, int limit) {
    return _comicAPI.getComics(after, limit);
  }

}