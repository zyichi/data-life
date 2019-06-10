import 'dart:collection';

class Page<Item> {
  static const int pageSize = 20;
  final List<Item> _items;
  final int pageNumber;

  int get count => _items.length;
  int get startIndex => pageNumber * pageSize;
  int get endIndex => startIndex + count - 1;

  Page(this._items, this.pageNumber);

  UnmodifiableListView<Item> get items =>
      UnmodifiableListView<Item>(_items);
}
