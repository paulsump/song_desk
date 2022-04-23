// © 2022, Paul Sumpner <sumpner@hotmail.com>

class Song {
  final List<Bar> bars;

  final String key, genre, strum;
  final int swing, tempo;

  Map<int, String> keyChangesAtBigStaveIndices;
  bool doubleTime;

  Song.fromJson(Map<String, dynamic> json)
      : bars = List<Bar>.from(json["bars"].map((bar) => Bar.fromJson(bar))),
        key = json['key'],
        genre = json['genre'],
        swing = json.containsKey('swing') ? json['swing'] : 0,
        tempo = json['tempo'],
        doubleTime = json.containsKey('doubleTime'),
        strum = json['strum'],
        keyChangesAtBigStaveIndices = {0: json['key']} {
    calcKeyChangesAtBigStaveIndices(json);
  }

  void calcKeyChangesAtBigStaveIndices(Map<String, dynamic> json) {
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
              keyChangesAtBigStaveIndices[staveIndex] = keyChanges[staveLabel];
            }
          }
        }
      }
    }
  }

  String getKey(int barIndex) {
    String key = keyChangesAtBigStaveIndices[0]!;

    for (int i = 0; i < _calcStaveIndex(barIndex) + 1; ++i) {
      if (keyChangesAtBigStaveIndices.containsKey(i)) {
        key = keyChangesAtBigStaveIndices[i]!;
      }
    }
    return key;
  }

  bool boomClapOrDoubleReggae() {
    if (strum.contains('BoomClap')) {
      return true;
    }

    return doubleTime && strum == 'Reggae';
  }
}

int _calcStaveCount(int barCount) => ((barCount / 8).ceil() / 2).ceil();

int _calcStaveIndex(int barIndex) => barIndex ~/ 8;

List<Quaver>? _createQuavers(Map<String, dynamic> json, String voice) {
  List<Quaver>? quavers;

  if (json.containsKey(voice)) {
    quavers = List<Quaver>.from(json[voice].map((q) => Quaver.fromJson(q)));
  }
  return quavers;
}

class Bar {
  final String? chord;

  final List<String>? phrases;
  final List<Quaver>? bass, vocal, backing, harmony, snare, arp;

  final bool preferHarmony, pad;

  Bar.fromJson(Map<String, dynamic> json)
      : chord = json['chord'],
        phrases = _createPhrases(json),
        bass = _createQuavers(json, 'bass'),
        vocal = _createQuavers(json, 'vocal'),
        backing = _createQuavers(json, 'backing'),
        harmony = _createQuavers(json, 'harmony'),
        snare = _createQuavers(json, 'snare'),
        arp = _createQuavers(json, 'arp'),
        preferHarmony =
            json.containsKey('preferHarmony') ? json['preferHarmony'] : false,
        pad = json.containsKey('pad') ? json['pad'] : false;

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

List<String>? _createPhrases(Map<String, dynamic> json) {
  List<String>? phrases;

  if (json.containsKey('verses')) {
    phrases = <String>[];

    var verses = json['verses'][0];

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

    var shared = json['shareds'][0]['shared'];
    phrases.add(shorten(shared));
  } else if (json.containsKey('restates')) {
    // TODO restates
  }
  return phrases;
}

String shorten(String phrase) {
  var list = phrase.split('#');

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
