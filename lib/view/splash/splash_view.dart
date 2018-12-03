import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data/auth/auth_manager.dart';
import 'package:data/common/shared_preferences_manager.dart';
import 'package:manga4dog/view/login/login_view.dart';
import 'package:base/widgets/transition_animation.dart';

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
    await AuthManager().init();

    SharedPreferencesManager sharedPreferencesManager = await SharedPreferencesManager.getInstance();
    Future.delayed(const Duration(milliseconds: 1500)).then((_) async {
      Widget w;
      if (!sharedPreferencesManager.loggedIn) {
        w = LoginView();
      } else {
        w = LoginView();
      }
      Navigator.of(context).push(
        AnimatedPageRoute(child: w, duration: Duration(milliseconds: 1000), transitionType: TransitionType.FromRight),
      );
    });
  }
}
