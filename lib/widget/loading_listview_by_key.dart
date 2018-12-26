import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/utils/function.dart';

class LoadingListViewByKey<T> extends StatefulWidget {
  final PageRequest<T> pageRequest;

  final WidgetAdapter<T> widgetAdapter;

  final int pageSize;

  final int pageThreshold;

  final bool reverse;

  final int startFrom;

  final GetPageOffset<T> getPageOffset;

  final double cacheExtent;

  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;

  LoadingListViewByKey(this.pageRequest,
      {this.pageSize: 20, this.pageThreshold: 3, @required this.widgetAdapter, this.reverse:
      false, Key key, this.startFrom: 1, this.getPageOffset, this.cacheExtent: 250.0, this.addAutomaticKeepAlives : true, this.addRepaintBoundaries : true})
      : super(key: key);

  @override
  LoadingListViewByKeyState createState() => LoadingListViewByKeyState<T>();
}

class LoadingListViewByKeyState<T> extends State<LoadingListViewByKey<T>> with TickerProviderStateMixin {
  List<T> objects = [];
  Map<int, int> index = {};
  Future request;
  bool isPerformingRequest = true;
  bool isLoadMore = true;
  bool isAnimate = false;
  bool isScroll = false;

  @override
  void initState() {
    super.initState();
    this.lockedLoadNext();
  }

  @override
  Widget build(BuildContext context) {
    print('AAAAAAAAAAAAAAAAAAAAAAA');
    return ListView.builder(
      cacheExtent: widget.cacheExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      itemBuilder: itemBuilder,
      itemCount: objects.length + (isLoadMore ? 1 : 0),
      reverse: widget.reverse,
      physics: ClampingScrollPhysics(),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index + widget.pageThreshold > objects.length) {
      lockedLoadNext();
    }

    if (index == objects.length) return _buildProgressIndicator();

    return widget.widgetAdapter != null ? widget.widgetAdapter(objects[index], index) : new SizedBox();
  }

  Future loadNext() async {
    if (isLoadMore) {
      int page = objects.length == 0 ? 0 : widget.getPageOffset(objects.last);
      List<T> fetched = await widget.pageRequest(page, widget.pageSize);

      if (fetched == null || fetched.length == 0 || fetched.length < widget.pageSize) {
        this.setState(() {
          isLoadMore = false;
        });
      }

      if (mounted) {
        this.setState(() {
          objects.addAll(fetched);
        });
      }
    }
  }

  void lockedLoadNext() {
    if (this.request == null) {
      this.request = loadNext().then((x) {
        this.request = null;
      });
    }
  }

  Future<Null> onRefresh() async {
    this.request?.timeout(const Duration());

    Future<List<T>> fetched = widget.pageRequest(0, widget.pageSize);
    isLoadMore = true;

    fetched.then((value) {
      setState(() {
        objects.clear();
        objects.addAll(value);
      });
    });

    return null;
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoadMore ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

}
