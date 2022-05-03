// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();

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
      key: _scaffoldStateKey,
      body: Center(
        child: !songNotifier.isReady
            ? Text('Loading Songs...',
                style: Theme.of(context).textTheme.headline4)
            : SongListView(),
      ),
      floatingActionButton: !songNotifier.isReady
          ? _buildMenuButton()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _Button(fun: songNotifier.back, icon: Icons.skip_previous),
                _Button(fun: songNotifier.play, icon: Icons.play_arrow_rounded),
                _Button(fun: songNotifier.forward, icon: Icons.skip_next),
                _Button(fun: songNotifier.stop, icon: Icons.stop),
                _buildMenuButton(),
              ],
            ),
      endDrawer: const Drawer(child: MuteListView()),
    );
  }

  Widget _buildMenuButton() => _Button(
      fun: () => _scaffoldStateKey.currentState!.openEndDrawer(),
      icon: Icons.menu);
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.fun,
    required this.icon,
  }) : super(key: key);

  final VoidCallback fun;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: FloatingActionButton(onPressed: fun, child: Icon(icon)),
    );
  }
}
