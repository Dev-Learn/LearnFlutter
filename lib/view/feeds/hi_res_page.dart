import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manga4dog/view/tile/hi_res_image_tile.dart';
import 'package:manga4dog/widget/loading_listview.dart';
import 'package:data/model/hi_res_image/hi_res_image.dart';
import 'package:data/model/hi_res_image/hi_res_image_api.dart';

class HiResImagePage extends StatefulWidget {

  HiResImagePage({Key key}) : super(key: key);

  @override
  _HiResImagePageState createState() => _HiResImagePageState();
}

class _HiResImagePageState extends State<HiResImagePage> with AutomaticKeepAliveClientMixin<HiResImagePage>{

  Widget w;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (w == null) {
      w = LoadingListView<HiResImage>(
        request,
        widgetAdapter: adaptTile,
        pageSize: 20,
        pageThreshold: 5,
        startFrom: 1,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }
    return w;
  }

  Future<List<HiResImage>> request(int page, int pageSize) async {
    HiResImageApi api = new HiResImageApi();
    return api.getImages(page, pageSize);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

Widget adaptTile(HiResImage hiResImage, int index, {TickerProvider ticker, bool isAnimate = false}) {
  return HiResImageTile(hiResImage);
}

