import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class Scheduler {
  Scheduler();

  final _events = <Event>[];

  void add(Event event) {
    _events.add(event);
  }

  //TODO Switch this around , it's back to front
  void play() {
    for (final event in _events) {
      event.reset();
    }
  }

  void update(Duration currentTime) {
    for (final event in _events) {
      if (!event.isPlaying && event.startTime < currentTime) {
        event.play();
      }
    }
  }
}

/// Note events
class Event {
  Event({
    required this.startTime,
    required this.audioPlayer,
    this.fun,
  });

  final Duration startTime;
  final AudioPlayer audioPlayer;

  final VoidCallback? fun;
  bool isPlaying = false;

  void play() {
    fun?.call();

    if (isPlaying) {
      unawaited(audioPlayer.seek(Duration.zero));
    } else {
      unawaited(audioPlayer.resume());
      isPlaying = true;
    }
  }

  void reset() {
    isPlaying = false;
  }
}
