// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

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
  final _audioPlayers = <AudioPlayer>[];

  static const _fileNames = <String>[
    'piano.mf.a1.wav',
    'piano.mf.a2.wav',
    'piano.mf.a3.wav',
  ];

  @override
  void initState() {
    super.initState();

    _preLoad();
    _ticker = createTicker((elapsed) {
      _time = elapsed;

      final time = _time - _playTime;
      _scheduler.update(time);

      // out(time);
      // setState(() {});
    });

    _ticker.start();
  }

  void _addEvents() {
    for (int i = 0; i < _fileNames.length; ++i) {
      _scheduler.add(
        Event(
          startTime: Duration(milliseconds: i * 400),
          fileName: _fileNames[i],
          audioPlayer: _audioPlayers[i],
        ),
      );
    }
  }

  void _preLoad() async {
    for (final fileName in _fileNames) {
      final url = await audioCache.load(fileName);

      // LOW_LATENCY seems to be needed to replay
      final audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
      _audioPlayers.add(audioPlayer);

      // prepare the player with this audio but do not start playing
      unawaited(audioPlayer.setUrl(url.path));

      // set release mode so that it never releases
      // unawaited(audioPlayer.setReleaseMode(ReleaseMode.STOP));
    }

    // TODO MOve this call elsewhere
    _addEvents();
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
