import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:song_desk/out.dart';

const noWarn = out;

/// play a note
class Note {
  Note({
    required this.letter,
    required this.octave,
    required this.audioPlayer,
  });

  final String letter;
  final int octave;

  final AudioPlayer audioPlayer;
}

const letters = [
  'ab',
  'a',
  'bb',
  'b',
  'c',
  'db',
  'd',
  // 'e',
  // 'eb',
  // 'f',
  // 'g',
  // 'gb'
];

const octaves = [1, 2, 3];
// const octaves = [1, 2, 3, 4, 5, 6];
// TODO octave 0 & 7 is missing some letters
// const octaves = [0, 1, 2, 3, 4, 5, 6, 7];

/// loads and plays notes.
class Notes {
  final list = <Note>[];

  final audioCache = AudioCache();

  // TODO optimize into two loops - or just remove this function?
  // Note? getNote(String letter, int octave) {
  //   for (final note in list) {
  //     if (letter == note.letter && octave == note.octave) {
  //       return note;
  //     }
  //   }
  //   return null;
  // }

  Future<void> preLoad() async {
    for (final octave in octaves) {
      for (final letter in letters) {
        final url = await audioCache.load('piano.mf.$letter$octave.wav');

        // LOW_LATENCY seems to be needed to replay
        final audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

        list.add(Note(
          letter: letter,
          octave: octave,
          audioPlayer: audioPlayer,
        ));

        // prepare the player with this audio but do not start playing
        unawaited(audioPlayer.setUrl(url.path));

        // set release mode so that it never releases (I can't hear effect though currently)
        unawaited(audioPlayer.setReleaseMode(ReleaseMode.STOP));
      }
    }
  }
}
