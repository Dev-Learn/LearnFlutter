import 'dart:async';

import 'package:data/model/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga4dog/view/tile/user_tile.dart';
import 'package:manga4dog/widget/loading_listview.dart';
import 'package:data/model/user/user_api.dart';

class FollowersPage extends StatefulWidget {
  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage>
    with AutomaticKeepAliveClientMixin<FollowersPage> {
  Widget w;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (w == null) {
      w = LoadingListView<User>(
        request,
        widgetAdapter: adaptTile,
        pageSize: 50,
        pageThreshold: 5,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }
    return w;
  }

  Future<List<User>> request(int page, int pageSize) async {
    UserAPI api = new UserAPI();
    return api.getFollowers(page, pageSize);
  }

  @override
  bool get wantKeepAlive => true;
}

Widget adaptTile(User user, int index, {TickerProvider ticker, bool isAnimate = false}) {
  return new UserTile(user, isAnimate, index, ticker, );
}



