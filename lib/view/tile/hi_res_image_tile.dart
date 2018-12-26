import 'package:data/model/hi_res_image/hi_res_image.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/widget/image_loader/image_loader.dart';

class HiResImageTile extends StatefulWidget {
  final HiResImage image;

  //UserItem(this.map);
  HiResImageTile(this.image);

  @override
  _HiResImageTileState createState() => _HiResImageTileState();
}

class _HiResImageTileState extends State<HiResImageTile> {
  bool isLoaded = false;

  ImageLoaderProvider imageLoader;

  @override
  void initState() {
    super.initState();
//    print('${widget.comic.id} init image');
    _loadImage();
  }

  _loadImage() {
    imageLoader = ImageLoaderProvider(widget.image.src.original);
    imageLoader.resolve(new ImageConfiguration()).addListener((_, __) {
      if (mounted) {
        setState(() {
          isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
//    print('build: ${widget.comic.id}');
    return ListTile(
      title: Container(
        child: isLoaded
            ? Image(
          image: imageLoader,
          height: 300.0,
          fit: BoxFit.cover,
        )
            : Container(
          color: Colors.green,
          height: 300.0,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Text(
                '${widget.image.id}',
                style: TextStyle(color: Colors.red),
              ),
              CircularProgressIndicator()
            ],
          ),
          alignment: AlignmentDirectional.center,
        ),
      ),
    );
//    return ListTile(
//      title: Container(
//        height: 300.0,
//        child: ImageLoader(
//          imageUrl: widget.image.src.original,
//          fit: BoxFit.cover,
//          placeholder: Container(
//            alignment: AlignmentDirectional.center,
//            child: CircularProgressIndicator(),
//          ),
//        ),
//      ),
//    );
  }

  @override
  void dispose() {
    print('BBBBBBBBBBBBB');
    super.dispose();
  }

}