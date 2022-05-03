// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';
import 'package:song_desk/view/buttons.dart';
import 'package:song_desk/view/mute_list_view.dart';
import 'package:song_desk/view/song_list_view.dart';

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

      unawaited(songNotifier.init(
        playFun: () {
          _playTime = _time;

          playing = true;
        },
        stopFun: () => playing = false,
      ));

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

  @override
  Widget build(BuildContext context) {
    final songNotifier = getSongNotifier(context, listen: true);

    return Scaffold(
      key: Buttons.scaffoldStateKey,
      body: Center(
        child: !songNotifier.isReady
            ? Text('Loading Songs...',
                style: Theme.of(context).textTheme.headline4)
            : SongListView(),
      ),
      floatingActionButton: const Buttons(),
      endDrawer: const Drawer(child: MuteListView()),
    );
  }

}

