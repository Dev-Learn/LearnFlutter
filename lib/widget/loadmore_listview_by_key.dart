import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef Future<List<T>> PageRequest<T>(int page, int pageSize);
typedef Widget WidgetAdapter<T>(T t, {bool isAnimate});
typedef int GetPageOffset<T>(T t);

class LoadingListViewByKey<T> extends StatefulWidget {
  final PageRequest<T> pageRequest;

  final WidgetAdapter<T> widgetAdapter;

  final int pageSize;

  final int pageThreshold;

  final bool reverse;

  final GetPageOffset<T> getPageOffset;

  final double cacheExtent;

  LoadingListViewByKey(this.pageRequest,
      {@required this.widgetAdapter, @required this.getPageOffset, this.pageSize: 20, this.pageThreshold: 3, this.cacheExtent, this.reverse: false, Key key})
      : super(key: key);

  @override
  LoadingListViewByKeyState createState() => LoadingListViewByKeyState<T>();
}

class LoadingListViewByKeyState<T> extends State<LoadingListViewByKey<T>> with AutomaticKeepAliveClientMixin<LoadingListViewByKey<T>> {
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
    return ListView.builder(
      cacheExtent: widget.cacheExtent,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
      itemBuilder: itemBuilder,
      itemCount: objects.length + (isLoadMore ? 1 : 0),
      reverse: widget.reverse,
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index + widget.pageThreshold > objects.length) {
      lockedLoadNext();
    }

    if (index == objects.length) return _buildProgressIndicator();

    return widget.widgetAdapter != null ? widget.widgetAdapter(objects[index]) : new SizedBox();
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
