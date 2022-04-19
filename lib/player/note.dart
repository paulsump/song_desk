import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:song_desk/out.dart';

const noWarn = out;
final _audioCache = AudioCache();

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

/// loads and plays notes.
/// TODO extract PianoNotes from Player
class Notes {
  final list = <Note>[];

  late AudioPlayer kickAudioPlayer;

  Future<void> preLoad() async {
    kickAudioPlayer = await _createAudioPlayer('kick.wav');
    kickAudioPlayer.setVolume(0.3);

    const letters = [
      'c',
      'db',
      'd',
      'eb',
      'e',
      'f',
      'gb',
      'g',
      'ab',
      'a',
      'bb',
      'b',
    ];

    const octaves = [1, 2, 3, 4, 5, 6];

    for (final octave in octaves) {
      for (final letter in letters) {
        final fileName = 'piano.mf.$letter$octave.wav';

        list.add(Note(
          letter: letter,
          octave: octave,
          audioPlayer: await _createAudioPlayer(fileName),
        ));
      }
    }
  }
}

Future<AudioPlayer> _createAudioPlayer(String fileName) async {
  final url = await _audioCache.load(fileName);

  // LOW_LATENCY seems to be needed to replay
  final audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  // prepare the player with this audio but do not start playing
  unawaited(audioPlayer.setUrl(url.path));

  // set release mode so that it never releases (I can't hear effect though currently)
  unawaited(audioPlayer.setReleaseMode(ReleaseMode.STOP));
  return audioPlayer;
}
