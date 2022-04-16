import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class Scheduler {
  Scheduler();

  final _events = <Event>[];
  bool _isPlaying = false;

  void add(Event event) {
    _events.add(event);
  }

  void play() {
    _isPlaying = true;

    for (final event in _events) {
      event.reset();
    }
  }

  void update(Duration currentTime) {
    for (final event in _events) {
      if (!event.isPlaying && event.startTime < currentTime) {
        event.play();

        // out('P: $currentTime');
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
    isPlaying = true;
    unawaited(audioPlayer.resume());
  }

  void reset() {
    isPlaying = false;
  }
}
