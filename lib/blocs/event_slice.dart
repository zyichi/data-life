import 'dart:math';

import 'package:data_life/services/event_page.dart';
import 'package:data_life/models/event.dart';

class EventSlice {
  static const maxInt = 0x7FFFFFFF;
  final List<EventPage> _pages;

  final int startIndex;
  final int totalCount;

  EventSlice(this._pages, this.totalCount)
      : startIndex = _pages.map((p) => p.startIndex).fold(maxInt, min);

  const EventSlice.empty()
      : _pages = const [],
        startIndex = 0,
        totalCount = 0;

  bool get hasNext => endIndex < totalCount;

  int get endIndex => _pages.map((page) => page.endIndex).fold(-1, max);

  Event elementAt(int index) {
    for (final page in _pages) {
      if (index >= page.startIndex && index <= page.endIndex) {
        return page.events[index - page.startIndex];
      }
    }
    return null;
  }

  List<int> get indexes {
    return endIndex < 0
        ? <int>[]
        : List.generate(endIndex - startIndex, (i) => startIndex + i);
  }

  @override
  String toString() =>
      '_EventSlice($startIndex - $endIndex), total count: $totalCount';
}
