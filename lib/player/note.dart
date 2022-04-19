import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:song_desk/out.dart';

const noWarn = out;
final _audioCache = AudioCache();

abstract class Playable {
  Playable({
    required this.audioPlayer,
    required this.playbackRate,
  });

  // TODO CALL audioPlayer.dispose()
  final AudioPlayer audioPlayer;
  final double playbackRate;

//TODO Move Event.play() to Playable because then you'll know how much to repitch

}

/// play a note
class Note extends Playable {
  Note({
    required this.letter,
    required this.octave,
    required AudioPlayer audioPlayer,
    required double playbackRate,
  }) : super(
          audioPlayer: audioPlayer,
          playbackRate: playbackRate,
        );

  final String letter;
  final int octave;
}

/// plays preloaded sample.
class Kick {
  //TODO replace with Playable
  late AudioPlayer audioPlayer;

  Future<void> preLoad() async {
    audioPlayer = await _createAudioPlayer('kick.wav');
    audioPlayer.setVolume(0.3);
  }
}

/// plays preloaded piano samples.
class Piano {
  final list = <Note>[];

  Future<void> preLoad() async {
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
          playbackRate: 1,
        ));
      }
    }
  }
}

/// plays preloaded double bass samples.
class Bass {
  final list = <Note>[];

  Future<void> preLoad() async {
    const letters = [
      'C',
      'Db',
      'D',
      'Eb',
      'E',
      'F',
      'Gb',
      'G',
      'Ab',
      'A',
      'Bb',
      'B',
    ];

    const octaves = [1, 2, 3];

    for (final octave in octaves) {
      for (final letter in letters) {
        final fileName = 'bass_$letter$octave.wav';

        if (fileName == 'bass_Ab3.wav') {
          break;
        }
        try {
          list.add(Note(
            letter: letter,
            octave: octave,
            audioPlayer: await _createAudioPlayer(fileName),
            //TODO Set           playbackRate:
            playbackRate: 1,
          ));
        } catch (e) {
          logError('Failed to load $fileName');
        }
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
