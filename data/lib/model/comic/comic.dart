import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:data/model/genre/genre.dart';

part 'comic.jser.dart';

class Comic{

  int id;

  String title;

  String description;

  String image;

  List<Genre> genres;

  Comic();

  Comic.from({
    this.id,
    this.title,
    this.description,
    this.image,
    this.genres,
  });

}
@GenSerializer()
class ComicSerializer extends Serializer<Comic> with _$ComicSerializer {}