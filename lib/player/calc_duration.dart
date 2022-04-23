// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:math';

import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';

/// Calculate the duration of the note from the gap to the next note
int calcDuration(fromBarIndex, fromQuaverIndex, voice, bars) {
  Quaver? previousQuaver;

  int previousBigQuaverIndex = -1;
  final notes = _NoteIterable(voice, fromBarIndex, fromQuaverIndex, bars);

  // out('s c $fromBarIndex, $fromQuaverIndex');

  for (final _Note note in notes) {
    final int bigQuaverIndex = note.barIndex * 4 + note.quaverIndex;

    // out('p c: $note');

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
  )   : _currentNote = _Note(barIndex, quaverIndex),
        _nextNote = _Note(barIndex, quaverIndex);

  final String voice;
  final List<Bar> bars;

  /// for iteration
  final _Note _nextNote;

  /// FOR external use
  final _Note _currentNote;

  @override
  _Note get current => _currentNote;

  @override
  bool moveNext() {
    while (_nextNote.barIndex < bars.length) {
      final Bar? bar = bars[_nextNote.barIndex];

      while (_nextNote.quaverIndex < 4) {
        _currentNote.quaverIndex = _nextNote.quaverIndex;

        _nextNote.quaverIndex += 1;
        _currentNote.barIndex = _nextNote.barIndex;

        if (_nextNote.quaverIndex == 4) {
          _nextNote.barIndex += 1;

          _nextNote.quaverIndex = 0;
          _currentNote.setQuaverIfHasPitch(bar!.getQuavers(voice));

          // out('4a c: $_currentNote');
          if (_currentNote.quaver != null) {
            // out('4b c: $_currentNote');
            return true;
          }
        }

        _currentNote.setQuaverIfHasPitch(bar!.getQuavers(voice));

        if (_currentNote.quaver != null) {
          // out('ok c: $_currentNote');
          return true;
        }
      }
    }

    // out('done c: $_currentNote');
    return false;
  }
}

/// Quaver Info
class _Note {
  _Note(this.barIndex, this.quaverIndex);

  int barIndex;
  int quaverIndex;

  Quaver? quaver;

  void setQuaverIfHasPitch(List<Quaver>? quavers) {
    quaver = null;

    if (quavers != null) {
      final Quaver quaver_ = quavers[quaverIndex];

      if (quaver_.pitch != null) {
        quaver = quaver_;
      }
    }
  }

  @override
  String toString() => '$barIndex, $quaverIndex';
}
