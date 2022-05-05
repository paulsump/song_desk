// © 2022, Paul Sumpner <sumpner@hotmail.com>

import 'package:flutter/material.dart';
import 'package:song_desk/out.dart';
import 'package:song_desk/player/song_notifier.dart';

const noWarn = out;

class Buttons extends StatelessWidget {
  const Buttons({Key? key}) : super(key: key);

  static final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final songNotifier = getSongNotifier(context, listen: true);

    return !songNotifier.isReady
        ? _buildMenuButtons()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Button(fun: songNotifier.back, icon: Icons.skip_previous),
              _Button(fun: songNotifier.play, icon: Icons.play_arrow_rounded),
              _Button(fun: songNotifier.forward, icon: Icons.skip_next),
              _Button(fun: songNotifier.stop, icon: Icons.stop),
              _buildMenuButtons(),
            ],
          );
  }

  Widget _buildMenuButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildMenuButton(scaffoldStateKey.currentState!.openDrawer),
          _buildMenuButton(scaffoldStateKey.currentState!.openEndDrawer),
        ],
      );

  Widget _buildMenuButton(VoidCallback fun) =>
      _Button(fun: fun, icon: Icons.menu);
}

class _Button extends StatelessWidget {
  const _Button({Key? key, required this.fun, required this.icon})
      : super(key: key);

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
