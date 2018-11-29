// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic_image.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$ComicImageSerializer implements Serializer<ComicImage> {
  @override
  Map<String, dynamic> toMap(ComicImage model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'idComic', model.idComic);
    setMapValue(ret, 'image', model.image);
    return ret;
  }

  @override
  ComicImage fromMap(Map map) {
    if (map == null) return null;
    final obj = new ComicImage();
    obj.id = map['id'] as int;
    obj.idComic = map['idComic'] as int;
    obj.image = map['image'] as String;
    return obj;
  }
}

abstract class _$ComicImageResponseSerializer
    implements Serializer<ComicImageResponse> {
  Serializer<ComicImage> __comicImageSerializer;
  Serializer<ComicImage> get _comicImageSerializer =>
      __comicImageSerializer ??= new ComicImageSerializer();
  @override
  Map<String, dynamic> toMap(ComicImageResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'success', model.success);
    setMapValue(
        ret,
        'result',
        codeIterable(model.result,
            (val) => _comicImageSerializer.toMap(val as ComicImage)));
    return ret;
  }

  @override
  ComicImageResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new ComicImageResponse();
    obj.success = map['success'] as bool;
    obj.result = codeIterable<ComicImage>(map['result'] as Iterable,
        (val) => _comicImageSerializer.fromMap(val as Map));
    return obj;
  }
}

abstract class _$ComicImageRequestSerializer
    implements Serializer<ComicImageRequest> {
  @override
  Map<String, dynamic> toMap(ComicImageRequest model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'idComic', model.idComic);
    return ret;
  }

  @override
  ComicImageRequest fromMap(Map map) {
    if (map == null) return null;
    final obj = new ComicImageRequest();
    obj.idComic = map['idComic'] as int;
    return obj;
  }
}
