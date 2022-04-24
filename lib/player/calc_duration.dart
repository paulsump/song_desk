// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:math';

import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

/// Calculate the duration of the note from the gap to the next note
int calcDuration(fromBarIndex, fromQuaverIndex, voice, bars) {
  Quaver? previousQuaver;

  int previousBigQuaverIndex = -1;
  final noteIterable = _NoteIterable(voice, fromBarIndex, fromQuaverIndex, bars);

  for (final _Note note in noteIterable) {
    final int bigQuaverIndex = note.barIndex * 4 + note.quaverIndex;

    if (previousQuaver != null) {
      return min(12, bigQuaverIndex - previousBigQuaverIndex);
    }

    previousQuaver = note.quaver;
    previousBigQuaverIndex = bigQuaverIndex;
  }

  return 7;
}

//TODO TRiplets
// final bool triplet = isTriplet(note.bar, voice);
// final int bigQuaverIndex = note.barIndex * 4 + note.quaverIndex * (triplet?4/3 : 1);
// bool isTriplet(bar, voice) {
//   return false;
// }

class _NoteIterable extends Iterable<_Note> {
  _NoteIterable(this.voice, this.fromBarIndex, this.fromQuaverIndex, this.bars);

  final String voice;
  final int fromBarIndex, fromQuaverIndex;

  final List<Bar> bars;

  @override
  Iterator<_Note> get iterator =>
      _NoteIterator(voice, fromBarIndex, fromQuaverIndex, bars);
}

/// Traverses all bars then each quaver of a voice,
/// returns quaver info if has pitch.
class _NoteIterator implements Iterator<_Note> {
  _NoteIterator(
    this.voice,
    int barIndex,
    int quaverIndex,
    this.bars,
  )   : _current = _Note(barIndex, quaverIndex),
        _next = _Note(barIndex, quaverIndex);

  final String voice;
  final List<Bar> bars;

  /// for iteration
  final _Note _next;

  /// FOR external use
  final _Note _current;

  @override
  _Note get current => _current;

  @override
  bool moveNext() {
    while (_next.barIndex < bars.length) {
      final Bar? bar = bars[_next.barIndex];

      while (_next.quaverIndex < 4) {
        _current.quaverIndex = _next.quaverIndex;

        _next.quaverIndex += 1;
        _current.barIndex = _next.barIndex;

        if (_next.quaverIndex == 4) {
          _next.barIndex += 1;

          _next.quaverIndex = 0;
          _current.setQuaverIfHasPitch(bar!.getQuavers(voice), _next);

          if (_current.quaver != null) {
            out('4: $current');
            return true;
          }
        }

        _current.setQuaverIfHasPitch(bar!.getQuavers(voice), _next);

        if (_current.quaver != null) {
          out('${_next.quaverIndex}: $current');
          return true;
        }
      }
    }

    out('done: $current');
    return false;
  }
}

/// Quaver Info
class _Note {
  _Note(this.barIndex, this.quaverIndex);

  int barIndex;
  int quaverIndex;

  Quaver? quaver;

  void setQuaverIfHasPitch(List<Quaver>? quavers, _Note next) {
    quaver = null;

    if (quavers != null) {
      final Quaver quaver_ = quavers[next .quaverIndex];

      if (quaver_.pitch != null) {
        quaver = quaver_;

        barIndex = next.barIndex;
        quaverIndex = next.quaverIndex;
      }
    }
  }

  @override
  String toString() => '$barIndex, $quaverIndex';
}
