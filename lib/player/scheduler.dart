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

        if (!event.wantStartPlay) {
          if (endTime < currentTime) {
            //TODO fade out using setVolume
            event.stop();
          }
        } else {
          if (event.startTime < currentTime && currentTime < endTime) {
            event.play();
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

/// Note events
class Event {
  Event({
    required this.startTime,
    this.audioPlayer,
    this.function,
    this.duration,
  });

  final Duration startTime;
  final AudioPlayer? audioPlayer;

  final VoidCallback? function;
  bool get isPlaying =>
      audioPlayer != null ? audioPlayer!.state == PlayerState.PLAYING : false;
  bool wantStartPlay = true;

  final Duration? duration;

  void play() {
    function?.call();

    if (audioPlayer != null) {
      if (!wantStartPlay) {
        unawaited(audioPlayer!.seek(Duration.zero));
      } else {
        unawaited(audioPlayer!.resume());
        wantStartPlay = false;
      }
    }
  }

  void setWantStartPlay() {
    wantStartPlay = true;
  }

  void stop() {
    wantStartPlay = true;
    audioPlayer?.stop();
  }
}
