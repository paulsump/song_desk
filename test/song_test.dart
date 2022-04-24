// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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

  group('keyChange', () {
    test('C', () async {
      final song = await getSong('Fantasy');

      expect(song.getKey(18 * 8), equals('C'));
    });
  });

  group('calcDuration After All', () {
    test('bass bar 8, q 0 = 4', () async {
      final song = await getSong('After All');

      final int duration = calcDuration(8, 0, 'bass', song.bars);
      expect(duration, equals(4));
    });

    test('bass bar 16, q 1 = 1', () async {
      final song = await getSong('After All');

      final int duration = calcDuration(16, 1, 'bass', song.bars);
      expect(duration, equals(1));
    });
  });

}
