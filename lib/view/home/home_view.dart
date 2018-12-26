import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manga4dog/presenter/home/home_presenter.dart';
import 'package:manga4dog/view/feeds/comic_page.dart';
import 'package:manga4dog/view/feeds/feeds_page.dart';
import 'package:manga4dog/view/followers/followers_page.dart';
import 'package:manga4dog/view/home/drawer.dart';
import 'package:base/state/base_state.dart';
import 'package:flutter/scheduler.dart';

class HomeView extends StatefulWidget {
  HomeView();

  @override
  _HomeViewState createState() => new _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> {

  PageController _pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
          drawer: Drawer(
            child: MenuDrawer(),
          ),
        body: Builder(
          builder: (context) {
            return PageView(
                physics: NeverScrollableScrollPhysics(),
                children: [
//                  FeedsPage(),
                  FeedsPage(),
//                  HiResImagePage(),
                  ComicPage(comicId: 17,),
                  FollowersPage(),
                ],

                /// Specify the page controller
                controller: _pageController,
                onPageChanged: onPageChanged);
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), title: Text("profiles")),
              BottomNavigationBarItem(icon: Icon(Icons.rss_feed), title: Text("feed")),
              BottomNavigationBarItem(icon: Icon(Icons.people), title: Text("Followers"))
            ],

            /// Will be used to scroll to the next page
            /// using the _pageController
            onTap: navigationTapped,
            currentIndex: _page),
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController(keepPage: true, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

}
