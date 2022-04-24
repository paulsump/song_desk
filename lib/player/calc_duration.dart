// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:math';

import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

int _calcBigQuaverIndex(int barIndex, int quaverIndex) =>
    barIndex * 4 + quaverIndex;

/// Calculate the duration of the note from the gap to the next note
int calcDuration(
  int fromBarIndex,
  int fromQuaverIndex,
  String voice,
  List<Bar> bars,
) {
  final int fromBigQuaverIndex =
      _calcBigQuaverIndex(fromBarIndex, fromQuaverIndex);

  for (int Q = 1 + fromBigQuaverIndex; Q < 4 * bars.length; ++Q) {
    if (_hasPitchAt(Q, voice, bars)) {
      return min(12, Q - fromBigQuaverIndex);
    }
  }

  return 7;
}

bool _hasPitchAt(int Q, String voice, List<Bar> bars) {
  int barIndex = Q ~/ 4;

  int quaverIndex = Q % 4;
  final List<Quaver>? quavers = bars[barIndex].getQuavers(voice);

  return quavers?[quaverIndex].pitch != null;
}

//TODO TRiplets
// final bool triplet = isTriplet(note.bar, voice);
// final int bigQuaverIndex = note.barIndex * 4 + note.quaverIndex * (triplet?4/3 : 1);
// bool isTriplet(bar, voice) {
//   return false;
// }
