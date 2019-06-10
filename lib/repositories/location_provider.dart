import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/location.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/db/location_table.dart';


class LocationProvider {

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${LocationTable.name}'));
  }

  Future<List<Location>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      LocationTable.name,
      columns: [],
      orderBy: '${LocationTable.columnLastVisitTime} desc',
      limit: count,
      offset: startIndex,
    );
    return maps.map((map) {
      return LocationTable.fromMap(map);
    }).toList();
  }

  Future<Location> getViaId(int id) async {
    List<Map> maps = await LifeDb.db.query(LocationTable.name,
      columns: [],
      where: '${LocationTable.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return LocationTable.fromMap(maps.first);
    }
    return null;
  }

  Future<Location> getViaDisplayAddress(String displayAddress) async {
    List<Map> maps = await LifeDb.db.query(LocationTable.name,
      columns: [],
      where: '${LocationTable.columnDisplayAddress} = ?',
      whereArgs: [displayAddress],
    );
    if (maps.length > 0) {
      return LocationTable.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Location>> search(String pattern, int limit) async {
    List<Map> maps = await LifeDb.db.query(LocationTable.name,
      columns: [],
      where: "${LocationTable.columnDisplayAddress} like '%$pattern%'",
      whereArgs: [],
      orderBy: '${LocationTable.columnLastVisitTime} desc',
      limit: limit,
    );
    return maps.map((map) {
      return LocationTable.fromMap(map);
    }).toList();
  }

  Future<int> insert(Location location) async {
    return LifeDb.db.insert(LocationTable.name, LocationTable.toMap(location));
  }

  Future<int> update(Location location) async {
    assert(location.id != null);
    return LifeDb.db.update(LocationTable.name, LocationTable.toMap(location),
        where: "${LocationTable.columnId} = ?", whereArgs: [location.id]);
  }

  Future<int> save(Location location) async {
    int affected = 0;
    if (location.id == null) {
      location.id = await insert(location);
      affected = 1;
    } else {
      affected = await update(location);
    }
    return affected;
  }

}
