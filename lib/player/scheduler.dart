import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

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
  });

  final Duration startTime;
  final AudioPlayer audioPlayer;

  bool isPlaying = false;

  //TODO Move Event.play() to Playable because then you'll know how much to repitch
  //TODO remove async if not setplaybackrate()
  void play() async {
    if (isPlaying) {
      unawaited(audioPlayer.seek(Duration.zero));
    } else {
      await audioPlayer.resume();

      // await audioPlayer.setPlaybackRate(2);
      isPlaying = true;
    }
  }

  void reset() {
    isPlaying = false;
  }
}
