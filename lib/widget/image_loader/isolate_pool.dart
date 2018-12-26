import 'dart:async';
import 'dart:collection';

import 'dart:isolate';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

class IsolatePool {
  Lock _lock;

  static final IsolatePool _singleton = IsolatePool._internal();

  factory IsolatePool() => _singleton;

  IsolatePool._internal(){
    _lock = new Lock();
    queue = Queue<IsolateHandler>();
  }

  Queue<IsolateHandler> queue;

  final int limit = 5;

  int count = 0;

  execute<T>(Function entryPoint, T message) async {
    ReceivePort exitPort = ReceivePort();
    IsolateHandler<T> isoHandler = IsolateHandler<T>(exitPort: exitPort, entryPoint: entryPoint, message: message);

    queue.add(isoHandler);

    executes<T>();
  }

  executes<T>() async {
    bool needWait = await _lock.synchronized(() async{
      if (count < limit) {
        count++;
        print('current count (after Add): $count');
        return false;
      } else
        return true;
    });
    if(needWait)
      return;

    if (queue.isNotEmpty) {
      IsolateHandler<T> handle = queue.removeLast();
      Isolate iso = await Isolate.spawn<T>(handle.entryPoint, handle.message, paused: true);
      handle.bind(iso);
      handle.exitPort.listen((message) {
        if (message == null) {
          print('stopped');
          _disposeIsolateHandler<T>(handle);
        }
      });
      iso.resume(iso.pauseCapability);
    }
  }

  _disposeIsolateHandler<T>(IsolateHandler<T> isoHandler) async{
    isoHandler.dispose();
    await _lock.synchronized(() async{
      count--;
      print('current count (after Sub): $count');
    });
    if (queue.isNotEmpty) {
      executes<T>();
    }
  }
}

//typedef void EntryPoint<T>(T message);

typedef OnExit = void Function();

class IsolateHandler<T> {
  final ReceivePort exitPort;
  final Function entryPoint;
  final T message;

  Isolate _isolate;

  IsolateHandler({@required ReceivePort exitPort, this.entryPoint, this.message})
      : this.exitPort = exitPort,
        assert(exitPort != null);

  bind(isolate) {
    _isolate = isolate;
    _isolate.addOnExitListener(exitPort.sendPort);
  }

  dispose() {
    _isolate.removeOnExitListener(exitPort.sendPort);
    exitPort.close();
    _isolate.kill();
  }
}
