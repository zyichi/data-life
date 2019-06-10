import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

import 'package:data_life/constants.dart';
import 'package:data_life/paging/page_list.dart';
import 'package:data_life/paging/page_repository.dart';
import 'package:data_life/paging/page.dart';

import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';


abstract class PageEvent extends Equatable {
  PageEvent([List props = const []]) : super(props);
}

class RefreshPage extends PageEvent {}

class FetchPage extends PageEvent {
  final int pageNumber;

  FetchPage({@required this.pageNumber})
      : assert(pageNumber != null),
        super([pageNumber]);
}

abstract class PageState extends Equatable {
  PageState([List props = const []]) : super(props);
}

class PageUninitialized extends PageState {}
class PageLoading extends PageState {}
class PageError extends PageState {}

class PageLoaded<Item> extends PageState {
  final PageList<Item> pageList;

  PageLoaded(this.pageList) : super([pageList]);
}

class PageBloc<Item> extends Bloc<PageEvent, PageState> {
  final _indexController = PublishSubject<int>();
  final PageRepository pageRepository;
  final _pages = <int, Page<Item>>{};
  final _pagesBeingRequested = Set<int>();
  int _total;
  static const int preFetchPageNum = 4;
  static const int indexBufferTime = 300;

  PageBloc({@required this.pageRepository})
      : assert(pageRepository != null) {
    _indexController.stream
        .bufferTime(Duration(milliseconds: indexBufferTime))
        .where((batch) => batch.isNotEmpty)
        .listen(_handleIndexes);
  }

  @override
  PageState get initialState => PageUninitialized();

  @override
  Stream<PageState> mapEventToState(PageEvent event) async* {
    if (event is RefreshPage) {
      print('${logStr()} mapEventToState RefreshPage');
      yield PageLoading();
      _total = await pageRepository.count();
      print('${logStr()} mapEventToState RefreshPage: total is $_total');
      if (_total == 0) {
        // print('${logStr()} mapEventToState RefreshPage: total is 0');
        yield PageLoaded<Item>(PageList<Item>([], 0));
        return;
      }
      int startIndex = 0;
      if (currentState is PageLoaded) {
        startIndex = (currentState as PageLoaded).pageList.startIndex;
      }
      final indexes = List.generate(
          min(_total, Page.pageSize * preFetchPageNum), (i) => startIndex + i);

      _pages.clear();
      _pagesBeingRequested.clear();

      _handleIndexes(indexes);
    }
    if (event is FetchPage) {
      print('${logStr()} mapEventToState FetchPage');
      try {
        final pageNumber = event.pageNumber;
        final items = await pageRepository.get(
            startIndex: pageNumber * Page.pageSize,
            count: Page.pageSize);
        final page = Page<Item>(items, pageNumber);

        _pages[pageNumber] = page;
        _pagesBeingRequested.remove(pageNumber);

        if (_pages.length >= preFetchPageNum * 2) {
          _pages.removeWhere((i, _) =>
          i < pageNumber - preFetchPageNum * 2 || i > pageNumber + preFetchPageNum);
        }

        final _pageList =
        PageList<Item>(_pages.values.toList(growable: false), _total);

        yield PageLoaded<Item>(_pageList);
      } catch (e) {
        print('${logStr()} mapEventToState FetchPage error: $e');
        yield PageError();
      }
    }
  }

  @override
  void dispose() {
    _indexController.close();
    super.dispose();
  }

  void _handleIndexes(List<int> indexes) async {
    print('${logStr()} PageBloc handleIndexes: $indexes');
    int startIndex = indexes.fold(maxInt, min);
    int endIndex = indexes.fold(-1, max);
    int startPageNumber = startIndex ~/ Page.pageSize;
    int endPageNumber = endIndex ~/ Page.pageSize;

    for (int i = startPageNumber; i <= endPageNumber; i++) {
      if (_pagesBeingRequested.contains(i)) continue;
      if (_pages.containsKey(i)) continue;

      _pagesBeingRequested.add(i);

      print('${logStr()} PageBloc handleIndexes dispatch FetchPage for page $i');
      dispatch(FetchPage(pageNumber: i));
    }
  }

  void getItem(int index) {
    _indexController.sink.add(index);
  }

  String logStr() {
    List l = List<Item>();
    if (l is List<Contact>) {
      return 'CONTACT';
    }
    if (l is List<Location>) {
      return 'LOCATION';
    }
    if (l is List<Moment>) {
      return 'MOMENT';
    }
    if (l is List<Goal>) {
      return 'GOAL';
    }
    return 'UNKNOWN';
  }
}
