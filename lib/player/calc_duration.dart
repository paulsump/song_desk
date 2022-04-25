// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:math';

import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

/// Calculate the duration of the note from the gap to the next note
int calcDuration(
  int fromBarIndex,
  int fromQuaverIndex,
  String voice,
  List<Bar> bars,
) {
  final int fromQ = fromBarIndex * 4 + fromQuaverIndex;
  int fromPitch = _getPitchAt(fromQ, voice, bars)!;

  for (int toQ = 1 + fromQ; toQ < 4 * bars.length; ++toQ) {
    int? toPitch = _getPitchAt(toQ, voice, bars);

    if (toPitch != null) {
      // if (toPitch != fromPitch) {
      return min(12, toQ - fromQ);
      // }
    }
  }

  return 7;
}

int? _getPitchAt(int Q, String voice, List<Bar> bars) {
  int barIndex = Q ~/ 4;

  int quaverIndex = Q % 4;
  final List<Quaver>? quavers = bars[barIndex].getQuavers(voice);

  return quavers?[quaverIndex].pitch;
}

//TODO TRiplets
// final bool triplet = isTriplet(note.bar, voice);
// final int bigQuaverIndex = note.barIndex * 4 + note.quaverIndex * (triplet?4/3 : 1);
// bool isTriplet(bar, voice) {
//   return false;
// }
