import 'dart:math';
import 'package:sqflite/sqflite.dart';

import 'package:data_life/db/life_db.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/db/action_table.dart';


class ActionProvider {

  final int testTotal = 32;

  Future<int> testCount() async {
    return Future.delayed(Duration(milliseconds: 30), () => testTotal);
  }

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${ActionTable.name}'));
  }

  Future<List<MyAction>> getTestData({int startIndex, int count}) async {
    return Future.delayed(Duration(seconds: 1), () {
      startIndex = min(startIndex, testTotal);
      int endIndex = min(startIndex + count - 1, testTotal - 1);
      final actions = List<MyAction>();
      for (int i = startIndex; i <= endIndex; ++i) {
        final action = MyAction();
        action.id = i;
        actions.add(action);
      }
      return actions;
    });
  }

  Future<List<MyAction>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      ActionTable.name,
      columns: [],
      orderBy: '${ActionTable.columnLastActiveTime} desc',
      limit: count,
      offset: startIndex,
    );
    return maps.map((map) {
      return ActionTable.fromMap(map);
    }).toList();
  }

  Future<MyAction> getViaId(int id) async {
    List<Map> maps = await LifeDb.db.query(ActionTable.name,
      columns: [],
      where: '${ActionTable.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return ActionTable.fromMap(maps.first);
    }
    return null;
  }

  Future<MyAction> getViaName(String name) async {
    List<Map> maps = await LifeDb.db.query(ActionTable.name,
      columns: [],
      where: '${ActionTable.columnName} = ?',
      whereArgs: [name],
    );
    if (maps.length > 0) {
      return ActionTable.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MyAction>> search(String pattern) async {
    List<Map> maps = await LifeDb.db.query(ActionTable.name,
      columns: [],
      where: "${ActionTable.columnName} like '%$pattern%'",
      whereArgs: [],
      limit: 8,
    );
    return maps.map((map) {
      return ActionTable.fromMap(map);
    }).toList();
  }

  Future<int> insert(MyAction action) async {
    return LifeDb.db.insert(ActionTable.name, ActionTable.toMap(action));
  }

  Future<int> update(MyAction action) async {
    assert(action.id != null);
    return LifeDb.db.update(ActionTable.name, ActionTable.toMap(action),
        where: "${ActionTable.columnId} = ?", whereArgs: [action.id]);
  }

  Future<int> save(MyAction action) async {
    int affected = 0;
    if (action.id == null) {
      action.id = await insert(action);
      affected = 1;
    } else {
      affected = await update(action);
    }
    return affected;
  }
}


