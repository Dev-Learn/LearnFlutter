import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:base/util/size_util.dart';

import 'view/splash/splash_view.dart';

void main(){

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) => runApp(new MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //showPerformanceOverlay: true,
      home: LayoutBuilder(
        builder: (context, boxConstraint) {
          SizeUtil.instance.init(boxConstraint.maxWidth, boxConstraint.maxHeight);
          return SplashView();
        },
      ),
    );
  }
}
