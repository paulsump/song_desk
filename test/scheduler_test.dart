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

  group('calcDuration n = 2', () {
    test('bass bar 1, q 2 = 2', () async {
      // expect(duration, equals(2));
    });
  });
}
