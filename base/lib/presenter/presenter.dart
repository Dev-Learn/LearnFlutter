
import 'dart:async';

import 'package:base/observable_life_cycle/observable_life_cycle.dart';
import 'package:meta/meta.dart';

abstract class Presenter<V extends LifeCycleOwner> implements LifeCycleObserver {
  V view;

  List<StreamSubscription> streamSubscriptions = [];

  Presenter(V v) {
    view = v;
    view?.lifeCycle?.addObserver(this);
  }

  @override
  void onInitState() {}

  @override
  void onDispose() {
    streamSubscriptions.forEach((subscription) => subscription.cancel());
    streamSubscriptions.clear();
    view?.lifeCycle?.removeObserver(this);
    view = null;
  }

  @protected
  void addSubscription<T>(Stream<T> stream,
      {Function onStart,
      Function onSuccess,
      Function onError,
      Function onDone,
      bool cancelOnError: false}) {
    if (onStart != null) onStart();
    StreamSubscription<T> subscription = stream.listen(onSuccess, cancelOnError: cancelOnError);
    streamSubscriptions.add(subscription);
    subscription.onError(onError);
    subscription.onDone(() {
      streamSubscriptions.remove(subscription);
      if (onDone != null) onDone();
    });
  }
}
