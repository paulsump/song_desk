// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/scheduler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
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
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void _play() {
    // TODO REMOVe this
    player.play('piano.mf.ab1.wav');

    for (int i = 0; i < fileNames.length; ++i) {
      scheduler.add(
          Event(start: time + Duration(seconds: i), fileName: fileNames[i]));
    }

    // TODO try removing this
    setState(() {});
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
