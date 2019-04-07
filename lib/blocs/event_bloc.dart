import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'package:data_life/services/event_service.dart';
import 'package:data_life/services/event_page.dart';
import 'event_slice.dart';


class EventBloc {
  static const maxInt = 0x7FFFFFFF;

  final EventService _eventService;

  final _invalidController = PublishSubject<bool>();
  final _indexController = PublishSubject<int>();

  final _pages = <int, EventPage>{};
  final _pagesBeingRequested = Set<int>();
  int _totalCount = maxInt;

  final _sliceSubject =
      BehaviorSubject<EventSlice>.seeded(EventSlice.empty());

  EventBloc(this._eventService) {
    _invalidController.stream.listen(_handleInvalid);
    _indexController.stream
        .bufferTime(Duration(milliseconds: 500))
        .where((batch) => batch.isNotEmpty)
        .listen(_handleIndexes);
  }

  Sink<int> get index => _indexController.sink;
  Sink<bool> get invalid => _invalidController.sink;

  ValueObservable<EventSlice> get slice => _sliceSubject.stream;

  int _getPageStartFromIndex(int index) =>
      (index ~/ EventService.eventsPerPage) *
      EventService.eventsPerPage;

  void _handleInvalid(bool invalid) async {
    _totalCount = await _eventService.requestTotalCount();
    final indexes = List.generate(
        min(_totalCount, EventService.eventsPerPage * 3), (i) => slice.value.startIndex + i);

    // Clear cached page.
    _pages.clear();
    _handleIndexes(indexes);
  }

  void _handleIndexes(List<int> indexes) {
    final int minIndex = indexes.fold(maxInt, min);
    final int maxIndex = indexes.fold(-1, max);

    final minPageIndex = _getPageStartFromIndex(minIndex);
    final maxPageIndex = _getPageStartFromIndex(maxIndex);

    for (int i = minPageIndex;
        i <= maxPageIndex;
        i += EventService.eventsPerPage) {
      if (_pages.containsKey(i)) continue;
      if (_pagesBeingRequested.contains(i)) continue;

      _pagesBeingRequested.add(i);
      _eventService.requestPage(i).then((page) => _handleNewPage(page, i));
    }

    // Remove pages too far from current scroll position.
    _pages.removeWhere((pageIndex, _) =>
        pageIndex < minPageIndex - EventService.eventsPerPage ||
        pageIndex > maxPageIndex + EventService.eventsPerPage);
  }

  void _handleNewPage(EventPage page, int index) {
    _pages[index] = page;
    _pagesBeingRequested.remove(index);
    _sendNewSlice();
  }

  void _sendNewSlice() {
    final pages = _pages.values.toList(growable: false);
    final slice = EventSlice(pages, _totalCount);
    print('_sendNewSlice: $slice');
    _sliceSubject.add(slice);
  }
}

class EventProvider extends InheritedWidget {
  final EventBloc eventBloc;

  EventProvider({
    Key key,
    @required this.eventBloc,
    Widget child,
  })  : assert(eventBloc != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static EventBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(EventProvider)
              as EventProvider)
          .eventBloc;
}
