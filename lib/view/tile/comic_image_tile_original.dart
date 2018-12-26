import 'package:cached_network_image/cached_network_image.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';

class ComicImageTile extends StatefulWidget {
  final ComicImage comic;

  //UserItem(this.map);
  ComicImageTile(this.comic);

  @override
  _ComicImageTileState createState() => _ComicImageTileState();
}

class _ComicImageTileState extends State<ComicImageTile> with AutomaticKeepAliveClientMixin<ComicImageTile>{
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    print('${widget.comic.id} init image');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build: ${widget.comic.id}');
    return ListTile(
      title: Container(
        height: 300.0,
        child: CachedNetworkImage(
          imageUrl: widget.comic.image,
          fit: BoxFit.cover,
          placeholder: Container(
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('BBBBBBBBBBBBB');
    super.dispose();
  }

  @override
//  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
