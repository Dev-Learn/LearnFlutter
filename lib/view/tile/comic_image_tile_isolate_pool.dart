import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manga4dog/widget/image_loader/isolate_pool.dart';
import 'package:manga4dog/widget/image_loader/image_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DemoIsolatePoolTile extends StatefulWidget {
  final ComicImage comic;

  //UserItem(this.map);
  DemoIsolatePoolTile(this.comic);

  @override
  _DemoIsolatePoolTileState createState() => _DemoIsolatePoolTileState();
}

class _DemoIsolatePoolTileState extends State<DemoIsolatePoolTile> with AutomaticKeepAliveClientMixin<DemoIsolatePoolTile> {
  bool isLoaded = false;

  CachedNetworkImageProvider imageProvider;

  Uint8List imageData;

  @override
  void initState() {
    super.initState();
//    print('${widget.comic.id} init image');
    _loadImage();
  }

  _loadImage() {
    spawnImageViaIsolate(widget.comic.image).then((data) {
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
//    print('build: ${widget.comic.id}');
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
//    print('BBBBBBBBBBBBB');
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class SpawnMessage {
  final String url;
  final String path;
  final SendPort sendPort;

  SpawnMessage(this.url, this.path, this.sendPort);
}

class ImageMessage {
  String url;
  Map<String, String> header;
  int retryLimit;
  Duration retryDuration;
  final SendPort sendPort;

  ImageMessage(this.sendPort, this.url, {this.header, this.retryLimit, this.retryDuration});
}

void spawnImage(SpawnMessage message) {
  loadAsync(message.url, message.path).then((Uint8List imageData) {
    message.sendPort.send(imageData);
  });
}

Future<Uint8List> spawnImageViaIsolate(String url) async {

  Directory _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
  if (!_cacheImagesDirectory.existsSync()) {
    await _cacheImagesDirectory.create();
  }

  return await loadAsync(url, _cacheImagesDirectory.path);
}

Future<Uint8List> loadAsync(url, path) async {
  String uId = uid(url);

  try {
    if (/*useDiskCache*/ true) {
      Uint8List _diskCache = await loadFromDiskCache(uId, url, path);
      return _diskCache;
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  Uint8List imageData = await loadFromRemote(url, retryLimit: 2, retryDuration: Duration(milliseconds: 500));
  if (imageData != null) {
    return imageData;
  }

  return emptyImage;
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
  var receivePort = ReceivePort();

  ImageMessage message = ImageMessage(receivePort.sendPort, url, header: header, retryLimit: retryLimit, retryDuration: retryDuration);
    await IsolatePool().execute<ImageMessage>(download, message);

  var image = await receivePort.first;

  receivePort.close();
  return image;
}

void download(ImageMessage message) async {
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

  run(() async {
    if (message.header != null)
      return await http.get(message.url, headers: message.header).timeout(Duration(seconds: 5));
    else
      return await http.get(message.url).timeout(Duration(seconds: 5));
  }, message.retryLimit, message.retryDuration)
      .then((imageData) {
    message.sendPort.send(imageData.bodyBytes);
  });

}

String uid(String str) => md5.convert(utf8.encode(str)).toString().toLowerCase().substring(0, 9);
