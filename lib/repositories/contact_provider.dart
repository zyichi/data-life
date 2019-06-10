import 'dart:math';
import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/contact.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/db/contact_table.dart';

class ContactProvider {
  final int total = 64;

  Future<int> countTestData() async {
    return Future.delayed(Duration(milliseconds: 30), () => total);
  }

  Future<List<Contact>> getTestData({int startIndex, int count}) async {
    return Future.delayed(Duration(seconds: 1), () {
      startIndex = min(startIndex, total);
      int endIndex = min(startIndex + count - 1, total - 1);
      final contacts = List<Contact>();
      for (int i = startIndex; i <= endIndex; ++i) {
        final contact = Contact();
        contact.name = 'Contact $i';
        contacts.add(contact);
      }
      return contacts;
    });
  }

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${ContactTable.name}'));
  }

  Future<List<Contact>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      ContactTable.name,
      columns: [],
      orderBy: '${ContactTable.columnLastMeetTime} desc',
      limit: count,
      offset: startIndex,
    );
    return maps.map((map) {
      return ContactTable.fromMap(map);
    }).toList();
  }

  Future<Contact> getViaId(int id) async {
    List<Map> maps = await LifeDb.db.query(ContactTable.name,
      columns: [],
      where: '${ContactTable.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return ContactTable.fromMap(maps.first);
    }
    return null;
  }

  Future<Contact> getViaName(String name) async {
    List<Map> maps = await LifeDb.db.query(ContactTable.name,
      columns: [],
      where: '${ContactTable.columnName} = ?',
      whereArgs: [name],
    );
    if (maps.length > 0) {
      return ContactTable.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contact>> search(String pattern, int limit) async {
    List<Map> maps = await LifeDb.db.query(
      ContactTable.name,
      columns: [],
      where:
          "${ContactTable.columnName} like '%$pattern%' or ${ContactTable.columnNickname} like '%$pattern%'",
      whereArgs: [],
      limit: limit,
    );
    return maps.map((map) {
      return ContactTable.fromMap(map);
    }).toList();
  }

  Future<int> insert(Contact contact) async {
    return LifeDb.db.insert(ContactTable.name, ContactTable.toMap(contact));
  }

  Future<int> update(Contact contact) async {
    assert(contact.id != null);
    return LifeDb.db.update(ContactTable.name, ContactTable.toMap(contact),
        where: "${ContactTable.columnId} = ?", whereArgs: [contact.id]);
  }

  Future<int> save(Contact contact) async {
    int affected = 0;
    if (contact.id == null) {
      contact.id = await insert(contact);
      affected = 1;
    } else {
      affected = await update(contact);
    }
    return affected;
  }
}
