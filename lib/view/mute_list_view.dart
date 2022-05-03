// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';
import 'package:song_desk/preferences.dart';
import 'package:song_desk/view/song_list_view.dart';

const noWarn = out;

class MuteListView extends StatefulWidget {
  const MuteListView({Key? key}) : super(key: key);

  @override
  State<MuteListView> createState() => _MuteListViewState();
}

class _MuteListViewState extends State<MuteListView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final voice in allMutes)
          CheckboxListTile(
            title:
                Text(voice.capitalize(), style: const TextStyle(fontSize: 28)),
            value: !Preferences.isMuted(voice),
            onChanged: (bool? value) {
              setState(() {
                Preferences.toggleMute(voice);

                if ('countIn' == voice) {
                  final songNotifier = getSongNotifier(context, listen: false);

                  songNotifier.rescheduleAllSongNotes();
                }
              });
            },
          )
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
