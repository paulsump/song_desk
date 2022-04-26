import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:song_desk/out.dart';

const noWarn = out;


/// Note events.
abstract class Event {
  Event({required this.startTime, this.duration});

  final Duration startTime;
  final Duration? duration;

  bool wantStartPlay = true;
  bool began = false;

  void begin(){began = true;}
  void end(){began = false;}

  void play();
  void setWantStartPlay() => wantStartPlay = true;

  void stop() => wantStartPlay = true;

  @override
  String toString() => '$startTime, ${duration!.inMilliseconds}';
}

/// e.g. a call back to go to the next track.
class FunctionEvent extends Event {
  FunctionEvent({
    required Duration startTime,
    required this.function,
  }) : super(startTime: startTime);

  final VoidCallback function;

  @override
  void play() => function();
}

/// Play a sample for an optional duration.
class AudioEvent extends Event {
  AudioEvent({
    required Duration startTime,
    Duration? duration,
    this.audioPlayer,
  }) : super(startTime: startTime, duration: duration);

  final AudioPlayer? audioPlayer;

  bool get _sampleIsAlreadyPlaying =>
      audioPlayer != null ? audioPlayer!.state == PlayerState.PLAYING : false;

  @override
  void play() {
    if (audioPlayer != null) {
      if (_sampleIsAlreadyPlaying) {
        // Go back to start (instead of seek(0) which isn't allowed with LOW_LATENCY).
        unawaited(audioPlayer!.stop());
      }

      unawaited(audioPlayer!.resume());
      wantStartPlay = false;
    }
  }

  @override
  void stop() {
    super.stop();

    unawaited(audioPlayer?.stop());
  }
}
