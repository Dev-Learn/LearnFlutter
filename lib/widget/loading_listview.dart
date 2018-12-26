import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/utils/function.dart';
import 'dart:math' as math;

class LoadingListView<T> extends StatefulWidget {
  final PageRequest<T> pageRequest;

  final WidgetAdapter<T> widgetAdapter;

  final int pageSize;

  final int pageThreshold;

  final bool reverse;

  final int startFrom;

  final double cacheExtent;

  final bool addAutomaticKeepAlives;

  final bool addRepaintBoundaries;

  LoadingListView(this.pageRequest,
      {this.pageSize: 20,
      this.pageThreshold: 3,
      @required this.widgetAdapter,
      this.reverse: false,
      Key key,
      this.startFrom: 1,
      this.cacheExtent: 250.0,
      this.addAutomaticKeepAlives: true,
      this.addRepaintBoundaries : true})
      : super(key: key);

  @override
  LoadingListViewState createState() => LoadingListViewState<T>();
}

class LoadingListViewState<T> extends State<LoadingListView<T>> with TickerProviderStateMixin {
  List<T> objects = [];
  Map<int, int> index = {};
  Future request;
  bool isPerformingRequest = true;
  bool isLoadMore = true;

//  bool isAnimate = false;
  bool isScroll = false;
  int lastItemBuilt = 0;

//  ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  @override
  void initState() {
    super.initState();
    this.lockedLoadNext();
//    _scrollController.addListener((){
//      if (_scrollController.position.extentAfter - _scrollController.offset <
//              50) {
//        lockedLoadNext();
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        cacheExtent: widget.cacheExtent,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        itemBuilder: itemBuilder,
        itemCount: objects.length + (isLoadMore ? 1 : 0),
        reverse: widget.reverse,
//        controller: _scrollController,
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    if (index + widget.pageThreshold > objects.length) {
      lockedLoadNext();
    }

    if (index == objects.length) return _buildProgressIndicator();
    bool isAnimate = false;
    if (index > lastItemBuilt) {
      isAnimate = true;
      lastItemBuilt = index;
    }
    return widget.widgetAdapter != null
        ? widget.widgetAdapter(objects[index], index, ticker: this, isAnimate: isAnimate)
        : new SizedBox();
  }

  Future loadNext() async {
    if (isLoadMore) {
      int page = (objects.length / widget.pageSize).ceil() + widget.startFrom;
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
