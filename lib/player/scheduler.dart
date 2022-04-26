import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/event.dart';

const noWarn = out;

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
          // TODO removing this wantStartPlay fixes the tests
          if (!event.wantStartPlay) {
            // TODO fade out using setVolume
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

  void scrub(Duration currentTime) {
    for (final event in _events) {
      /// TODO make all notes have a duration (reality of a sample)
      final Duration endTime = event.startTime + event.duration!;

      if (event.startTime < currentTime && currentTime < endTime) {
        if (!event.began) {
          event.begin();
        }
      } else {
        event.end();
      }
    }

    // stop events that have playCount[eventId] == 0
    // eventId is inst+pitch
  }
}
