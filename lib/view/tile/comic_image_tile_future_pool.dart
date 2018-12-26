import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manga4dog/widget/image_loader/FuturePool.dart';
import 'package:manga4dog/widget/image_loader/image_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DemoFuturePoolTile extends StatefulWidget {
  final ComicImage comic;

  //UserItem(this.map);
  DemoFuturePoolTile(this.comic);

  @override
  _DemoFuturePoolTileState createState() => _DemoFuturePoolTileState();
}

class _DemoFuturePoolTileState extends State<DemoFuturePoolTile> with AutomaticKeepAliveClientMixin<DemoFuturePoolTile> {
  bool isLoaded = false;

  Uint8List imageData;

  @override
  void initState() {
    super.initState();
//    print('${widget.comic.id} init image');
    _loadImage();
  }

  _loadImage() {
    spawnImageViaFuture(widget.comic.image).then((data) {
      if (mounted) {
        setState(() {
          imageData = data;
          isLoaded = true;
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build: ${widget.comic.id}');
    return ListTile(
      title: Container(
        child: isLoaded
            ? Image.memory(
                imageData,
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
    print('BBBBBBBBBBBBB');
//    subscription.cancel();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ImageMessage {
  String url;
  Map<String, String> header;
  int retryLimit;
  Duration retryDuration;

  ImageMessage(this.url, {this.header, this.retryLimit, this.retryDuration});
}

Future<Uint8List> loadAsyncImage(String url, String path) async {
  String uId = uid(url);

  try {
    if (/*useDiskCache*/ true) {
      Uint8List _diskCache = await loadFromDiskCache(uId, url, path);
      return _diskCache;
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  Uint8List imageData = await loadFromRemote(url, retryLimit: 5, retryDuration: Duration(milliseconds: 500));
  if (imageData != null) {
    return imageData;
  }

  return emptyImage;
}

Future<Uint8List> spawnImageViaFuture(String url) async {
  Directory _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
  if (!_cacheImagesDirectory.existsSync()) {
    await _cacheImagesDirectory.create();
  }

  return await loadAsyncImage(url, _cacheImagesDirectory.path);

}

Future<Uint8List> loadFromDiskCache(String uId, String url, String path) async {
  File _cacheImageFile = File(join(path, uId));
  if (_cacheImageFile.existsSync()) {
    return await _cacheImageFile.readAsBytes();
  }

  Uint8List imageData = await loadFromRemote(url, retryLimit: 2, retryDuration: Duration(milliseconds: 500));
  if (imageData != null) {
    await (File(join(path, uId))).writeAsBytes(imageData);
    return imageData;
  }

  return emptyImage;
}

Future<Uint8List> loadFromRemote(String url, {Map<String, String> header, int retryLimit, Duration retryDuration}) async {
  Completer<Uint8List> completer = Completer();
  ImageMessage message = ImageMessage(url, header: header, retryLimit: retryLimit, retryDuration: retryDuration);
  FuturePool().addToPool(StreamSubscriptionHandler(uid: url, loadAsync: download, message: message, onSuccess: (data){
    if(data is Uint8List)
      completer.complete(data);
  }));
  return completer.future;
}

Future<Uint8List> download(ImageMessage message) async {
  if (message.retryLimit < 0) message.retryLimit = 0;

  /// Retry mechanism.
  Future<http.Response> run<T>(Future f(), int retryLimit, Duration retryDuration) async {
    for (int t = 0; t < retryLimit + 1; t++) {
      try {
        http.Response res = await f();
        if (res != null) {
          if (res.statusCode == 200)
            return res;
          else
            debugPrint('Load error, response status code: ' + res.statusCode.toString());
        }
      } catch (_) {}
      await Future.delayed(retryDuration);
    }

    if (retryLimit > 0) debugPrint('Retry failed!');
    return null;
  }

  http.Response _response;
  _response = await run(() async {
    if (message.header != null)
      return await http.get(message.url, headers: message.header).timeout(Duration(seconds: 5));
    else
      return await http.get(message.url).timeout(Duration(seconds: 5));
  }, message.retryLimit, message.retryDuration);
  if (_response != null) return _response.bodyBytes;

  return null;
}

String uid(String str) => md5.convert(utf8.encode(str)).toString().toLowerCase().substring(0, 9);
