import 'package:flutter/painting.dart';

bool isDarkColor(int color) {
  int red = (color >> 16) & 0xFF;
  int green = (color >> 8) & 0xFF;
  int blue = color & 0xFF;
  double darkness = 1 - (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
  if (darkness < 0.5) {
    return false; //light
  } else {
    return true; //dark
  }
}

Color getLighterColor(Color color, double ratio){

  assert(ratio >= 0.0 && ratio <= 1.0);

  Color lighterColor = new Color.fromRGBO(
      (color.red + ((255 - color.red) * ratio)).round(),
      (color.green + ((255 - color.green) * ratio)).round(),
      (color.blue + ((255 - color.blue) * ratio)).round(),
      1.0);

  return lighterColor;
}

Color getDarkerColor(Color color, double ratio){

  assert(ratio >= 0.0 && ratio <= 1.0);

  Color darkerColor = new Color.fromRGBO(
      (color.red - ( color.red * ratio)).round(),
      (color.green - (color.green * ratio)).round(),
      (color.blue - (color.blue * ratio)).round(),
      1.0);

  return darkerColor;
}