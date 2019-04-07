import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/life_db.dart';


class GoalService {
  Future<Database> open() async {
    return await LifeDb.open();
  }

  Future<Goal> insert(Goal goal) async {
    Database db = await open();
    goal.id = await db.insert(GoalTable.name, goal.toMap());
    return goal;
  }

  Future<int> delete(int id) async {
    Database db = await open();
    final affected = await db.delete(GoalTable.name, where: '${GoalTable.columnId} = ?', whereArgs: [id]);
    return affected;
  }

  Future<Goal> getGoal(int id) async {
    Database db = await open();
    List<Map> maps = await db.query(GoalTable.name,
        where: '${GoalTable.columnId} = ?',
        whereArgs: [id]
    );
    if (maps.length > 0) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Goal>> queryGoal(String keyword, int limit) async {
    Database db = await open();
    List<Map> maps = await db.query(
      GoalTable.name,
      where: '${GoalTable.columnName} like %?%',
      whereArgs: [keyword],
      orderBy: '${GoalTable.columnLastActiveTime} desc',
      limit: limit
    );
    return maps.map((item) {
      return Goal.fromMap(item);
    }).toList();
  }

  Future<List<Goal>> getAllGoals() async {
    Database db = await open();
    List<Map> maps = await db.query(
      GoalTable.name,
      orderBy: '${GoalTable.columnLastActiveTime} desc'
    );
    return maps.map((item) {
      return Goal.fromMap(item);
    }).toList();
  }

  Future<int> update(Goal goal) async {
    Database db = await open();
    final affected = await db.update(GoalTable.name, goal.toMap(),
        where: "${GoalTable.columnId} = ?", whereArgs: [goal.id]);
    return affected;
  }

  Future close() async => LifeDb.close();
}
