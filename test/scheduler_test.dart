// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/player/calc_duration.dart';
import 'package:song_desk/player/scheduler.dart';

/// Test [Scheduler] update() to see if events are called
/// specifically, is event.stop() called after duration is up?
void main() {
  final scheduler = Scheduler();

  final events = <_MockEvent>[];

  for (int i = 0; i < 2; ++i) {
    final event = _MockEvent(
      startTime: Duration(seconds: i),
      duration: const Duration(seconds: 1),
    );

    scheduler.add(event);
    events.add(event);
  }

  group('stopWasCalled', () {
    // test('update 0 -> false', () async {
    //   scheduler.update(const Duration(milliseconds:0));
    //   expect(events[0].stopWasCalled, false);
    // });

    test('update 1001 -> true', () async {
      scheduler.update(const Duration(milliseconds:1001));
      expect(events[0].stopWasCalled, true);
    });

    // test('update 0, 1001 -> true', () async {
    //   scheduler.update(const Duration(milliseconds:0));
    //   expect(events[0].stopWasCalled, false);
    //
    //   scheduler.update(const Duration(milliseconds:1001));
    //   expect(events[0].stopWasCalled, true);
    // });
    //
    // test('play, update 0, 1001 -> true', () async {
    //   scheduler.play();
    //
    //   scheduler.update(const Duration(milliseconds:0));
    //   expect(events[0].stopWasCalled, false);
    //
    //   scheduler.update(const Duration(milliseconds:1001));
    //   expect(events[0].stopWasCalled, true);
    // });
  });
}

/// For testing, lets test know that stop was called.
class _MockEvent extends Event {
  _MockEvent({
    required Duration startTime,
    Duration? duration,
  }) : super(startTime: startTime, duration: duration);

  bool stopWasCalled = false;

  @override
  void play() {
    if (!wantStartPlay) {
    } else {
      wantStartPlay = false;
    }
  }

  @override
  void stop() {
    super.stop();

    //TODO LEt test know we got here
    stopWasCalled = true;
  }
}
