class Scheduler {
  Scheduler();

  final _events = <Event>[];

  void add(Event event) {
    _events.add(event);
  }
}

class Event {
  Event({required this.offset, required this.fileName});

  final Duration offset;
  final String fileName;

  void execute() {
    // player.play(fileName);
  }
}