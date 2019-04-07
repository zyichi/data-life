import 'package:sqflite/sqflite.dart';

import 'package:data_life/life_db.dart';
import 'package:data_life/models/event.dart';
import 'event_page.dart';

class EventService {
  static int eventsPerPage = 10;
  static int networkDelay = 500;

  Future<Database> open() async {
    return await LifeDb.open();
  }

  Future<EventPage> requestPage(int offset) async {
    print('_requestPage: $offset');
    Database db = await open();
    List<Map> maps = await db.query(EventTable.name,
        orderBy: '${EventTable.columnBeginTime} desc',
        limit: eventsPerPage, offset: offset,
    );
    var events = <Event>[];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return EventPage(events, offset);
  }

  Future<int> requestTotalCount() async {
    Database db = await open();
    int count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${EventTable.name}'));
    return count;
  }

  Future<Event> insert(Event event) async {
    Database db = await open();
    event.id = await db.insert(EventTable.name, event.toMap());
    return event;
  }

  Future<int> delete(int id) async {
    Database db = await open();
    int affected = await db.delete(EventTable.name,
        where: '${EventTable.columnId} = ?', whereArgs: [id]);
    return affected;
  }

  Future<int> deleteAll(String tableName) async {
    Database db = await open();
    int affected = await db.delete(tableName);
    return affected;
  }

  Future<Event> getEvent(int id) async {
    Database db = await open();
    List<Map> maps = await db.query(EventTable.name,
        where: '${EventTable.columnId} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Event.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Event>> getAllEvents() async {
    Database db = await open();
    List<Map> maps = await db.query(EventTable.name);
    var events = <Event>[];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return events;
  }

  Future<int> update(Event event) async {
    Database db = await open();
    int affected = await db.update(EventTable.name, event.toMap(),
        where: "${EventTable.columnId} = ?", whereArgs: [event.id]);
    return affected;
  }

  Future close() async => LifeDb.close();
}
