import 'package:flutter/material.dart';

class NoScaleFactorText extends Text {
  NoScaleFactorText(
    String data, {
    Key key,
    TextStyle style,
    TextAlign textAlign,
    TextDirection textDirection,
    bool softWrap,
    TextOverflow overflow,
    int maxLines,
  }) : super(
          data,
          key: key,
          style: style == null ? TextStyle(fontFamily: 'SfProDisplay') : style.copyWith(fontFamily: 'SfProDisplay'),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: 1.0,
          maxLines: maxLines,
        );
}
