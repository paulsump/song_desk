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

  //TODO Switch this around , it's back to front
  void play() {
    for (final event in _events) {
      event.setWantPlay();
    }
  }

  void update(Duration currentTime) {
    for (final event in _events) {
      if (event.duration != null) {
        final Duration endTime = event.startTime + event.duration!;

        if (!event.wantPlay) {
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
        if (event.wantPlay && event.startTime < currentTime) {
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
//TODO     audioPlayer!.state == PlayerState.PLAYING;
  bool wantPlay = true;

  final Duration? duration;

  void play() {
    function?.call();

    if (audioPlayer != null) {
      if (!wantPlay) {
        unawaited(audioPlayer!.seek(Duration.zero));
      } else {
        unawaited(audioPlayer!.resume());
        wantPlay = false;
      }
    }
  }

  void setWantPlay() {
    wantPlay = true;
  }

  void stop() {
    wantPlay = true;
    audioPlayer?.stop();
  }
}
