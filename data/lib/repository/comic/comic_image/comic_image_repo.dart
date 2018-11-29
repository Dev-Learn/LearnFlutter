import 'package:data/model/comic_image/comic_image.dart';

abstract class ComicImageRepo {
  Future<ComicImage> getComicImage(int page, int limit, int idComic);
}