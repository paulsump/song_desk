import 'dart:async';

import 'package:song_desk/home_page.dart';

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
      }
    }
  }
}

/// Note events
class Event {
  Event({required this.startTime, required this.fileName});

  final Duration startTime;
  final String fileName;

  bool isPlaying = false;

  void play() {
    unawaited(audioCache.play(fileName));
    isPlaying = true;
  }

  void reset() {
    isPlaying = false;
  }
}
