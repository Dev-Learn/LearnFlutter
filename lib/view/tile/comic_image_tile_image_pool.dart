import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:data/model/comic_image/comic_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:manga4dog/widget/image_loader/FuturePool.dart';
import 'package:manga4dog/widget/image_loader/image_pool.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DemoImagePoolTile extends StatefulWidget {
  final ComicImage comic;

  //UserItem(this.map);
  DemoImagePoolTile(this.comic);

  @override
  _DemoImagePoolTileState createState() => _DemoImagePoolTileState();
}

class _DemoImagePoolTileState extends State<DemoImagePoolTile>{
  bool isLoaded = false;

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
}

Future<Uint8List> spawnImageViaIsolate(String url) async {
  Directory _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
//    Lock _lock = Lock();
//    await _lock.synchronized(() async{
//      _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
//      if (!_cacheImagesDirectory.existsSync()) {
//        await _cacheImagesDirectory.create();
//      }
//    });

  return await loadAsync(url, _cacheImagesDirectory.path);
}

Future<Uint8List> loadAsync(url, path) async {
  String uId = uid(url);

//  try {
//    if (/*useDiskCache*/ true) {
//      Uint8List _diskCache = await loadFromDiskCache(uId, url, path);
//      return _diskCache;
//    }
//  } catch (e) {
//    debugPrint(e.toString());
//  }
//
//  Uint8List imageData = await loadFromRemote(url, join(path, uId), retryLimit: 2, retryDuration: Duration(milliseconds: 500));
//  if (imageData != null) {
//    return imageData;
//  }
//
//  return emptyImage;
  Uint8List _diskCache = await loadFromDiskCache(uId, url, path);
  return _diskCache;
}

Future<Uint8List> loadFromDiskCache(String uId, String url, String path) async {

  File _cacheImageFile = File(join(path, uId));
  if ( _cacheImageFile.existsSync()) {
    return await _cacheImageFile.readAsBytes();
  } else {
    var success = await loadFromRemote(url, _cacheImageFile, retryLimit: 2, retryDuration: Duration(milliseconds: 500));
    if (success != null && success) {

      Completer<File> completer = Completer();

      FuturePool().addToPool(StreamSubscriptionHandler(uid: uId, loadAsync: compressImage, message: _cacheImageFile.path, onSuccess: (data){
          completer.complete(data);
      }));

      File file = await completer.future;

      return await file.readAsBytes();
    }
  }

  return emptyImage;
}

Future<File> compressImage(String path) async{
  File file  = await FlutterImageCompress.compressAndGetFile(
    path,
    path,
    minHeight: 1500,
    minWidth: 1500,
    quality: 85,
  );

  return file;
}

Future<bool> loadFromRemote(String url, File file, {Map<String, String> header, int retryLimit, Duration retryDuration}) async {
  Completer<bool> completer = Completer();

  ImageMessage message = ImageMessage(url, file, header: header, retryLimit: retryLimit, retryDuration: retryDuration);
  await ImagePool().addToPool<ImageMessage, bool>(
    ImageHandler(
      message: message,
      entryPoint: download,
      uid: url,
      callBack: (success) {
        completer.complete(success);
      },
    ),
  );

  return completer.future;
}

Future<bool> download(ImageMessage message) async {
  if (message.retryLimit < 0) message.retryLimit = 0;

  /// Retry mechanism

  http.Response _response;
//  _response = await run(() async {
//    if (message.header != null)
//      return await http.get(message.url, headers: message.header).timeout(Duration(seconds: 5));
//    else
//      return await http.get(message.url).timeout(Duration(seconds: 5));
//  }, message.retryLimit, message.retryDuration);
  http.Client client = http.Client();
  if (message.header == null)
    message.header = Map();
  print("DEQUEUE: ${message.url}");
  _response = await client.get(message.url, headers: message.header).whenComplete(client.close);
  print("REQUEST END: ${message.url}");

  if (_response != null) {

//    ImageInfo imageInfo = findImageInfo(_response.bodyBytes);
//    if(imageInfo == null || imageInfo.info == null)
//      return false;
//
//    print('width: ${imageInfo.info.width} - height: ${imageInfo.info.height} - ${message.url}');
//
//    if (imageInfo.info.width > MAX_IMAGE_SIZE || imageInfo.info.height > MAX_IMAGE_SIZE) {
//      ImageLib.Image image = imageInfo.decoder.decodeImage(_response.bodyBytes);
//      image = ImageLib.copyResize(image, MAX_IMAGE_SIZE);
//      var encodeImage = ImageLib.encodeJpg(image, quality: 70);
//      await message.file.writeAsBytes(encodeImage);
//      return true;
//    }

    await message.file.writeAsBytes(_response.bodyBytes);
    return true;
  }

  return false;
}

String uid(String str) => md5.convert(utf8.encode(str)).toString().toLowerCase().substring(0, 9);

Uint8List emptyImage = Uint8List.fromList([
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  1,
  115,
  82,
  71,
  66,
  0,
  174,
  206,
  28,
  233,
  0,
  0,
  0,
  4,
  115,
  66,
  73,
  84,
  8,
  8,
  8,
  8,
  124,
  8,
  100,
  136,
  0,
  0,
  0,
  11,
  73,
  68,
  65,
  84,
  8,
  153,
  99,
  248,
  15,
  4,
  0,
  9,
  251,
  3,
  253,
  227,
  85,
  242,
  156,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130
]);