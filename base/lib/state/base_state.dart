
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:base/contract/base_contract.dart';
import 'package:base/dialog/loading_dialog.dart';
import 'package:base/exception/exceptions.dart';
import 'package:base/no_scale_factor_text.dart';
import 'package:base/observable_life_cycle/observable_life_cycle.dart';
import 'package:base/resources/strings.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> implements BaseContract {
  final LifeCycleRegistry _lifeCycleRegistry = LifeCycleRegistry();

  LoadingDialog _loadingDialog;

  bool _loadingDialogShowing = false;
  bool _hasDialogShowing = false;

  bool animatedVertically() => true;

  @override
  void initState() {
    super.initState();
    _lifeCycleRegistry.notifyStateChanged(LifeCycleState.INIT);
  }

  T getAncestorState<T>() => (context.ancestorStateOfType(TypeMatcher<T>()) as T);

  @override
  void dispose() {
    _lifeCycleRegistry.notifyStateChanged(LifeCycleState.DISPOSE);
    super.dispose();
  }

  @override
  void onDisplayError(Exception exception, {VoidCallback onOk, bool barrierDismissible: true, shouldAllowPop}) {
  }

  @override
  void onDisplayErrorWithTryAgain(Exception exception, VoidCallback onTryAgain) {
  }

  @override
  void onHideLoading() {
    hideLoadingDialog();
  }

  @override
  void onShowLoading() {
    _showLoadingDialog();
  }

  @override
  LifeCycle get lifeCycle => _lifeCycleRegistry;

  @override
  bool get isMounted => mounted;

  void _showLoadingDialog() async {
    if (!_loadingDialogShowing) {
      _loadingDialogShowing = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (_loadingDialog == null) _loadingDialog = LoadingDialog();
          return _loadingDialog;
        },
      );
    }
  }

  void hideLoadingDialog() {
    if (_loadingDialogShowing) {
      _loadingDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void hideShowingDialog() {
    if (_hasDialogShowing) {
      _hasDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void showSnackBar(String message) {
    try {
      Scaffold.of(context).hideCurrentSnackBar(reason: SnackBarClosedReason.remove);
    } catch (ex) {}
    Scaffold.of(context).showSnackBar(SnackBar(
      content: NoScaleFactorText(message),
      duration: Duration(seconds: 2),
    ));
  }
}
