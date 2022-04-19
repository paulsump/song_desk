// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:audioplayers/audioplayers.dart';
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
  Scheduler get currentScheduler => _schedulers[currentSongTitle]!;

  String get currentSongTitle => titles[currentIndex];
  int currentIndex = 0;

  final _schedulers = <String, Scheduler>{};
  final _piano = Piano();

  final _kick = Kick();
  final _bass = Bass();

  final _persist = Persist();
  final _convert = Convert();

  final titles = [
    // 'All Bass',
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
    play();

    notifyListeners();
  }

  void play() {
    currentScheduler.play();
  }

  void init() async {
    await _persist.loadSongs();

    await _piano.preLoad();
    await _kick.preLoad();

    await _bass.preLoad();
    await _convert.init();

    if (currentSongTitle.startsWith('All ')) {
      final scheduler = Scheduler();

      _schedulers[currentSongTitle] = scheduler;
      _scheduleAllNotes(scheduler, _bass.list);
    } else {
      for (final entry in _persist.songs.entries) {
        final scheduler = Scheduler();

        final name = entry.key;
        _schedulers[name] = scheduler;

        _scheduleNotes(scheduler, entry.value!);
      }
    }
  }

  void _scheduleNotes(scheduler, song) {
    const tempo = 200;

    int b = 0;
    int pads = 0;

    for (final bar in song.bars) {

      _addQuavers(bar.bass, song, b, pads, tempo, scheduler, (semitone) {
        final int i = semitone + 12 * 2;
        return _bass.list[i].audioPlayer;
      });

      final backing = (bar.preferHarmony || bar.backing == null)
          ? bar.harmony
          : bar.backing;

      _addQuavers(backing, song, b, pads, tempo, scheduler, (semitone) {
        final int i = semitone + 12 * 4;
        return _piano.list[i].audioPlayer;
      });
      _addQuavers(bar.snare, song, b, pads, tempo, scheduler,
          (semitone) => _kick.audioPlayer);

      if (bar.pad) {
        ++pads;
      } else {
        ++b;
      }
    }
  }

  void _addQuavers(quavers, song, int b, int pads, int tempo, scheduler, fun) {
    if (quavers != null) {
      int q = 0;

      final triplet = quavers[3].triplet;

      for (final quaver in quavers) {
        if (quaver.pitch != null) {
          final semitone =
              _convert.quaverToSemitone(quaver, song.getKey(b + pads));

          int t = tempo * b * 4 + q * (triplet ? (tempo * 4) ~/ 3 : tempo);

          if (q == 1 || q == 3) {
            t += tempo * song.swing ~/ 600;
          }

          _addNote(scheduler, t, fun(semitone));
        }
        q += 1;
      }
    }
  }

  void _addNote(scheduler, int t, AudioPlayer audioPlayer) {
    scheduler.add(
      Event(
        startTime: Duration(milliseconds: t),
        audioPlayer: audioPlayer,
      ),
    );
  }
}

/// for initial testing schedule all the instrument's notes.
void _scheduleAllNotes(Scheduler scheduler, List<Note> list) {
  for (int i = 0; i < list.length; ++i) {
    scheduler.add(
      Event(
        startTime: Duration(milliseconds: i * 700),
        audioPlayer: list[i].audioPlayer,
      ),
    );
  }
}
