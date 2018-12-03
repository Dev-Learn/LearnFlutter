import 'package:data/model/comic/comic.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base/no_scale_factor_text.dart';
import 'dart:core';
import 'dart:ui' as ui show Image;

class ComicTile extends StatefulWidget {

  final Comic comic;

  ComicTile({@required this.comic});

  @override
  _ComicTileState createState() => _ComicTileState();
}

class _ComicTileState extends State<ComicTile> {

  bool isLoaded = false;

  CachedNetworkImageProvider imageProvider;

  ui.Image image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: RawImage(
        image: image,
        fit: BoxFit.fill,
      ),
      title: NoScaleFactorText(widget.comic.title),
      subtitle: NoScaleFactorText(buildGenresString()),
      trailing: Icon(Icons.favorite),

    );
  }

  String buildGenresString(){
    return widget.comic.genres.map((g)=> g.genre).toList().join(' - ');
  }

  _loadImage() {
    imageProvider = CachedNetworkImageProvider(widget.comic.image, scale: 0.4,);
    imageProvider.resolve(ImageConfiguration()).addListener((ImageInfo imageInfo, bool synchronousCal) {
      if (mounted) {
        setState(() {
          image = imageInfo.image;
          isLoaded = true;
        });
      }
    });
  }
}
