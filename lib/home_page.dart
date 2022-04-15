// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/scheduler.dart';

final audioCache = AudioCache();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final _scheduler = Scheduler();
  Duration _time = Duration.zero;

  Duration _playTime = Duration.zero;

  static const _fileNames = <String>[
    'piano.mf.a2.wav',
    'piano.mf.b2.wav',
    'piano.mf.c2.wav',
  ];

  @override
  void initState() {
    super.initState();

    for (final fileName in _fileNames) {
      audioCache.load(fileName);
    }

    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed;
        _scheduler.update(_time - _playTime);
      });
    });

    _ticker.start();

    for (int i = 0; i < _fileNames.length; ++i) {
      _scheduler.add(
        Event(
          startTime: Duration(seconds: i),
          fileName: _fileNames[i],
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
