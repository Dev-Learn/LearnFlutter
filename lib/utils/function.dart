import 'dart:async';

import 'package:flutter/material.dart';
typedef Future<List<T>> PageRequest<T> (int page, int pageSize);
typedef Widget WidgetAdapter<T>(T t, int index, {TickerProvider ticker, bool isAnimate});
typedef int Indexer<T>(T t);
typedef GetOverflow(OverflowItem item);
typedef Future<bool> HandleSubmit(/*BuildContext context*/);
typedef int GetPageOffset<T>(T t);

enum OverflowItem {
  Settings,
  LogOut
}

