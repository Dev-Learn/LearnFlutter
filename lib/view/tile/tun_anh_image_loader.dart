import 'dart:collection';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:synchronized/synchronized.dart';

class TunAnhImageLoader {
  static TunAnhImageLoader _singleton = TunAnhImageLoader._interval();

  factory TunAnhImageLoader() => _singleton;

  TunAnhImageLoader._interval();

  State _state;

  set state(State c) {
    _state = c;
  }

  static const int CACHE_SIZE = 524288000;
  Map<int, MyStreamController> imageCache = HashMap();

  MyStreamController load(String url) {
    int key = url.hashCode;
    MyStreamController streamController = imageCache[key];
    if (streamController == null) {
      print('not cache $url');
      streamController = MyStreamController();
      imageCache[key] = streamController;
      loadFromNetwork(key, url);
    } else {
      print('cached: $url');
    }
    return streamController;
  }

  void loadFromNetwork(int key, String url) {
    CachedNetworkImageProvider loader = CachedNetworkImageProvider(url, scale: 0.4);
    loader.resolve(ImageConfiguration()).addListener((ImageInfo image, bool synchronousCall) async {
      if (_state.mounted) {
        print("loaded");
        MyStreamController streamController = imageCache[key];
        ByteData byte = await image.image.toByteData();
        streamController.size = byte.lengthInBytes;
        print('stream: ${streamController.size}');
        streamController.timeStamp = DateTime.now().millisecondsSinceEpoch;
        handle();
        streamController.add(loader);
      } else {
        print("loading");
      }
    });
  }

  handle() async {
    var lock = new Lock();
    await lock.synchronized(() {
      int n = 0;
      imageCache.values.forEach((value) {
        if (value.size != null) {
          n += value.size;
        }
      });
      if (n > CACHE_SIZE) {
        release(n - CACHE_SIZE);
      }
    });
  }

  release(int mustReleaseSize) {
    int released = 0;
    print('RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
    while (released < mustReleaseSize) {

      var list = [];

      imageCache.forEach(
        (key, value) {
          if (value.size != null) {
            int size = value.size;
            released += size;
            if(released < mustReleaseSize){
              list.add(key);
            }
          }
        },
      );

      list.forEach((k) {
        imageCache[k].dispose();
        imageCache.remove(k);
      });
    }
  }
}

abstract class ImageSubscriber {
  void imageLoaded(CachedNetworkImageProvider image);
}

class MyConfig extends ImageConfiguration {}

class MyStreamController {
  StreamController<CachedNetworkImageProvider> controller = StreamController.broadcast();

  int size;

  int timeStamp;

  void add(CachedNetworkImageProvider provider) {
    controller.sink.add(provider);
  }

  void dispose(){
    controller.close();
  }
}
