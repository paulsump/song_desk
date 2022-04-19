// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:song_desk/player/home_page.dart';
import 'package:song_desk/player/song_notifier.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SongNotifier()),
        ],
        child: MaterialApp(
        home: WillPopScope(
          onWillPop: () async => false,
          child: const HomePage(),
        ),
      ),
    );
  }
}
