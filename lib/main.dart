import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manga4dog/base/util/size_util.dart';

import 'view/splash/splash_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      //showPerformanceOverlay: true,
      home: SafeArea(
        child: LayoutBuilder(
          builder: (context, boxConstraint) {
            SizeUtil.instance.init(boxConstraint.maxWidth, boxConstraint.maxHeight);
            return SplashView();
          },
        ),
      ),
    );
  }
}
