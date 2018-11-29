// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ComicSerializer implements Serializer<Comic> {
  Serializer<Genre> __genreSerializer;
  Serializer<Genre> get _genreSerializer =>
      __genreSerializer ??= new GenreSerializer();
  @override
  Map<String, dynamic> toMap(Comic model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'title', model.title);
    setMapValue(ret, 'description', model.description);
    setMapValue(ret, 'image', model.image);
    setMapValue(ret, 'genre', _genreSerializer.toMap(model.genre));
    return ret;
  }

  @override
  Comic fromMap(Map map) {
    if (map == null) return null;
    final obj = new Comic();
    obj.id = map['id'] as int;
    obj.title = map['title'] as String;
    obj.description = map['description'] as String;
    obj.image = map['image'] as String;
    obj.genre = _genreSerializer.fromMap(map['genre'] as Map);
    return obj;
  }
}
