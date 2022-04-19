// © 2022, Paul Sumpner <sumpner@hotmail.com>

class Song {
  final List<Bar> bars;

  final String key, genre;

  Song({
    required this.bars,
    required this.key,
    required this.genre,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final bars = json["bars"];

    return Song(
      bars: List<Bar>.from(bars.map((source) => Bar.fromJson(source))),
      key: json['key'],
      genre: json['genre'],
    );
  }
}

class Bar {
  final String? chord;

  final List<String>? phrases;
  final List<Quaver>? vocal,backing;

  Bar({this.chord, this.phrases, this.vocal,this.backing});

  factory Bar.fromJson(Map<String, dynamic> json) {
    try {
      List<Quaver>? vocal;

      if (json.containsKey('vocal')) {
        var q = json['vocal'];
        vocal = List<Quaver>.from(q.map((source) => Quaver.fromJson(source)));
      }

      List<Quaver>? backing;

      if (json.containsKey('backing')) {
        var q = json['backing'];
        backing = List<Quaver>.from(q.map((source) => Quaver.fromJson(source)));
      }

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

      return Bar(
        chord: json['chord'],
        phrases: phrases,
        vocal: vocal,
        backing: backing,
      );
    } catch (e) {
      return Bar(chord: "667");
    }
  }

  static String shorten(String phrase) {
    var list = phrase.split('#');
    phrase = list[0] == ';' ? '' : list[0];

    for (String deliminator in [' ', '/']) {
      if (phrase.contains(deliminator)) {
        phrase = phrase.split(deliminator)[0];
      }
    }
    return phrase;
  }
}

class Quaver {
  final int? pitch;
  final String? accidental;

  Quaver({this.pitch, this.accidental});

  factory Quaver.fromJson(Map<String, dynamic> json) {
    try {
      return Quaver(
        pitch: json['pitch'],
        accidental: json['accidental'],
      );
    } catch (e) {
      return Quaver(pitch: 668);
    }
  }

  @override
  String toString() {
    return "${pitch ?? ''},${accidental ?? ''}";
  }
}
