import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:song_desk/out.dart';

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

/// plays preloaded sample.
class Kick {
  // TODO CALL audioPlayer.dispose()
  late AudioPlayer audioPlayer;

  Future<void> preLoad() async {
    audioPlayer = await _createAudioPlayer('kick.wav');
    audioPlayer.setVolume(0.3);
  }
}

/// plays preloaded piano samples quietly.
class Arp extends Piano {
  @override
  Future<void> preLoad() async {
    await super.preLoad();

    for (final sample in _samples) {
      sample.audioPlayer.setVolume(0.4);
    }
  }
}

abstract class Instrument{
  List<Sample> get samples;

  Future<void> preLoad() async {}
}


/// plays preloaded piano samples.
class Piano implements Instrument{
  final _samples = <Sample>[];

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

  @override
  List<Sample> get samples => _samples;
}

/// plays preloaded double bass samples.
class Bass  implements Instrument{
  final _samples = <Sample>[];

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

          audioPlayer.setVolume(0.8);

          _samples.add(Sample(
            letter: letter,
            octave: octave,
            audioPlayer: audioPlayer,
          ));
        } catch (e) {
          logError('Failed to load $fileName');
        }
      }
    }
  }

  @override
  List<Sample> get samples => _samples;
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
