// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_desk/loader/convert.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/note.dart';
import 'package:song_desk/player/scheduler.dart';

const noWarn = out;

SongNotifier getSongNotifier(BuildContext context, {required bool listen}) =>
    Provider.of<SongNotifier>(context, listen: listen);

/// Access to prepared songs
class SongNotifier with ChangeNotifier {
  //TODO MAke nullable ?
  Scheduler get currentScheduler => _schedulers[currentSongTitle]!;

  String get currentSongTitle => titles[currentIndex];
  int currentIndex = 0;

  final _schedulers = <String, Scheduler>{};
  final _notes = Notes();

  final _persist = Persist();
  final _convert = Convert();

  final titles = [
    'Addicted',
    'Age Aint Nothing But a Number',
    'Back to Black',
    'Enjoy the Silence',
    'Flowers',
    'It Must Be Love',
    'Lay All Your Love On Me',
    'Suddenly',
    'After All',
    'Breaking Up Is Hard To Do',
    'Declaration Of Rights',
    'Everything I Own',
    'Front Door',
    'I and I',
    'Joy In The Morning',
    'Life In The Ghetto',
    'Love Me Forever',
    'Man Next Door',
    'My Conversation',
    'Never Leave Me Lonely',
    'Pure Sorrow',
    'Silly Games',
    'Sitting And Watching',
    'The Tide Is High',
    'Am I the Same Girl',
    'Another Star',
    'At Last I am Free',
    "Don't Make Me Over",
    'Fantasy',
    'Free',
    'Golden Lady',
    'How Can You Mend A Broken Heart',
    'Look What You Done For Me',
    'Love & Happiness',
    'My Cherie Amour',
    'People Make The World Go Round',
    'These Arms Of Mine',
  ];

  void update(Duration time) {
    if (_schedulers.containsKey(currentSongTitle)) {
      currentScheduler.update(time);
    }
  }

  void playNext() {
    ++currentIndex;

    currentIndex %= _schedulers.entries.length;
    currentScheduler.play();

    notifyListeners();
  }

  void init() async {
    await _persist.loadSongs();
    await _notes.preLoad();

    await _convert.init();

    for (final entry in _persist.songs.entries) {
      final scheduler = Scheduler();

      final name = entry.key;
      _schedulers[name] = scheduler;

      _scheduleNotes(entry.value!, scheduler);
    }
  }

  void _scheduleNotes(song, scheduler) {
    int b = 0;
    int pads = 0;

    for (final bar in song.bars) {
      final backing = (bar.preferHarmony || bar.backing == null)
          ? bar.harmony
          : bar.backing;

      if (backing != null) {
        int q = 0;

        final triplet = backing[3].triplet;

        for (final quaver in backing) {
          if (quaver.pitch != null) {
            final semitone =
                _convert.quaverToSemitone(quaver, song.getKey(b + pads));

            const tempo = 200;
            int t = tempo * b * 4 + q * (triplet ? (tempo * 4) ~/ 3 : tempo);

            if (q == 1 || q == 3) {
              t += tempo * song.swing ~/ 600;
            }

            final int i = semitone + 12 * 4;

            scheduler.add(
              Event(
                startTime: Duration(milliseconds: t),
                audioPlayer: _notes.list[i].audioPlayer,
              ),
            );
          }
          q += 1;
        }
      }

      final snare = bar.snare;
      if (snare != null) {
        int q = 0;

        for (final quaver in snare) {
          if (quaver.pitch != null) {
            final int t = b * 4 + q;

            scheduler.add(
              Event(
                startTime: Duration(milliseconds: t * 200),
                audioPlayer: _notes.kickAudioPlayer,
              ),
            );
          }
          ++q;
        }
      }

      if (bar.pad) {
        ++pads;
      } else {
        ++b;
      }
    }
  }
}
