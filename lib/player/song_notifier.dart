// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_desk/loader/convert.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/calc_duration.dart';
import 'package:song_desk/player/event.dart';
import 'package:song_desk/player/samples.dart';
import 'package:song_desk/player/scheduler.dart';
import 'package:song_desk/preferences.dart';

const noWarn = out;

SongNotifier getSongNotifier(BuildContext context, {required bool listen}) =>
    Provider.of<SongNotifier>(context, listen: listen);

/// Access to prepared songs
class SongNotifier with ChangeNotifier {
  Scheduler get _currentScheduler => _schedulers[currentSongTitle]!;

  String get currentSongTitle => titles[_currentSongIndex];
  Song get currentSong => _persist.songs[currentSongTitle]!;

  double get currentSongPositionFactor => _currentSongIndex / titles.length;
  int _currentSongIndex = 0;

  final _schedulers = <String, Scheduler>{};

  final _instruments = <String, Instrument>{
    'Piano': Piano(),
    'Kick': Kick(),
    'Bass': Bass(),
    'Arp': Arp(),
  };

  final _persist = Persist();
  final _convert = Convert();

  bool get isReady => _schedulers.isNotEmpty;
  late VoidCallback _playFun, _stopFun;

  void update(Duration time) {
    if (_schedulers.containsKey(currentSongTitle)) {
      _currentScheduler.update(time);
    }
  }

  void playIndex(int index) {
    _currentSongIndex = index;

    _playAndSavePreferences();
  }

  void back() {
    --_currentSongIndex;

    if (_currentSongIndex < 0) {
      _currentSongIndex = titles.length - 1;
    }

    _playAndSavePreferences();
  }

  void forward() {
    ++_currentSongIndex;

    if (titles.length <= _currentSongIndex) {
      _currentSongIndex = 0;
    }
    _playAndSavePreferences();
  }

  void _playAndSavePreferences() {
    play();

    notifyListeners();
    Preferences.setInt('currentSongIndex', _currentSongIndex);
  }

  void play() {
    _playFun();

    _currentScheduler.play();
  }

  void stop() => _stopFun();

  Future<void> init({
    required VoidCallback playFun,
    required VoidCallback stopFun,
  }) async {
    await _persist.loadSongs();

    for (final Instrument instrument in _instruments.values) {
      await instrument.preLoad();
    }

    await _convert.init();
    rescheduleAllSongNotes();

    _currentSongIndex = Preferences.getInt('currentSongIndex') ?? 0;

    _playFun = playFun;
    _stopFun = stopFun;

    play();
    notifyListeners();
  }

  void rescheduleAllSongNotes() {
    _schedulers.clear();

    for (final entry in _persist.songs.entries) {
      _scheduleNotes(entry.key, entry.value!);
    }
  }

