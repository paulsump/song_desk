import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const allVoices = <String>[
  'bass',
  'backing',
  'vocal',
  'harmony',
  'snare',
  'arp',
];

class Preferences {
  static late SharedPreferences _instance;

  static Future init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static bool isMuted(String voice) =>
      _getStringList('mutedVoices').contains(voice);

  static void toggleMute(String voice) async {
    final List<String> mutedVoices = _getStringList('mutedVoices');

    if (mutedVoices.contains(voice)) {
      mutedVoices.remove(voice);
    } else {
      mutedVoices.add(voice);
    }

    unawaited(_instance.setStringList('mutedVoices', mutedVoices));
  }

  static List<String> _getStringList(String key) =>
      _instance.getStringList(key) ?? <String>[];
}
