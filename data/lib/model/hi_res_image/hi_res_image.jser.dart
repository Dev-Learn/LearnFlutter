// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hi_res_image.dart';

// **************************************************************************
// JaguarSerializerGenerator
// **************************************************************************

abstract class _$HiResImageSerializer implements Serializer<HiResImage> {
  Serializer<HiResImageUrls> __hiResImageUrlsSerializer;
  Serializer<HiResImageUrls> get _hiResImageUrlsSerializer =>
      __hiResImageUrlsSerializer ??= new HiResImageUrlsSerializer();
  @override
  Map<String, dynamic> toMap(HiResImage model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'id', model.id);
    setMapValue(ret, 'width', model.width);
    setMapValue(ret, 'height', model.height);
    setMapValue(ret, 'src', _hiResImageUrlsSerializer.toMap(model.src));
    return ret;
  }

  @override
  HiResImage fromMap(Map map) {
    if (map == null) return null;
    final obj = new HiResImage();
    obj.id = map['id'] as int;
    obj.width = map['width'] as int;
    obj.height = map['height'] as int;
    obj.src = _hiResImageUrlsSerializer.fromMap(map['src'] as Map);
    return obj;
  }
}

abstract class _$HiResImageUrlsSerializer
    implements Serializer<HiResImageUrls> {
  @override
  Map<String, dynamic> toMap(HiResImageUrls model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'original', model.original);
    setMapValue(ret, 'large', model.large);
    setMapValue(ret, 'medium', model.medium);
    setMapValue(ret, 'small', model.small);
    setMapValue(ret, 'tiny', model.tiny);
    return ret;
  }

  @override
  HiResImageUrls fromMap(Map map) {
    if (map == null) return null;
    final obj = new HiResImageUrls();
    obj.original = map['original'] as String;
    obj.large = map['large'] as String;
    obj.medium = map['medium'] as String;
    obj.small = map['small'] as String;
    obj.tiny = map['tiny'] as String;
    return obj;
  }
}

abstract class _$HiresImageResponseSerializer
    implements Serializer<HiresImageResponse> {
  Serializer<HiResImage> __hiResImageSerializer;
  Serializer<HiResImage> get _hiResImageSerializer =>
      __hiResImageSerializer ??= new HiResImageSerializer();
  @override
  Map<String, dynamic> toMap(HiresImageResponse model) {
    if (model == null) return null;
    Map<String, dynamic> ret = <String, dynamic>{};
    setMapValue(ret, 'total_results', model.totalResults);
    setMapValue(ret, 'page', model.page);
    setMapValue(ret, 'per_page', model.perPage);
    setMapValue(
        ret,
        'photos',
        codeIterable(model.photos,
            (val) => _hiResImageSerializer.toMap(val as HiResImage)));
    return ret;
  }

  @override
  HiresImageResponse fromMap(Map map) {
    if (map == null) return null;
    final obj = new HiresImageResponse();
    obj.totalResults = map['total_results'] as int;
    obj.page = map['page'] as int;
    obj.perPage = map['per_page'] as int;
    obj.photos = codeIterable<HiResImage>(map['photos'] as Iterable,
        (val) => _hiResImageSerializer.fromMap(val as Map));
    return obj;
  }
}