  void _scheduleNotes(String songName, Song song) {
    final scheduler = Scheduler();

    _schedulers[songName] = scheduler;

    final int quaverDuration = 30000 ~/ song.tempo;
    final int barDuration = quaverDuration * 4;

    AudioPlayer _piano4(semitone) =>
        _instruments['Piano']!.getPlayer(semitone, 4);
    AudioPlayer _piano5(semitone) =>
        _instruments['Piano']!.getPlayer(semitone, 5);

    int b = 0;
    int pads = 0;

    for (final bar in song.bars) {
      _addQuavers(bar.bass, song, b, pads, quaverDuration, scheduler,
          (semitone) => _instruments['Bass']!.getPlayer(semitone, 2), 'bass');

      _addQuavers(bar.vocal, song, b, pads, quaverDuration, scheduler, _piano5,
          'vocal');

      if (bar.preferHarmony != null) {
        final opposite = bar.preferHarmony! ? bar.backing : bar.harmony;

        _addQuavers(opposite, song, b, pads, quaverDuration, scheduler, _piano4,
            'leftover');
      }

      _addQuavers(bar.backing, song, b, pads, quaverDuration, scheduler,
          _piano4, 'backing');

      _addQuavers(bar.harmony, song, b, pads, quaverDuration, scheduler,
          _piano5, 'harmony');

      _addQuavers(bar.snare, song, b, pads, quaverDuration, scheduler,
          (semitone) => _instruments['Kick']!.getPlayer(semitone, 0), 'snare');

      _addQuavers(bar.arp, song, b, pads, quaverDuration, scheduler,
          (semitone) => _instruments['Arp']!.getPlayer(semitone, 5), 'arp');

      // TODO Honour songEnd

      if (bar.repeatRight > 0) {
        scheduler.add(RepeatEvent(
          startTime: Duration(milliseconds: b * barDuration),
          duration: Duration(milliseconds: bar.repeatDuration * barDuration),
          count: bar.repeatRight,
        ));
      } else if (bar.ending != null) {
        scheduler.add(EndingEvent(
          startTime: Duration(milliseconds: b * barDuration),
          duration: Duration(milliseconds: bar.endingDuration * barDuration),
        ));
      }

      if (bar.pad) {
        ++pads;
      } else {
        ++b;
      }
    }

    if (!Preferences.isMuted('countIn')) {
      b += 8;

      // final bool triplet =
      //     ['How Can You Mend A Broken Heart'].contains(songName);

      _addCountInEvents(scheduler, b, quaverDuration, false);
      b += 2;
    } else {
      b += 2;
    }

    _addPlayNextEvent(scheduler, quaverDuration * b * 4);
  }

  void _addQuavers(quavers, song, int b, int pads, int quaverDuration,
      scheduler, getPlayer, voice) {
    if (quavers != null) {
      int q = 0;

      final triplet = quavers[3].triplet;

      for (final Quaver quaver in quavers) {
        if (quaver.pitch != null) {
          final semitone =
              _convert.quaverToSemitone(quaver, song.getKey(b + pads));

          int t = quaverDuration * b * 4 +
              q * (triplet ? (quaverDuration * 4) ~/ 3 : quaverDuration);

          final double offset = panOffset(q, song, voice, triplet);
          t += (quaverDuration * offset).round();

          double? duration = quaver.duration;

          if (duration == null && voice == 'bass') {
            duration = calcDuration(b, q, voice, song.bars);
          }

          if (duration != null) {
            duration -= offset;

            duration *= quaverDuration;
          }

          _addNote(scheduler, t, getPlayer(semitone), duration, voice);
        }
        q += 1;
      }
    }
  }

  void _addNote(scheduler, int t, AudioPlayer audioPlayer, double? duration,
      String voice) {
    scheduler.add(
      AudioEvent(
        startTime: Duration(milliseconds: t),
        duration:
            duration != null ? Duration(milliseconds: duration.toInt()) : null,
        audioPlayer: audioPlayer,
        voice: voice,
      ),
    );
  }

  double panOffset(int q, Song song, String voice, bool triplet) {
    if (triplet) {
      return 0;
    } else if (voice == 'arp') {
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

  /// Count in with 5 kicks.
  void _addCountInEvents(
    Scheduler scheduler,
    int b,
    int quaverDuration,
    bool triplet,
  ) {
    for (final int bi in [0, 1, 2]) {
      for (final int q in [0, 2]) {
        _addNote(
            scheduler,
            quaverDuration * (b + bi) * 4 +
                q * (triplet ? (quaverDuration * 4) ~/ 3 : quaverDuration),
            _instruments['Kick']!.getPlayer(0, 0),
            null,
            'countIn');
      }
    }
  }

  /// Auto play next song when finish song.
  void _addPlayNextEvent(Scheduler scheduler, int startTime) {
    scheduler.add(FunctionEvent(
      startTime: Duration(milliseconds: startTime),
      function: forward,
    ));
  }

  static const titles = [
    //    'test_scheduler',
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
}
