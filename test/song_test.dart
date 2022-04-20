// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/song.dart';

/// Test [Song] functions.
void main() {
  group('Song keyChanges()', () {
    test('C', () {
      final song = Song(
        bars: List.generate(16*8, (i) => Bar()),
        genre: '',
        key: 'C',
        swing: 0,
        tempo: 111,
      );

      final json = {
        'keyChanges': {'Chorus': 'Bb'},
        'staveLabels':
        [
          "Guitar",
          "Intro",
          "",
          "",
          "Verse",
          "",
          "",
          "",
          "Chorus",
          "",
          "",
          "",
          "Break",
          "Bridge",
          "",
          "",
        ],
      };
      song.calcKeyChangesAtBigStaveIndices(json);

      expect(song.getKey(8*8), equals('Bb'));
    });
  });
}
