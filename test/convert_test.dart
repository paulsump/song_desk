// © 2022, Paul Sumpner <sumpner@hotmail.com>

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

      for (int i = 0; i < 12; ++i){
      final quaver = Quaver(pitch: i, accidental: null);

      // final semitone = convert.quaverToSemitone(quaver, 'C');
      }
      // expect(semitone, equals(1));
    });
  });
}
