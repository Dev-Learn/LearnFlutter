// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$GenreSerializer implements Serializer<Genre> {
  @override
  Map<String, dynamic> toMap(Genre model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'genre', model.genre);
    return ret;
  }

  @override
  Genre fromMap(Map map) {
    if (map == null) return null;
    final obj = new Genre();
    obj.id = map['id'] as int;
    obj.genre = map['genre'] as String;
    return obj;
  }
}
