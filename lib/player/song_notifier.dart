// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String get currentSongTitle => 'Pure Sorrow';
  final _schedulers = <String, Scheduler>{};

  final _notes = Notes();
  final _persist = Persist();

  final _convert = Convert();

  void update(Duration time) {
    if (_schedulers.containsKey(currentSongTitle)) {
      currentScheduler.update(time);
    }
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
    //TODO key changes
    //TODO Repeats
    // final song = persist.songs['Golden Lady'];
    // TODO BAss
    // final song = persist.songs['Enjoy the Silence'];
    // final song = persist.songs['Another Star'];
    // final song = persist.songs['Silly Games'];
    // triplets
    // final song = persist.songs['Declaration Of Rights'];
    // key changes, pads
    // final song = _persist.songs['Fantasy'];

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
