// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:song_desk/out.dart';

const noWarn = out;

/// convenient access to screen dimensions.
Size getScreenSize(BuildContext context) => MediaQuery.of(context).size;

double getScreenWidth(BuildContext context) => getScreenSize(context).width;

double getScreenHeight(BuildContext context) => getScreenSize(context).height;

Offset getScreenCenter(BuildContext context) {
  final size = getScreenSize(context);
  return Offset(size.width, size.height) / 2;
}

bool isPortrait(BuildContext context) {
  final screen = getScreenSize(context);
  return screen.width < screen.height;
}

/// object dimensions calculated using the shortestEdge of the screen...

double screenAdjust(double length, BuildContext context) =>
    length * _getScreenShortestEdge(context);

double _getScreenShortestEdge(BuildContext context) {
  final screen = getScreenSize(context);

  return min(screen.width, screen.height);
}
