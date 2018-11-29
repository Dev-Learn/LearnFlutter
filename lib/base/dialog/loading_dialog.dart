
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manga4dog/base/dialog/base_dialog.dart';

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    Widget dialog = CupertinoActivityIndicator(
      radius: 18.0,
    );
    return WillPopScope(
      child: BaseDialog(
        child: dialog,
        minWidth: 23.0,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      onWillPop: () {},
    );
  }
}
