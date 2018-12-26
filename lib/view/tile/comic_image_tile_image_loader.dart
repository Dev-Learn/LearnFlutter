import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/widget/image_loader/image_loader.dart';

class DemoImageLoaderTile extends StatefulWidget {
  final ComicImage comic;

  //UserItem(this.map);
  DemoImageLoaderTile(this.comic);

  @override
  _DemoImageLoaderTileState createState() => _DemoImageLoaderTileState();
}

class _DemoImageLoaderTileState extends State<DemoImageLoaderTile> {
  bool isLoaded = false;

  ImageLoaderProvider imageLoader;

  @override
  void initState() {
    super.initState();
    print('${widget.comic.id} init image');
    _loadImage();
  }

  _loadImage() {
    imageLoader = ImageLoaderProvider(widget.comic.image);
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
    print('build: ${widget.comic.id}');
    return ListTile(
      title: Container(
        child: isLoaded
            ? Image(
          image: imageLoader,
          height: 300.0,
          fit: BoxFit.cover,
        )
            : Container(
          height: 300.0,
          child: Stack(
            children: <Widget>[
              Text(
                '${widget.comic.id}',
                style: TextStyle(color: Colors.red),
              ),
              CircularProgressIndicator()
            ],
          ),
          alignment: AlignmentDirectional.center,
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('${widget.comic.id} BBBBBBBBBBBBB');
    super.dispose();
  }

}
