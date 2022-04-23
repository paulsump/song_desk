// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/player/calc_duration.dart';

/// Test [Song] functions.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('keyChange', () {
    test('C', () async {
      final persist = Persist();
      const title = 'Fantasy';

      await persist.loadSong(title);
      final song = persist.songs[title]!;
      expect(song.getKey(18 * 8), equals('C'));
    });
  });

  group('calcDuration', () {
    test('1', () async {
      final persist = Persist();
      const title = 'After All';

      await persist.loadSong(title);
      final song = persist.songs[title]!;

      final int duration = calcDuration(16, 1, 'bass', song.bars);
      expect(duration, equals(1));
    });
  });
}
