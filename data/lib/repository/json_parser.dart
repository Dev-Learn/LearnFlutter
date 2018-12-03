import 'package:data/model/comic/comic.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:data/model/genre/genre.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

class JsonParser {
  static final JsonParser _singleton = JsonParser._internal();

  factory JsonParser() => _singleton;

  JsonRepo repo;

  JsonParser._internal()
      : repo = JsonRepo()
          ..add(ComicSerializer())
          ..add(ComicImageRequestSerializer())
          ..add(ComicImageResponseSerializer())
          ..add(ComicImageSerializer())
          ..add(GenreSerializer());
}
