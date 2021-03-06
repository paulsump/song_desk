// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/player/calc_duration.dart';

/// Test [calcDuration] with various parameters.
void main() {
  String getFileText(String fileName) =>
      File('test_songs/$fileName.json').readAsStringSync();

  Future<Song> getSong(title) async {
    final map = await json.decode(getFileText(title));

    return Song.fromJson(map);
  }

  group('duration* (n = 2)', () {
    test('bass bar 1, q 2 = 2', () async {
      final song = await getSong('duration0');

      final double? duration = calcDuration(1, 2, 'bass', song.bars);
      expect(duration, equals(2));
    });

    test('duration1 (n = 2): bass bar 0, q 0 = null', () async {
      final song = await getSong('duration1');

      final double? duration = calcDuration(0, 0, 'bass', song.bars);
      expect(duration, equals(null));
    });
  });

  group('calc_duration_test', () {
    test('bass bar 0, q 0 = 3', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(0, 0, 'bass', song.bars);
      expect(duration, equals(3));
    });

    test('bass bar 0, q 3 = 3', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(0, 3, 'bass', song.bars);
      expect(duration, equals(3));
    });

    test('bass bar 1, q 2 = 2', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(1, 2, 'bass', song.bars);
      expect(duration, equals(2));
    });

    test('bass bar 2, q 0 = 1', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(2, 0, 'bass', song.bars);
      expect(duration, equals(1));
    });

    test('bass bar 2, q 1 = 2', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(2, 1, 'bass', song.bars);
      expect(duration, equals(2));
    });

    test('bass bar 2, q 3 = 3', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(2, 3, 'bass', song.bars);
      expect(duration, equals(3));
    });

    test('bass bar 3, q 2 = 7', () async {
      final song = await getSong('calc_duration_test');

      final double? duration = calcDuration(3, 2, 'bass', song.bars);
      expect(duration, equals(null));
    });
  });

  group('After All', () {
    test('bass bar 8, q 0 = 4', () async {
      final song = await getSong('After All');

      final double? duration = calcDuration(8, 0, 'bass', song.bars);
      expect(duration, equals(4));
    });

    test('bass bar 16, q 1 = 1', () async {
      final song = await getSong('After All');

      final double? duration = calcDuration(16, 1, 'bass', song.bars);
      expect(duration, equals(1));
    });
  });

  group('scheduler', () {
    test('bass bar 0, q 0 = 4', () async {
      final song = await getSong('scheduler');

      final double? duration = calcDuration(0, 0, 'bass', song.bars);
      expect(duration, equals(null));
    });
  });
}
