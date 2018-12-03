import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manga4dog/presenter/home/home_presenter.dart';
import 'package:manga4dog/view/home/drawer.dart';
import 'package:base/state/base_state.dart';
import 'package:flutter/scheduler.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  _HomeViewState createState() => new _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> with AutomaticKeepAliveClientMixin<HomeView> implements HomeContract{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
          drawer: Drawer(
            child: MenuDrawer(),
          ),
//          body: LoadingListViewByKey
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

//  Future<List<Comic>> request(int page, int pageSize) async {
//    return api.getComicImages(page, pageSize, widget.comicId);
//  }

  @override
  onLoadComicsCompleted() {
    // TODO: implement onLoadComicsCompleted
    return null;
  }
}
