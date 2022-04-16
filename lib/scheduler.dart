import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class Scheduler {
  Scheduler();

  final _events = <Event>[];

  void add(Event event) {
    _events.add(event);
  }

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
    required this.fileName,
    required this.audioPlayer,
  });

  final Duration startTime;
  final String fileName;

  final AudioPlayer audioPlayer;
  bool isPlaying = false;

  void play() {
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
