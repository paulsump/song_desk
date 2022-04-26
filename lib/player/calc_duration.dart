// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:song_desk/loader/song.dart';

/// Q is the index if all the quavers were stored in a single array.
/// It's combination of barIndex and quaverIndex.
/// Also known as bigQuaverIndex in Mel.

/// Calculate the duration of the note from the gap to the next note
/// If the gap is bigger than 12 then returns null
int? calcDuration(
  int fromBarIndex,
  int fromQuaverIndex,
  String voice,
  List<Bar> bars,
) {
  final int fromQ = fromBarIndex * 4 + fromQuaverIndex;
  int? fromPitch = _getPitchAt(fromQ, voice, bars);

  for (int toQ = 1 + fromQ; toQ < 4 * bars.length; ++toQ) {
    int? toPitch = _getPitchAt(toQ, voice, bars);

    if (toPitch != null) {
      // TODO remove this null check, shouldn't need it
      if (fromPitch != null) {
        if (toPitch == fromPitch) {
          return null;
        }
      }

      final int duration = toQ - fromQ;
      // TODO Always duration, so return 16
      return 12 < duration ? null : duration;
    }
  }

  // TODO Always duration, so return 16
  return null;
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
