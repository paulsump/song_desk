// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final songNotifier = getSongNotifier(context, listen: false);

      songNotifier.init();

      _ticker = createTicker((elapsed) {
        _time = elapsed;

        songNotifier.update(_time - _playTime);
      });

      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _playNext() {
    _playTime = _time;

    final songNotifier = getSongNotifier(context, listen: false);
    songNotifier.playNext();
  }

  @override
  Widget build(BuildContext context) {
    final songNotifier = getSongNotifier(context, listen: true);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              songNotifier.currentSongTitle,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playNext,
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}
