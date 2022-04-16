// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/note.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/scheduler.dart';

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
    await _notes.preLoad();
    _addEvents();
  }

  void _addEvents() {
    int count = 0;

    for (final letter in letters) {
      for (final octave in octaves) {
        final Note? note = _notes.getNote(letter, octave);

        if (note != null) {
          _scheduler.add(
            Event(
              startTime: Duration(milliseconds: count * 400),
              audioPlayer: note.audioPlayer,
            ),
          );
        }
        ++count;
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
