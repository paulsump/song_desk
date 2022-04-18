import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:song_desk/loader/bible.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

class Convert {
  late final Bible bible;

  Future<void> init() async {
    await _loadBible();
  }

  int quaverToSemitone(Quaver quaver, String key) {
    final pitch = quaver.pitch!;

    final semitoneOffset = _getSemitoneOffset(quaver, key);
    final octave = 12 * ((pitch - 1) ~/ 7);

    out('$pitch: $semitoneOffset,$octave');
    return semitoneOffset + octave;
  }

  Future<void> _loadBible() async {
    final String response = await rootBundle.loadString('config/bible.json');

    final map = await json.decode(response);
    bible = Bible.fromJson(map);
  }

  int _getSemitoneOffset(Quaver quaver, String key) {
    final pitch = quaver.pitch;

    final accidental = quaver.accidental;
    int semitoneOffset = 0;

    for (final note in bible.keys[key]!.notes) {
      if (accidental == note.accidental) {
        final pitchOffset = note.pitch;

        if (_isPitchInAnyOctaveOf(pitch!, pitchOffset)) {
          return semitoneOffset;
        }
      }

      semitoneOffset += 1;
    }

    return semitoneOffset;
  }

  bool _isPitchInAnyOctaveOf(int pitch, pitchOffset) {
    final octaves = {-35, -28, -21, -14, -7, 0, 7, 14, 21, 28, 35};

    for (final octave in octaves) {
      if (pitchOffset == pitch + octave) {
        return true;
      }
    }
    return false;
  }
}
