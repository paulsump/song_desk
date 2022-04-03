// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';

// for longer out put
// const _out = log;

final _out = debugPrint; // for tests

/// output any type of object, using toString()
/// or special case for a couple of types like List<Offset>
void out(Object object) {
  if (object is List<Offset>) {
    _out('n = ${object.length}\nconst [');
    for (Offset offset in object) {
      _out('Offset(${offset.dx},${offset.dy}),');
    }
    _out(']');
  } else if (object is Offset) {
    _out('${object.dx},${object.dy}');
  } else {
    _out(object.toString());
  }
}

/// Save errors somewhere that technical support can retrieve them later.
/// Currently this just passes the message to [out]()
///
/// TODO save messages to log file for now, later it would go on the cloud.
/// If I save a file to the app folder, I'll need to add path_provider package
/// At the moment there aren't any hidden log errors that make the
/// extra dependency worthwhile.
/// So I'll just output it for now...
void logError(String message) => out(message);
