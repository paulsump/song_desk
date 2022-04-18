// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:song_desk/loader/bible.dart';
import 'package:song_desk/loader/persist.dart';
import 'package:song_desk/loader/song.dart';
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
  late final Bible bible;

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
    // _addEvents();

    await _loadBible();
    _addNotes();
  }

  Future<void> _loadBible() async {
    final String response = await rootBundle.loadString('config/bible.json');

    final map = await json.decode(response);
    bible = Bible.fromJson(map);
  }

  int _quaverToSemitone(Quaver quaver, String key) {
    final pitch = quaver.pitch;

    final semitoneOffset = _getSemitoneOffset(quaver, key);

    final octave = 12 * ((pitch! - 1) ~/ 7);
    return semitoneOffset + octave;
  }

  int _getSemitoneOffset(Quaver quaver, String key) {
    final pitch = quaver.pitch;

    final accidental = quaver.accidental;
    int semitoneOffset = 0;

    for (final note in bible.keys[key]!.notes) {
      if (accidental == note.accidental) {
        final pitchOffset = note.pitch;

        if (_isPitchInAnyOctaveOf(pitch!, pitchOffset)) {
          return semitoneOffset;
        }
      }

      semitoneOffset += 1;
    }

    return semitoneOffset;
  }

  bool _isPitchInAnyOctaveOf(int pitch, pitchOffset) {
    final octaves = {-35, -28, -21, -14, -7, 0, 7, 14, 21, 28, 35};

    for (final octave in octaves) {
      if (pitchOffset == pitch + octave) {
        return true;
      }
    }
    return false;
  }

  void _addNotes() {
    final song = persist.songs['Age Aint Nothing But a Number'];

    if (song != null) {
      final key = song.key;

      int b = 0;
      for (final bar in song.bars) {
        final vocal = bar.vocal;

        if (vocal != null) {
          int q = 0;

          for (final quaver in vocal) {
            if (quaver.pitch != null) {
              final semitone = _quaverToSemitone(quaver, key);
              // out("${quaver.pitch}:$semitone");

              final int t = b * 4 + q;
              final int i = semitone + 12;

              _scheduler.add(
                Event(
                  startTime: Duration(milliseconds: t * 200),
                  audioPlayer: _notes.list[i].audioPlayer,
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
