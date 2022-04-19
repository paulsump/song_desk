// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:song_desk/loader/song.dart';

class Persist {
  final songs = <String, Song?>{};

  static const folderPaths = ['pop/', 'reggae/', 'soul/'];
  static const extension = '.json';

  Future<void> loadSong(String folderPath, String name) async {
    final String response =
        await rootBundle.loadString('$folderPath$name$extension');

    final map = await json.decode(response);
    songs[name] = Song.fromJson(map);
  }
}
