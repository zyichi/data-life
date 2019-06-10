import 'dart:math';

import 'package:data_life/paging/page.dart';
import 'package:data_life/constants.dart';


class PageList<Item> {
  final List<Page<Item>> _pages;
  final int total;

  final int startIndex;

  PageList(this._pages, this.total)
      : startIndex = _pages.map((p) => p.startIndex).fold(maxInt, min);

  int get startPage => _pages.map((p) => p.pageNumber).fold(maxInt, min);
  int get endPage => _pages.map((p) => p.pageNumber).fold(-1, max);

  Item itemAt(int index) {
    for (final page in _pages) {
      if (index >= page.startIndex && index <= page.endIndex) {
        return page.items[index - page.startIndex];
      }
    }
    return null;
  }
}
