
import 'package:flutter/material.dart';
import 'package:base/util/size_util.dart';

class BaseDialog extends StatelessWidget {
  const BaseDialog({
    Key key,
    this.child,
    this.minWidth = 0.0,
    this.minHeight = 0.0,
    this.elevation = 24.0,
    this.borderRadius = const BorderRadius.all(const Radius.circular(15.0)),
    this.backgroundColor = Colors.white,
    this.insetAnimationDuration: const Duration(milliseconds: 100),
    this.insetAnimationCurve: Curves.decelerate,
    this.shape,
  }) : super(key: key);

  final Widget child;

  final double elevation;

  final double minWidth;

  final double minHeight;

  final BorderRadius borderRadius;

  final Color backgroundColor;

  final Duration insetAnimationDuration;

  final Curve insetAnimationCurve;

  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    double maxWidth = SizeUtil.instance.getSize(920);
    double maxHeight = SizeUtil.instance.getSize(840, basedOnSmaller: false);
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Center(
          child: new ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: maxWidth,
              minHeight: minHeight,
              maxHeight: maxHeight,
            ),
            child: new Material(
              borderRadius: borderRadius,
              elevation: elevation,
              color: backgroundColor,
              type: MaterialType.card,
              child: child,
              shape: shape,
            ),
          ),
        ),
      ),
    );
  }
}
