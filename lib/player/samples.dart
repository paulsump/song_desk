import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/constants.dart';

const noWarn = out;
final _audioCache = AudioCache();

/// Access to a sample of a particular note
class Sample {
  Sample({
    required this.letter,
    required this.octave,
    required this.audioPlayer,
  });

  final String letter;
  final int octave;

  // TODO CALL audioPlayer.dispose()
  final AudioPlayer audioPlayer;
}

abstract class Instrument {
  AudioPlayer getPlayer(int semitone, int octave);

  Future<void> preLoad() async {
    //TODO MAYBE set volume here
  }

// TODO CALL audioPlayer.dispose()
}

/// plays preloaded sample.
class Kick implements Instrument {
  // TODO CALL audioPlayer.dispose()
  late AudioPlayer audioPlayer;

  @override
  AudioPlayer getPlayer(int semitone, int octave) => audioPlayer;

  @override
  Future<void> preLoad() async {
    audioPlayer = await _createAudioPlayer('kick.wav');

    unawaited(audioPlayer.setVolume(Constants.bassBoost ? 0.1 : 0.1));
  }
}

/// plays preloaded piano samples quietly.
class Arp extends Piano {
  @override
  Future<void> preLoad() async {
    await super.preLoad();

    for (final sample in _samples) {
      unawaited(sample.audioPlayer.setVolume(0.4));
    }
  }
}

/// plays preloaded piano samples.
class Piano implements Instrument {
  final _samples = <Sample>[];

  @override
  AudioPlayer getPlayer(int semitone, int octave) =>
      _samples[semitone + 12 * octave].audioPlayer;

  @override
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

    const octaves = [1, 2, 3, 4, 5, 6, 7];

    for (final octave in octaves) {
      for (final letter in letters) {
        final fileName = 'piano.mf.$letter$octave.wav';

        _samples.add(Sample(
          letter: letter,
          octave: octave,
          audioPlayer: await _createAudioPlayer(fileName),
        ));
      }
    }
  }
}

/// plays preloaded double bass samples.
class Bass implements Instrument {
  final _samples = <Sample>[];

  @override
  AudioPlayer getPlayer(int semitone, int octave) =>
      _samples[semitone + 12 * octave].audioPlayer;

  @override
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
          final audioPlayer = await _createAudioPlayer(fileName);

          unawaited(audioPlayer.setVolume(Constants.bassBoost ? 0.8 : 0.2));

          _samples.add(
              Sample(letter: letter, octave: octave, audioPlayer: audioPlayer));
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
