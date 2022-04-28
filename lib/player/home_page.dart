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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

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

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: ListView.builder(
            itemCount: SongNotifier.titles.length,
            itemBuilder: (context, index) {
              final String title = SongNotifier.titles[index];
              return ListTile(
                onTap: () => songNotifier.playIndex(index),
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: songNotifier.back,
                  child: const Icon(Icons.skip_previous),
                ),
                FloatingActionButton(
                  onPressed: songNotifier.play,
                  child: const Icon(Icons.play_arrow_rounded),
                ),
                FloatingActionButton(
                  onPressed: songNotifier.forward,
                  child: const Icon(Icons.skip_next),
                ),
                FloatingActionButton(
                  onPressed: _stop,
                  child: const Icon(Icons.stop),
                ),
                _buildMenuButton(),
              ],
            ),
      endDrawer: Drawer(
          child: ListView(
        children: [
          for (final voice in allVoices)
            CheckboxListTile(
              title: Text(voice.capitalize(),
                  style: const TextStyle(fontSize: 28)),
              value: Preferences.isMuted(voice),
              onChanged: (bool? value) {
                setState(() {
                  // TODO fix pref seems to get lost
                  Preferences.toggleMute(voice);
                });
              },
            )
        ],
      )),
    );
  }

  FloatingActionButton _buildMenuButton() => FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
        child: const Icon(Icons.menu),
      );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
