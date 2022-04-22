import 'dart:math';

/// Quaver Info
class _Note {
  _Note(this.barIndex, this.quaverIndex);

  int barIndex;
  int quaverIndex;

  dynamic bar;
  dynamic quaver;
}

/// Calculate the duration of the note from the gap to the next note
int calcDuration(fromBarIndex, fromQuaverIndex, voice, bars) {
  dynamic previousQuaver;
  int previousBigQuaverIndex = -1;

  final notes = _NoteIterable(voice, fromBarIndex, fromQuaverIndex, bars);

  for (final note in notes) {
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

  final dynamic bars;

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
  ) : _note = _Note(barIndex, quaverIndex);

  final String voice;

  final _Note _note;
  final dynamic bars;

  @override
  _Note get current => _note;

  @override
  bool moveNext() {
    if (_note.barIndex < bars.length()) {
      _note.bar = bars[_note.barIndex];

      if (_note.quaverIndex < 4) {
        _note.quaverIndex += 1;

        if (_note.quaverIndex == 4) {
          _note.barIndex += 1;

          _note.quaverIndex = 0;
          _note.quaver =
              _getQuaver(_note.barIndex, _note.bar, _note.quaverIndex);

          if (_note.quaver != null) {
            return true;
          }
        }

        _note.quaver = _getQuaver(_note.barIndex, _note.bar, _note.quaverIndex);

        if (_note.quaver != null) {
          return true;
        }
      }
    }

    return false;
  }

  _getQuaver(barIndex, bar, quaverIndex) {
    if (bar.containsKey(voice)) {
      dynamic quaver = bar[voice][quaverIndex];

      if (quaver.containsKey('pitch')) {
        return quaver;
      }
    }
  }
}
