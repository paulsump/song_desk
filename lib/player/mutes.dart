/// TODO Randomly mute voices
class Mutes {
  static final list = <String>[];

  static bool isMuted(String voice) => list.contains(voice);

  static void toggleMute(String voice) async {
    if (list.contains(voice)) {
      list.remove(voice);
    } else {
      list.add(voice);
    }
  }

  static void update(Duration currentTime) {}
}
