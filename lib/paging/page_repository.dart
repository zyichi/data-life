abstract class PageRepository<Item> {
  Future<int> count();
  Future<List<Item>> get({int startIndex, int count});
}
