// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:song_desk/loader/song.dart';

class Persist {
  final songs = <String, Song?>{};

  static const folderPaths = ['songs/'];
  static const extension = '.json';

  Future<void> loadSongs() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');

    for (String folderPath in Persist.folderPaths) {
      final files = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith(folderPath));

      for (String file in files) {
        final name = file
            .replaceAll('%20', ' ')
            .replaceAll(folderPath, '')
            .replaceAll(Persist.extension, '');

        await _loadSong(folderPath, name);
      }
    }
  }

  Future<void> _loadSong(String folderPath, String name) async {
    final String response =
        await rootBundle.loadString('$folderPath$name$extension');

    final map = await json.decode(response);
    songs[name] = Song.fromJson(map);
  }
}
