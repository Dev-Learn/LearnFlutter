import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'package:data/model/hi_res_image/hi_res_image.jser.dart';

class HiResImage{
  int id;
  int width;
  int height;
  HiResImageUrls src;
}
@GenSerializer()
class HiResImageSerializer extends Serializer<HiResImage> with _$HiResImageSerializer {}

class HiResImageUrls{
  String original;
  String large;
  String medium;
  String small;
  String tiny;
}
@GenSerializer()
class HiResImageUrlsSerializer extends Serializer<HiResImageUrls> with _$HiResImageUrlsSerializer {}

class HiresImageResponse{
  int totalResults;
  int page;
  int perPage;
  List<HiResImage> photos;
}
@GenSerializer(fields: {
  'totalResults': Alias('total_results'),
  'perPage': Alias('per_page'),
})
class HiresImageResponseSerializer extends Serializer<HiresImageResponse> with _$HiresImageResponseSerializer {}