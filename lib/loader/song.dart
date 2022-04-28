// © 2022, Paul Sumpner <sumpner@hotmail.com>

class Song {
  final List<Bar> bars;

  final String strum;
  final int swing, tempo;

  final Map<int, String> _keyChangesAtBigStaveIndices;
  final bool _doubleTime;

  final _repeatDurations = <int>[];
  final _endingDurations = <int>[];

  Song.fromJson(Map<String, dynamic> json)
      : bars = List<Bar>.from(json["bars"].map((bar) => Bar.fromJson(bar))),
        swing = json.containsKey('swing') ? json['swing'] : 0,
        tempo = json['tempo'],
        _doubleTime = json.containsKey('doubleTime'),
        strum = json['strum'],
        _keyChangesAtBigStaveIndices = {0: json['key']} {
    _calcKeyChangesAtBigStaveIndices(json);

    _calcRepeatDurations();
    _calcEndingDurations();
  }

  void _calcKeyChangesAtBigStaveIndices(Map<String, dynamic> json) {
    if (json.containsKey('keyChanges')) {
      final keyChanges = json['keyChanges'];

      final staveLabels = json['staveLabels'];
      final staveCount = _calcStaveCount(bars.length);

      for (int page = 0; page < 2; ++page) {
        for (int stave = 0; stave < staveCount; ++stave) {
          int staveIndex = page * staveCount + stave;

          if (staveIndex < staveLabels.length) {
            final staveLabel = staveLabels[staveIndex];

            if (keyChanges.containsKey(staveLabel)) {
              _keyChangesAtBigStaveIndices[staveIndex] = keyChanges[staveLabel];
            }
          }
        }
      }
    }
  }

  String getKey(int barIndex) {
    String key = _keyChangesAtBigStaveIndices[0]!;

    for (int i = 0; i < _calcStaveIndex(barIndex) + 1; ++i) {
      if (_keyChangesAtBigStaveIndices.containsKey(i)) {
        key = _keyChangesAtBigStaveIndices[i]!;
      }
    }
    return key;
  }

  bool boomClapOrDoubleReggae() =>
      strum.contains('BoomClap') || (_doubleTime && strum == 'Reggae');

  void _calcRepeatDurations() {
    int? previousLeftIndex;

    for (int b = 0; b < bars.length; ++b) {
      final Bar bar = bars[b];

      if (bar.repeatLeft) {
        // when find a Right, track backwards to first found Left
        previousLeftIndex = b;
      }

      if (bar.repeatRight != 0) {
        for (int n = 0; n < bar.repeatRight; ++n) {
          _repeatDurations.add(b - previousLeftIndex!);
        }
      }
    }
  }

  // calc extra needed to jump pass ending '1' to get to ending '2,3'
  void _calcEndingDurations() {
    int? ending1Index;

    for (int b = 0; b < bars.length; ++b) {
      final Bar bar = bars[b];

      if (bar.ending != null) {
        final String ending = bar.ending!;

        if (ending == '1') {
          // when find a ending1, track backwards to first found ending2
          ending1Index = b;
        } else {
          _endingDurations.add(b - ending1Index!);
        }
      }
    }
  }
}

int _calcStaveCount(int barCount) => ((barCount / 8).ceil() / 2).ceil();

int _calcStaveIndex(int barIndex) => barIndex ~/ 8;

List<Quaver>? _createQuavers(Map<String, dynamic> json, String voice) =>
    json.containsKey(voice)
        ? List<Quaver>.from(json[voice].map((q) => Quaver.fromJson(q)))
        : null;

class Bar {
  final String? chord;

  final List<String>? phrases;
  final List<Quaver>? bass, vocal, backing, harmony, snare, arp;

  final bool? preferHarmony;
  final bool pad;

  final bool repeatLeft;
  final int repeatRight;

  final String? ending;

  Bar.fromJson(Map<String, dynamic> json)
      : chord = json['chord'],
        phrases = _createPhrases(json),
        bass = _createQuavers(json, 'bass'),
        vocal = _createQuavers(json, 'vocal'),
        backing = _createQuavers(json, 'backing'),
        harmony = _createQuavers(json, 'harmony'),
        snare = _createQuavers(json, 'snare'),
        arp = _createQuavers(json, 'arp'),
        preferHarmony = json['preferHarmony'],
        pad = json.containsKey('pad') ? json['pad'] : false,
        repeatLeft = json['repeat'] == 'Left',
        repeatRight = _parseRepeat(json),
        ending = json['ending'];

  List<Quaver>? getQuavers(String voice) {
    switch (voice) {
      case 'bass':
        return bass;
      case 'vocal':
        return vocal;
      case 'backing':
        return backing;
      case 'harmony':
        return harmony;
      case 'snare':
        return snare;
      case 'arp':
        return arp;
    }
    return null;
  }
}

int _parseRepeat(Map<String, dynamic> json) {
  if (!json.containsKey('repeat')) {
    return 0;
  }

  final String s = json['repeat'];
  final length = s.length;

  if (!s.startsWith('Right')) {
    return 0;
  }

  if (length == 5) {
    return 1;
  }

  final String n = s.split(' ')[1];
  return int.parse(n);
}

List<String>? _createPhrases(Map<String, dynamic> json) {
  List<String>? phrases;

  if (json.containsKey('verses')) {
    phrases = <String>[];

    final verses = json['verses'][0];

    for (int i = 0; i < 4; ++i) {
      final key = 'verse $i';

      if (verses.containsKey(key)) {
        final phrase = shorten(verses[key]);

        if (phrase.isNotEmpty) {
          phrases.add(phrase);
        }
      } else {
        break;
      }
    }
  } else if (json.containsKey('shareds')) {
    phrases = <String>[];

    final shared = json['shareds'][0]['shared'];
    phrases.add(shorten(shared));
  } else if (json.containsKey('restates')) {
    // TODO restates
  }
  return phrases;
}

String shorten(String phrase) {
  final list = phrase.split('#');

  phrase = list[0] == ';' ? '' : list[0];

  for (String deliminator in [' ', '/']) {
    if (phrase.contains(deliminator)) {
      phrase = phrase.split(deliminator)[0];
    }
  }
  return phrase;
}

class Quaver {
  final int? pitch;

  final String? accidental;
  final bool triplet;

  final int? duration;

  Quaver.fromJson(Map<String, dynamic> json)
      : pitch = json['pitch'],
        accidental = json['accidental'],
        triplet = json.containsKey('triplet'),
        duration = json['duration'];

  @override
  String toString() {
    return "${pitch ?? ''},${accidental ?? ''}";
  }
}
