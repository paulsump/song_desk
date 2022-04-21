// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/song.dart';

/// Test [Song] functions.
void main() {
  group('Song keyChanges()', () {
    test('C', () {

      //TODO load song json
      const songJson = "TODO";
      final song = Song.fromJson(json.decode(songJson));

      expect(song.getKey(8 * 8), equals('Bb'));
    });
  });
}
