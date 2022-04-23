import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:song_desk/out.dart';

class Scheduler {
  Scheduler();

  final _events = <Event>[];

  void add(Event event) {
    _events.add(event);
  }

  void play() {
    for (final event in _events) {
      event.setWantStartPlay();
    }
  }

  void update(Duration currentTime) {
    for (final event in _events) {
      if (event.duration != null) {
        final Duration endTime = event.startTime + event.duration!;

        if (event.startTime < currentTime && currentTime < endTime) {
          if (event.wantStartPlay) {
            event.play();
          }
        } else {
          if (!event.wantStartPlay) {
            //TODO fade out using setVolume
            event.stop();
          }
        }
      } else {
        if (event.wantStartPlay && event.startTime < currentTime) {
          event.play();
        }
      }
    }
  }
}

/// Note events.
abstract class Event {
  Event({
    required this.startTime,
    this.duration,
  });

  final Duration startTime;
  bool wantStartPlay = true;

  final Duration? duration;

  void play();

  void setWantStartPlay() {
    wantStartPlay = true;
  }

  void stop() {
    wantStartPlay = true;
  }
}

/// e.g. a call back to go to the next track.
class FunctionEvent extends Event {
  FunctionEvent({
    required Duration startTime,
    required this.function,
  }) : super(startTime: startTime);

  final VoidCallback function;

  @override
  void play() {
    function();
  }
}

/// Play a sample for an optional duration.
class AudioEvent extends Event {
  AudioEvent({
    required Duration startTime,
    Duration? duration,
    this.audioPlayer,
  }) : super(startTime: startTime, duration: duration);

  final AudioPlayer? audioPlayer;

  @override
  void play() {
    if (audioPlayer != null) {
      if (!wantStartPlay) {
        unawaited(audioPlayer!.seek(Duration.zero));
      } else {
        unawaited(audioPlayer!.resume());
        wantStartPlay = false;
      }
    }
  }

  @override
  void stop() {
    super.stop();
    audioPlayer?.stop();
  }
}
