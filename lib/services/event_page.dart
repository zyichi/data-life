import 'dart:collection';

import 'package:data_life/models/event.dart';


class EventPage {
  final List<Event> _events;

  final int startIndex;

  EventPage(this._events, this.startIndex);

  int get count => _events.length;
  int get endIndex => startIndex + count - 1;

  UnmodifiableListView<Event> get events =>
      UnmodifiableListView<Event>(_events);

  @override
  String toString() => "_EventPage($startIndex-$endIndex)";
}
