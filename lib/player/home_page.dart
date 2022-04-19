// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:song_desk/loader/convert.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/note.dart';
import 'package:song_desk/player/scheduler.dart';

const noWarn = out;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  Duration _time = Duration.zero;
  Duration _playTime = Duration.zero;

  final _scheduler = Scheduler();
  final _notes = Notes();

  final persist = Persist();
  final convert = Convert();

  @override
  void initState() {
    super.initState();

    _init();

    _ticker = createTicker((elapsed) {
      _time = elapsed;

      _scheduler.update(_time - _playTime);
    });

    _ticker.start();
  }

  void _init() async {
    await _loadSongs();
    await _notes.preLoad();

    await convert.init();
    _addNotes();
    // _addEvents();
  }

  void _addNotes() {
    // final song = persist.songs['Age Aint Nothing But a Number'];
    // swing, preferHarmony
    // final song = persist.songs['Pure Sorrow'];
    //TODO key changes
    //TODO Repeats
    // final song = persist.songs['Golden Lady'];
    // TODO BAss
    // final song = persist.songs['Enjoy the Silence'];
    // final song = persist.songs['Another Star'];
    // final song = persist.songs['Silly Games'];
    // triplets
    // final song = persist.songs['Declaration Of Rights'];
    //TODO key changes, pads
    final song = persist.songs['Fantasy'];

    if (song != null) {
      int b = 0;

      for (final bar in song.bars) {
        final backing = (bar.preferHarmony || bar.backing == null)
            ? bar.harmony
            : bar.backing;

        if (backing != null) {
          int q = 0;

          final triplet = backing[3].triplet;

          for (final quaver in backing) {
            if (quaver.pitch != null) {
              final semitone = convert.quaverToSemitone(quaver, song.getKey(b));

              const tempo = 200;
              int t = tempo * b * 4 + q * (triplet ? (tempo * 4) ~/ 3 : tempo);

              if (q == 1 || q == 3) {
                t += tempo * song.swing ~/ 600;
              }

              final int i = semitone + 12 * 4;

              _scheduler.add(
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

              _scheduler.add(
                Event(
                  startTime: Duration(milliseconds: t * 200),
                  audioPlayer: _notes.kickAudioPlayer,
                ),
              );
            }
            q += 1;
          }
        }

        b += 1;
      }
    }
  }

  Future<void> _loadSongs() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');

    for (String folderPath in Persist.folderPaths) {
      final files = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith(folderPath));

      for (String file in files) {
        final name = file
            .replaceAll('%20', ' ')
            .replaceAll(folderPath, '')
            .replaceAll(Persist.extension, '');

        await persist.loadSong(folderPath, name);
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _play() {
    _playTime = _time;
    _scheduler.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_time',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _play,
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
