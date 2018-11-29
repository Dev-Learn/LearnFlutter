import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'genre.jser.dart';

class Genre{

  int id;

  String genre;

  Genre();

  Genre.from({
    this.id,
    this.genre,
  });

}
@GenSerializer()
class GenreSerializer extends Serializer<Genre> with _$GenreSerializer {}