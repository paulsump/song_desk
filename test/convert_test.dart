// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/convert.dart';
import 'package:song_desk/loader/song.dart';

/// Test serialization of [Convert] functions.
void main() {
  group('Convert.quaverToSemitone()', () {
    final convert = Convert();

    TestWidgetsFlutterBinding.ensureInitialized();

    test('C', () async {
      await convert.init();
      final quaver = Quaver(pitch: 0, accidental: null);

      final semitone = convert.quaverToSemitone(quaver, 'C');
      expect(semitone, equals(1));
    });
  });
}
