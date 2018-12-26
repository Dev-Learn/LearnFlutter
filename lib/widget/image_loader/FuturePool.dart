import 'dart:async';
import 'dart:collection';

import 'package:synchronized/synchronized.dart';

class FuturePool {

  static final FuturePool _singleton = FuturePool._internal();

  factory FuturePool() => _singleton;

  FuturePool._internal(){
    _lock = new Lock();
    _queue = Queue<StreamSubscriptionHandler>();
    _set = Set<String>();
  }

  Queue<StreamSubscriptionHandler> _queue;
  Set<String> _set;
  Lock _lock;

  final int _limit = 5;
  int _count = 0;

  addToPool<T, M>(StreamSubscriptionHandler<T, M> subscriptionHandler) {
    if (!_set.contains(subscriptionHandler.uid)) {
      _queue.addLast(subscriptionHandler);
      _set.add(subscriptionHandler.uid);
      execute<T, M>();
    }
  }

  execute<T, M>() async {
    bool needWait = await _lock.synchronized(() async {
      if (_count < _limit) {
        _count++;
//        print('current count (after Add): $_count');
        return false;
      } else
        return true;
    });
    if (needWait) return;

    if (_queue.isNotEmpty) {
      StreamSubscriptionHandler<T, M> handler = _queue.removeFirst();
      StreamSubscription<T> subscription = handler.loadAsync(handler.message).asStream().listen(handler.onSuccess);

      subscription.onError((error, stackTrace){
        print('$error');
        print('$stackTrace');
        handler.onError();
      });

      subscription.onDone(() {
//        print("Done");
        _disposeSubscription<T, M>(subscription);
      });
    }
  }

  _disposeSubscription<T, M>(StreamSubscription subscription) async {
    subscription?.cancel();
    await _lock.synchronized(() async {
      _count--;
//      print('current count (after Sub): $_count');
    });
    if (_queue.isNotEmpty) {
      execute<T, M>();
    }
  }
}

typedef Future<T> LoadAsync<T, M>(M message);

class StreamSubscriptionHandler<T, M> {
  final LoadAsync<T, M> loadAsync;
  final Function onSuccess;
  final Function onError;
  final M message;
  final String uid;

  StreamSubscriptionHandler({this.loadAsync, this.onSuccess, this.message, this.uid, this.onError});
}
