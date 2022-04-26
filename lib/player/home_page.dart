// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

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

  bool playing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final songNotifier = getSongNotifier(context, listen: false);

      unawaited(songNotifier.init());

      _ticker = createTicker((elapsed) {
        _time = elapsed;

        if (playing) {
          songNotifier.update(_time - _playTime);
        }
      });

      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _stop() => playing = false;

  @override
  Widget build(BuildContext context) {
    final songNotifier = getSongNotifier(context, listen: true);

    return Scaffold(
      body: Center(
        child: ListView.builder(
            itemCount: SongNotifier.titles.length,
            itemBuilder: (context, index) {
              final String title = SongNotifier.titles[index];
              return ListTile(
                onTap: () => songNotifier.playIndex(index, _time),
                title: Text(
                  title,
                  style: songNotifier.currentSongTitle == title
                      ? Theme.of(context).textTheme.headline4
                      : Theme.of(context).textTheme.headline6,
                ),
              );
            }),
      ),
      floatingActionButton: !songNotifier.isReady
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: play(songNotifier.back),
                  child: const Icon(Icons.skip_previous),
                ),
                FloatingActionButton(
                  onPressed: play(songNotifier.play),
                  child: const Icon(Icons.play_arrow_rounded),
                ),
                FloatingActionButton(
                  onPressed: play(songNotifier.forward),
                  child: const Icon(Icons.skip_next),
                ),
                FloatingActionButton(
                  onPressed: _stop,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
    );
  }

  VoidCallback play(void Function(Duration time) fun) => () {
        fun(_time);

        _playTime = _time;
        playing = true;
      };
}
