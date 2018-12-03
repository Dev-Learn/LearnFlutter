import 'package:flutter/material.dart';

import '../observable_life_cycle/observable_life_cycle.dart';

abstract class BaseContract extends LifeCycleOwner {
  void onShowLoading();

  void onHideLoading();

  void onDisplayError(Exception exception,
      {VoidCallback onOk, bool barrierDismissible: true, bool shouldAllowPop});

  void onDisplayErrorWithTryAgain(Exception exception, VoidCallback onTryAgain);

  bool get isMounted;
}
