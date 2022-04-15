class Scheduler {
  Scheduler();

  final _events = <Event>[];

  void add(Event event) {
    _events.add(event);
  }
}

class Event {
  Event({required this.start, required this.fileName});

  final Duration start;
  final String fileName;

  void execute() {
    // player.play(fileName);
  }
}