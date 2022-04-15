// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/scheduler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static final player = AudioCache();

  Duration time = Duration.zero;
  late final Ticker ticker;

  final scheduler = Scheduler();

  static const fileNames = <String>[
    'piano.mf.a2.wav',
    'piano.mf.b2.wav',
    'piano.mf.c2.wav',
  ];

  @override
  void initState() {
    super.initState();

    for (final fileName in fileNames) {
      player.load(fileName);
    }

    ticker = createTicker((elapsed) {
      setState(() {
        time = elapsed;
      });
    });

    ticker.start();

    for (int i = 0; i < fileNames.length; ++i) {
      scheduler.add(
          Event(offset: time + Duration(seconds: i), fileName: fileNames[i]));
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void _play() {
    // TODO REMOVe this
    player.play('piano.mf.ab1.wav');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$time',
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
