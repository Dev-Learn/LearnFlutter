import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'comic_image.jser.dart';

class ComicImage{

  int id;

  int idComic;

  String image;

  ComicImage();

  ComicImage.from({
    this.id,
    this.image,
    this.idComic
});

}
@GenSerializer()
class ComicImageSerializer extends Serializer<ComicImage> with _$ComicImageSerializer {}

class ComicImageResponse{

  ComicImageResponse();

  ComicImageResponse.from({this.result, this.success});

  bool success;

  List<ComicImage> result;

}
@GenSerializer()
class ComicImageResponseSerializer extends Serializer<ComicImageResponse> with _$ComicImageResponseSerializer {}

class ComicImageRequest{

  ComicImageRequest();

  ComicImageRequest.from(this.idComic);

 int idComic;

}
@GenSerializer()
class ComicImageRequestSerializer extends Serializer<ComicImageRequest> with _$ComicImageRequestSerializer {}
