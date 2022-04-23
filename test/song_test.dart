// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';

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

  group('f', () {
    test('C', () async {
      final persist = Persist();
      const title = 'After All';

      await persist.loadSong(title);
      final song = persist.songs[title]!;
    });
  });
}
