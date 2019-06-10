import 'package:data_life/models/contact.dart';
import 'package:data_life/repositories/contact_provider.dart';

import 'package:data_life/paging/page_repository.dart';


class ContactRepository extends PageRepository<Contact> {
  final ContactProvider _contactProvider;

  ContactRepository(this._contactProvider);

  Future<List<Contact>> get({int startIndex, int count}) async {
    return _contactProvider.get(startIndex: startIndex, count: count);
  }

  Future<int> count() async {
    return _contactProvider.count();
  }

  Future<Contact> getViaName(String name) async {
    return _contactProvider.getViaName(name);
  }

  Future<List<Contact>> search(String pattern, int limit) async {
    return _contactProvider.search(pattern, limit);
  }

  Future<List<Contact>> getAll() async {
    return Future.delayed(Duration(seconds: 1), () => []);
  }

  Future<int> save(Contact contact) async {
    return _contactProvider.save(contact);
  }
}
