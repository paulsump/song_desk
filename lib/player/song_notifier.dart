// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_desk/loader/convert.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';
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
    'Age Aint Nothing But a Number',
    'Flowers',
    'Lay All Your Love On Me',
    'Pure Sorrow',
    'Golden Lady',
    'Enjoy the Silence',
    'Another Star',
    'Silly Games',
    'Declaration Of Rights',
    'Fantasy',
    'I and I',
    'Life In The Ghetto',
    'Free',
    'How Can You Mend A Broken Heart',
    'Addicted',
    'Never Leave Me Lonely',
    'After All',
    'Bonita',
    'Love Me Forever',
    'My Cherie Amour',
    'Man Next Door',
    'Front Door',
    'My Conversation',
    'Breaking Up Is Hard To Do',
    'Love & Happiness',
    'These Arms Of Mine',
    "Don't Make Me Over",
    'Manha de Carnaval',
    'Look What You Done For Me',
    'Am I the Same Girl',
    'Suddenly',
    'Entrudo',
    'Joy In The Morning',
    'Outra Vez',
    'At Last I am Free',
    'Back to Black',
    'Melancolia',
    'Estate',
    'Insensatez',
    'Por Toda Minha Vida',
    'The Tide Is High',
    'Everything I Own',
    'O Barquinho',
    'Corcovado',
    'O Amor Em Paz',
    'O Sol Nascera',
    'Sitting And Watching',
    'Meditacao',
    'Samba do Aviao',
    'People Make The World Go Round',
    'It Must Be Love',
    'Samba em Preludio',
    'Estrada do Sol',
    'Quem Me Ve Sorrindo',
    'Este Seu Olhar',
    'O Mundo e um Moinho',
    'So em Teus Bracos',
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

  void _scheduleNotes(scheduler, Song song) {
    final duration = 30000 ~/ song.tempo;

    AudioPlayer _pianoPlayer(semitone) {
      final int i = semitone + 12 * 4;
      return _piano.list[i].audioPlayer;
    }

    int b = 0;
    int pads = 0;

    for (final bar in song.bars) {
      _addQuavers(bar.bass, song, b, pads, duration, scheduler, (semitone) {
        final int i = semitone + 12 * 2;
        return _bass.list[i].audioPlayer;
      }, () => _bass.stopAll());

      _addQuavers(
          bar.vocal, song, b, pads, duration, scheduler, _pianoPlayer, null);

      if (false) {
        final backing = (bar.preferHarmony || bar.backing == null)
            ? bar.harmony
            : bar.backing;

        _addQuavers(
            backing, song, b, pads, duration, scheduler, _pianoPlayer, null);
      } else {
        _addQuavers(bar.backing, song, b, pads, duration, scheduler,
            _pianoPlayer, null);

        _addQuavers(bar.harmony, song, b, pads, duration, scheduler,
            _pianoPlayer, null);
      }

      _addQuavers(bar.snare, song, b, pads, duration, scheduler,
          (semitone) => _kick.audioPlayer, null);

      _addQuavers(
          bar.arp, song, b, pads, duration, scheduler, _pianoPlayer, null);

      if (bar.pad) {
        ++pads;
      } else {
        ++b;
      }
    }
  }

  void _addQuavers(
      quavers, song, int b, int pads, int duration, scheduler, fun, fun2) {
    if (quavers != null) {
      int q = 0;

      final triplet = quavers[3].triplet;

      for (final quaver in quavers) {
        if (quaver.pitch != null) {
          final semitone =
              _convert.quaverToSemitone(quaver, song.getKey(b + pads));

          int t =
              duration * b * 4 + q * (triplet ? (duration * 4) ~/ 3 : duration);

          t += duration * panOffset(q, song, 'arp');
          _addNote(scheduler, t, fun(semitone), fun2);
        }
        q += 1;
      }
    }
  }

  int panOffset(int q, song, voice) {
    // if(! triplet):
    if (false){//voice == 'arp') {
      // final x = 0.06 * q;

      // if (q == 0) {
      //   return x + 2;
      // } else if (q == 1) {
      //   return x + 1;
      // } else if (q == 2) {
      //   return x + 0;
      // } else if (q == 3) {
      //   return x + -1;
      // }
    } else if (q == 1 || q == 3) {
      return song.swing ~/ 600;
    }
    return 0;
  }

  void _addNote(scheduler, int t, AudioPlayer audioPlayer, VoidCallback? fun) {
    scheduler.add(
      Event(
          startTime: Duration(milliseconds: t),
          audioPlayer: audioPlayer,
          fun: fun),
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
