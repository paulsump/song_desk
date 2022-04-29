import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:song_desk/out.dart';

const noWarn = out;

const _allVoices = <String>[
  'bass',
  'backing',
  'vocal',
  'harmony',
  'snare',
  'arp',
];

// leftover = the harmony or backing that M doesn't play.
final allMutes = _allVoices + ['leftover', 'countIn'];

class Preferences {
  static late SharedPreferences _instance;

  static Future init() async =>
      _instance = await SharedPreferences.getInstance();

  static bool isMuted(String voice) => _getStringList('mutes').contains(voice);

  static void toggleMute(String voice) async {
    final List<String> mutes = _getStringList('mutes');

    if (mutes.contains(voice)) {
      mutes.remove(voice);
    } else {
      mutes.add(voice);
    }

    unawaited(_instance.setStringList('mutes', mutes));
  }

  static List<String> _getStringList(String key) =>
      _instance.getStringList(key) ?? <String>[];
}
