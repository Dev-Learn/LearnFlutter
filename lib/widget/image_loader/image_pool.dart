import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:isolate/isolate_runner.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class ImagePool {
//  StreamSubscription _disposeCounter;
  IsolateRunner _isolateRunner;
  Lock _lock;

  static final ImagePool _singleton = ImagePool._internal();

  factory ImagePool() => _singleton;

  final int _concurrentLimit = 10;
  int _count = 0;

  ImagePool._internal() {
    _lock = Lock();
    _queue = Queue<ImageHandler>();
    _set = Set<String>();
  }

  Future<void> init() async{
    _isolateRunner = await IsolateRunner.spawn();
    Directory _cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, 'imagecache'));
    if (!_cacheImagesDirectory.existsSync()) {
      await _cacheImagesDirectory.create();
    }
  }

  Queue<ImageHandler> _queue;
  Set<String> _set;

  addToPool<T, U>(ImageHandler<T, U> handler) {
//    _lock.synchronized(() async {
//      if (_disposeCounter != null) {
//        print("CANCEL DISPOSE");
//        _disposeCounter.cancel();
//        _disposeCounter = null;
//      }
//    });
    if (!_set.contains(handler.uid)) {
      _queue.addLast(handler);
      _set.add(handler.uid);
//      print("ENQUEUE: ${handler.uid}");
      _execute<T, U>();
    }
  }

//  createIsolate() async {
//    _isolateRunner = await IsolateRunner.spawn();
//  }

  Future<IsolateRunner> _createIsolate() async {
    return await IsolateRunner.spawn();
  }

  _execute<T, U>() async {
    bool needWait = await _lock.synchronized(() async {
//      if (_isolateRunner == null) _isolateRunner = await _createIsolate();

      if (_count < _concurrentLimit) {
        _count++;
//        print('current count (after Add): $_count');
        return false;
      } else
        return true;
    });
    if (needWait) return;

    if (_queue.isNotEmpty) {
      ImageHandler<T, U> handler = _queue.removeFirst();
//      print('DEQUEUE: ${handler.uid}');

      StreamSubscription subscription = _isolateRunner.run(handler.entryPoint, handler.message).asStream().listen((data) {
        handler.callBack(data);
      });

      subscription.onError((error, stackTrace){
//        print("ERRORRRRRRRRR $error -  $stackTrace");
        handler.callBack(null);
      });

      subscription.onDone(() {
//        print("Done");
        _disposeSubscription<T, U>(subscription);
      });
    }
  }

  _disposeSubscription<T, U>(StreamSubscription subscription) async {
    subscription?.cancel();
    await _lock.synchronized(() async {
      _count--;
//      print('current count (after Sub): $_count');
    });
    if (_queue.isNotEmpty) {
      _execute<T, U>();
    } /*else {
      if (_disposeCounter == null) {
        print('START DISPOSE');
        _disposeCounter = Future.delayed(Duration(seconds: 1)).asStream().listen((_) {
          _disposeIsolate().then((_) {
            print('DISPOSED');
            _disposeCounter = null;
          });
        });
      }
    }*/
  }

  Future<void> _disposeIsolate() async {
    if (_isolateRunner == null)
      return;
    else {
      var alive = await _isolateRunner.ping();
      if (alive) {
        _isolateRunner.close().then((_) {
          _isolateRunner = null;
        });
      }
    }
  }

//  Future<void> dispose() async {
//    if (_isolateRunner == null)
//      return;
//    else {
//      var alive = await _isolateRunner.ping();
//      if (alive) {
//        _isolateRunner.close().then((_) {
//          _isolateRunner = null;
//        });
//      }
//    }
//  }
}

typedef void ImageCallBack<U>(U data);

class ImageHandler<T, U> {
  final String uid;
  final ImageCallBack<U> callBack;
  final Function entryPoint;
  final T message;

  ImageHandler({this.uid, this.callBack, this.entryPoint, this.message});
}

class ImageMessage {
  String url;
  Map<String, String> header;
  File file;
  int retryLimit;
  Duration retryDuration;

  ImageMessage(this.url, this.file, {this.header, this.retryLimit, this.retryDuration});
}

//class ImageData<U> {
//  final String uid;
//
//  final U data;
//
//  ImageData(this.uid, this.data);
//}
