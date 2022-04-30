import 'package:song_desk/out.dart';
import 'package:song_desk/player/event.dart';
import 'package:song_desk/preferences.dart';

const noWarn = out;

class Scheduler {
  Scheduler();

  final _events = <Event>[];
  void add(Event event) => _events.add(event);

  void play() {
    for (final event in _events) {
      event.setWantStartPlay();
    }
  }

  void update(Duration currentTime_) {
    Duration currentTime = currentTime_;

    // int repeatCount = 0;

    for (final event in _events) {
      if (event is AudioEvent) {
        if (Preferences.isMuted(event.voice)) {
          continue;
        }
      } else if (event is RepeatEvent) {
        // final Duration endTime = currentTime;
        // currentTime -= event.duration!;

        // TODO reset events so that they are audible.
        // for (final event in _events) {
        //   if (event.startTime <= currentTime && currentTime < endTime) {
        //     event.setWantStartPlay();
        //   }
        // }

        //TODO USE repeatCount
        // repeatCount = event.count;
      } else if (event is EndingEvent) {
        // currentTime += event.duration!;
      }

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

  // void scrub(Duration currentTime) {
  //   for (final event in _events) {
  /// TODO make all notes have a duration (reality of a sample)
  // final Duration endTime = event.startTime + event.duration!;
  //
  // if (event.startTime < currentTime && currentTime < endTime) {
  //   if (!event.began) {
  //     event.begin();
  //   }
  // } else {
  //   event.end();
  // }
  // }

  // TODO stop events that have playCount[eventId] == 0
  // eventId is inst+pitch
  // }
}
