// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/player/calc_duration.dart';

/// Test [Song] functions.
void main() {
  String getFileText(String fileName) =>
      File('test_songs/$fileName.json').readAsStringSync();

  Future<Song> getSong(title) async {
    final map = await json.decode(getFileText(title));

    return Song.fromJson(map);
  }

  group('calcDuration duration_test', () {
    test('bass bar 1, q 2 = 2', () async {
      final song = await getSong('duration_test');

      final int duration = calcDuration(1, 2, 'bass', song.bars);
      expect(duration, equals(2));
    });
  });
}
