// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';
import 'package:song_desk/preferences.dart';

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
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final songNotifier = getSongNotifier(context, listen: false);

      unawaited(songNotifier.init(() {
        _playTime = _time;

        playing = true;
      }));

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

    if (songNotifier.isReady) {
      WidgetsBinding.instance?.addPostFrameCallback((_) =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent *
              songNotifier.currentSongPositionFactor));
    }

    return Scaffold(
      key: scaffoldStateKey,
      body: Center(
        child: !songNotifier.isReady
            ? Text('Loading Songs...',
                style: Theme.of(context).textTheme.headline4)
            : ListView.builder(
                controller: _scrollController,
                itemCount: SongNotifier.titles.length,
                itemBuilder: (context, index) {
                  final String title = SongNotifier.titles[index];
                  return ListTile(
                    onLongPress: () => songNotifier.playIndex(index),
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
          ? _buildMenuButton()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _Button(fun: songNotifier.back, icon: Icons.skip_previous),
                _Button(fun: songNotifier.play, icon: Icons.play_arrow_rounded),
                _Button(fun: songNotifier.forward, icon: Icons.skip_next),
                _Button(fun: _stop, icon: Icons.stop),
                _buildMenuButton(),
              ],
            ),
      endDrawer: Drawer(
          child: ListView(
        children: [
          for (final voice in allMutes)
            CheckboxListTile(
              title: Text(voice.capitalize(),
                  style: const TextStyle(fontSize: 28)),
              value: !Preferences.isMuted(voice),
              onChanged: (bool? value) {
                setState(() {
                  Preferences.toggleMute(voice);

                  if ('countIn' == voice) {
                    final songNotifier =
                        getSongNotifier(context, listen: false);

                    songNotifier.rescheduleAllSongNotes();
                  }
                });
              },
            )
        ],
      )),
    );
  }

  Widget _buildMenuButton() => _Button(
      fun: () => scaffoldStateKey.currentState!.openEndDrawer(), icon: Icons.menu);
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

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
