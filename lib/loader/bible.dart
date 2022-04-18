import 'dart:math';

class Bible {
  final keys = <String, _Key>{};

  Bible.fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      keys[entry.key] = _Key.fromJson(entry.value);
    }
  }

  @override
  String toString() {
    String s = '';
    for (final key in keys.values) {
      s += key.toString() + '\n';
    }
    return s;
  }
}

class _Key {
  _Key.fromJson(List<dynamic> json) {
    for (final note in json) {
      notes.add(_Note.fromJson(note));
    }
  }

  final notes = <_Note>[];

  @override
  String toString() {
    String s = '';
    for (final note in notes) {
      s += note.toString();
    }
    return s;
  }
}

class _Note {
  _Note.fromJson(Map<String, dynamic> json)
      : pitch = json['pitch'],
        chord = json['chord'],
        accidental = json.containsKey('accidental') ? json['accidental'] : null,
        fakeAccidental =
            json.containsKey('fakeAccidental') ? json['fakeAccidental'] : null;

  final String? accidental, fakeAccidental;
  final String chord;
  final int pitch;

  @override
  String toString() {
    return '$pitch, $chord, $accidental, $fakeAccidental';
  }
}
