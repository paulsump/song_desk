// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String get currentSongTitle => _titles[_currentSongIndex];
  int _currentSongIndex = 0;

  final _schedulers = <String, Scheduler>{};
  final _piano = Piano();

  final _kick = Kick();
  final _bass = Bass();

  final _arp = Arp();
  final _persist = Persist();

  final _convert = Convert();
  bool get isReady => _schedulers.isNotEmpty;

  late VoidCallback _playFun;

  void update(Duration time) {
    if (_schedulers.containsKey(currentSongTitle)) {
      currentScheduler.update(time);
    }
  }

  void back() {
    --_currentSongIndex;

    if (_currentSongIndex < 0) {
      _currentSongIndex = 0;
    }
    _playAndSavePreferences();
  }

  void forward() {
    ++_currentSongIndex;

    _currentSongIndex %= _schedulers.entries.length;
    _playAndSavePreferences();
  }

  void _playAndSavePreferences() {
    play();

    notifyListeners();
    unawaited(_savePreferences());
  }

  void play() {
    _playFun();

    currentScheduler.play();
  }

  Future<void> init(VoidCallback playFun) async {
    await _persist.loadSongs();

    await _piano.preLoad();
    await _kick.preLoad();

    await _bass.preLoad();
    await _arp.preLoad();

    await _convert.init();

    for (final entry in _persist.songs.entries) {
      final scheduler = Scheduler();

      final name = entry.key;
      _schedulers[name] = scheduler;

      _scheduleNotes(scheduler, entry.value!);
    }

    await _loadPreferences();
    _playFun = playFun;

    play();
    notifyListeners();
  }

  void _scheduleNotes(scheduler, Song song) {
    final quaverDuration = 30000 ~/ song.tempo;

    AudioPlayer _pianoPlayer(semitone) {
      final int i = semitone + 12 * 4;

      return _piano.notes[i].audioPlayer;
    }

    int b = 0;
    int pads = 0;

    for (final bar in song.bars) {
      _addQuavers(bar.bass, song, b, pads, quaverDuration, scheduler,
          (semitone) {
        final int i = semitone + 12 * 2;

        return _bass.notes[i].audioPlayer;
      }, () => _bass.stopAll(), '');

      _addQuavers(bar.vocal, song, b, pads, quaverDuration, scheduler,
          _pianoPlayer, null, '');

      // final backing = (bar.preferHarmony || bar.backing == null)? bar.harmony : bar.backing;
      // _addQuavers(backing, song, b, pads, quaverDuration, scheduler, _pianoPlayer,     null, '');
      _addQuavers(bar.backing, song, b, pads, quaverDuration, scheduler,
          _pianoPlayer, null, '');

      _addQuavers(bar.harmony, song, b, pads, quaverDuration, scheduler,
          _pianoPlayer, null, '');

      _addQuavers(bar.snare, song, b, pads, quaverDuration, scheduler,
          (semitone) => _kick.audioPlayer, null, '');

      _addQuavers(bar.arp, song, b, pads, quaverDuration, scheduler,
          (semitone) {
        final int i = semitone + 12 * 5;

        return _arp.notes[i].audioPlayer;
      }, null, 'arp');

      if (bar.pad) {
        ++pads;
      } else {
        ++b;
      }
    }

    _addPlayNextEvent(scheduler, quaverDuration * b * 4);
  }

  void _addQuavers(quavers, song, int b, int pads, int quaverDuration,
      scheduler, getPlayer, function, voice) {
    if (quavers != null) {
      int q = 0;

      final triplet = quavers[3].triplet;

      for (final Quaver quaver in quavers) {
        if (quaver.pitch != null) {
          final semitone =
              _convert.quaverToSemitone(quaver, song.getKey(b + pads));

          int t = quaverDuration * b * 4 +
              q * (triplet ? (quaverDuration * 4) ~/ 3 : quaverDuration);

          if (!triplet) {
            t += (quaverDuration * panOffset(q, song, voice)).round();
          }
          _addNote(
              scheduler,
              t,
              getPlayer(semitone),
              function,
              quaver.duration != null
                  ? quaverDuration * quaver.duration!
                  : null);
        }
        q += 1;
      }
    }
  }

  double panOffset(int q, Song song, voice) {
    if (voice == 'arp') {
      final x = 0.06 * q;

      if (song.boomClapOrDoubleReggae()) {
        if (q == 0) {
          return x + 4;
        } else if (q == 1) {
          return x + 3;
        } else if (q == 2) {
          return x + 2;
        } else if (q == 3) {
          return x + 1;
        }
      } else if (song.strum == 'Reggae') {
        if (q == 0) {
          return x + 2;
        } else if (q == 1) {
          return x + 1;
        } else if (q == 2) {
          return x + 0;
        } else if (q == 3) {
          return x + -1;
        }
      }
    } else if (q == 1 || q == 3) {
      return song.swing / 600;
    }
    return 0;
  }

  void _addNote(scheduler, int t, AudioPlayer audioPlayer,
      VoidCallback? function, int? duration) {
    scheduler.add(
      Event(
          startTime: Duration(milliseconds: t),
          audioPlayer: audioPlayer,
          function: function,
          duration: duration != null ? Duration(milliseconds: duration) : null),
    );
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();

    final int? currentSongIndex_ = preferences.getInt('currentSongIndex');

    if (currentSongIndex_ != null) {
      _currentSongIndex = currentSongIndex_;
    }
  }

  Future<void> _savePreferences() async {
    final preferences = await SharedPreferences.getInstance();

    unawaited(preferences.setInt('currentSongIndex', _currentSongIndex));
  }

  ///Auto play next song when finish song.
  void _addPlayNextEvent(scheduler, int startTime) {
    scheduler.add(Event(
      startTime: Duration(milliseconds: startTime),
      function: forward,
    ));
  }
}

const _titles = [
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
  'Underneath The Arches',
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
  "I'm in the Mood for Love",
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
  'Moscow Nights',
  'Mr Benn Festive Road',
  'People Make The World Go Round',
  'It Must Be Love',
  'Blue Moon',
  'Samba em Preludio',
  'Estrada do Sol',
  'Quem Me Ve Sorrindo',
  'Este Seu Olhar',
  'O Mundo e um Moinho',
  'So em Teus Bracos',
];
