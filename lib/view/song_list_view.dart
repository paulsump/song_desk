// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';

const noWarn = out;

class SongListView extends StatelessWidget {
  SongListView({Key? key}) : super(key: key);

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final songNotifier = getSongNotifier(context, listen: true);

    if (songNotifier.isReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent * songNotifier.currentSongPositionFactor));
    }

    return Center(
      child: !songNotifier.isReady
          ? Text('Loading Songs...', style: Theme.of(context).textTheme.headline4)
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
    );
  }
}
