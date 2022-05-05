// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

class Persist {
  //TODO remove nullable from Song
  final songs = <String, Song?>{};

  static const folderPath = 'songs/';
  static const extension = '.json';

  Future<void> loadSongs() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');

    final files = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith(folderPath));

    for (String file in files) {
      final title = file
          .replaceAll('%20', ' ')
          .replaceAll(folderPath, '')
          .replaceAll(Persist.extension, '');

      await loadSong(title);
    }
  }

  /// public for tests only
  Future<void> loadSong(String title) async {
    final String response =
        await rootBundle.loadString('$folderPath$title$extension');

    final map = await json.decode(response);

    try {
      songs[title] = Song.fromJson(map);
    } catch (e) {
      logError('Loading $title: $e');
    }
  }
}
