// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/player/note.dart';
import 'package:song_desk/out.dart';
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
    // await _notes.preLoad();
    // _addEvents();

    await _loadSongs();

    final song = persist.songs['Age Aint Nothing But a Number'];
    if (song != null) {
      for (final bar in song.bars) {
        final vocal = bar.vocal;

        if (vocal != null) {
          out(vocal);
        }
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

  void _addEvents() {
    for (int i = 0; i < _notes.list.length; ++i) {
      _scheduler.add(
        Event(
          startTime: Duration(milliseconds: i * 200),
          audioPlayer: _notes.list[i].audioPlayer,
        ),
      );
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
