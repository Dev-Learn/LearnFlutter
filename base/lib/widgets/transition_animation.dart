import 'package:flutter/material.dart';

enum TransitionType{
  FromRight,
  FromBottom,
  Fade
}

class AnimatedPageRoute extends MaterialPageRoute {

  final Duration duration;
  final TransitionType transitionType;

  AnimatedPageRoute({@required Widget child, this.duration = defaultDuration, this.transitionType = TransitionType.FromRight}) : super(builder: (context) => child);

  @override
  Duration get transitionDuration => duration?? defaultDuration;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    switch(transitionType){
      case TransitionType.FromRight:
        Animation<Offset> slideAnimation = _slideRightToLeftTween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ));
        return SlideTransition(position: slideAnimation, child: child);
      case TransitionType.FromBottom:
        Animation<Offset> slideAnimation = _slideBottomToTopTween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ));
        return SlideTransition(position: slideAnimation, child: child);
      case TransitionType.Fade:
      default:
        Animation<double> fadeAnimation = _fadeTween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ));
        return FadeTransition(opacity: fadeAnimation, child: child);

    }
  }
}

const Duration defaultDuration = const Duration(milliseconds: 300);

final Tween<Offset> _slideRightToLeftTween = new Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

final Tween<Offset> _slideBottomToTopTween = new Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

final Tween<double> _fadeTween = new Tween<double>(
  begin: 0.0,
  end: 1.0,
);
