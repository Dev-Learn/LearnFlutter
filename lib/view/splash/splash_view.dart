import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manga4dog/base/util/size_util.dart';
import 'package:data/auth/auth_manager.dart';
import 'package:data/common/shared_preferences_manager.dart';
import 'package:manga4dog/view/login/login_view.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: AlignmentDirectional.center,
          child: Hero(
            tag: 'imageHero',
            child: Image.asset(
              'assets/ic_github_icon.png',
              width: 200.0,
              height: 200.0,
            ),
          ),
        ),
      ),
    );
  }

  Future _init() async {
    await AuthManager.getInstance().init();

    SharedPreferencesManager sharedPreferencesManager = await SharedPreferencesManager.getInstance();
    Future.delayed(const Duration(milliseconds: 1500)).then((_) async {
      Widget w;
      if (!sharedPreferencesManager.loggedIn) {
        w = LoginView();
      } else {
        w = LoginView();
      }
      Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => w,
            transitionDuration: Duration(milliseconds: 1000),
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child){
              Animation<Offset> slideAnimation = Tween(begin: Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            }
        ),
      );
    });
  }
}
