import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nima/nima.dart';
import 'package:nima/nima/math/mat2d.dart';
import 'package:nima/nima_actor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
//  bool isLoaded = false;
//  Uint8List imageData;
//
//  @override
//  void initState() {
//    Logger.root.fine('init screen');
//    super.initState();
//    _loadFile().then((data) {
//      Logger.root.fine('end read');
//      setState(() {
//        imageData = data;
//        isLoaded = true;
//      });
//    });
//  }
//
//  Future<Uint8List> _loadFile() async {
//    Directory externalDir = await getExternalStorageDirectory();
//    File file = File(join(externalDir.path, 'Pictures/photo.jpg'));
//    Logger.root.fine('start read');
//    return await file.readAsBytes();
//  }

  @override
  Widget build(BuildContext context) {
//    Logger.root.fine('build screen');
//    return Center(
//      widthFactor: 1.0,
//      heightFactor: 1.0,
//      child: Container(
//        alignment: AlignmentDirectional.center,
//        child: isLoaded
//            ? Image.memory(
//                imageData,
//                fit: BoxFit.cover,
//              )
//            : CircularProgressIndicator(),
//      ),
//    );

//    return new NimaActor("assets/wolf", alignment:Alignment.center, fit:BoxFit.contain, animation:"Run", completed: (_){
//
//    },);

    return Container();
  }
}
