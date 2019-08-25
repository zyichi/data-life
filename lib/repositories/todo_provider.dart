import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/todo.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/db/todo_table.dart';
import 'package:data_life/repositories/goal_provider.dart';

class TodoProvider {
  final GoalProvider _goalProvider = GoalProvider();

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${TodoTable.name}'));
  }

  Future<int> getWaitingTodoCount() async {
    return Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select count(*) from ${TodoTable.name} where ${TodoTable.columnStatus} == ${TodoStatus.waiting.index}'));
  }

  Future<List<Todo>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      orderBy:
          '${TodoTable.columnStatus} asc, ${TodoTable.columnStartTime} asc',
      limit: count,
      offset: startIndex,
    );
    var todoList = maps.map((map) {
      return TodoTable.fromMap(map);
    }).toList();
    for (var todo in todoList) {
      todo.goalAction =
          await _goalProvider.getGoalAction(todo.goalActionUuid, false);
      todo.goal = await _goalProvider.getViaUuid(todo.goalUuid, false);
    }
    return todoList;
  }

  Future<List<Todo>> getViaGoalUuid(String goalUuid, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      where: '${TodoTable.columnGoalUuid} = ?',
      whereArgs: [goalUuid],
    );
    var todoList =  maps.map((map) {
      return TodoTable.fromMap(map);
    }).toList();
    if (!rowOnly) {
      for (var todo in todoList) {
        todo.goalAction =
        await _goalProvider.getGoalAction(todo.goalActionUuid, rowOnly);
        todo.goal = await _goalProvider.getViaUuid(todo.goalUuid, rowOnly);
      }
    }
    return todoList;
  }

  Future<Todo> getViaKey(String goalUuid, String goalActionUuid, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      where: '${TodoTable.columnGoalUuid} = ? and ${TodoTable.columnGoalActionUuid} = ?',
      whereArgs: [goalUuid, goalActionUuid],
    );
    if (maps.length > 0) {
      var todo = TodoTable.fromMap(maps.first);
      if (!rowOnly) {
        todo.goalAction = await _goalProvider.getGoalAction(todo.goalActionUuid, rowOnly);
        todo.goal = await _goalProvider.getViaUuid(todo.goalUuid, rowOnly);
      }
      return todo;
    }
    return null;
  }

  Future<int> insert(Todo todo) async {
    return LifeDb.db.insert(TodoTable.name, TodoTable.toMap(todo));
  }

  Future<int> update(Todo todo) async {
    return LifeDb.db.update(
      TodoTable.name, TodoTable.toMap(todo),
      where: "${TodoTable.columnGoalUuid} = ? and ${TodoTable.columnGoalActionUuid} = ?",
      whereArgs: [todo.goalUuid, todo.goalActionUuid],
    );
  }

  Future<int> save(Todo todo) async {
    return await update(todo);
  }

  Future<int> delete(Todo todo) async {
    return LifeDb.db.delete(
      TodoTable.name,
      where: "${TodoTable.columnGoalUuid} = ? and ${TodoTable.columnGoalActionUuid} = ?",
      whereArgs: [todo.goalUuid, todo.goalActionUuid],
    );
  }

  Future<int> deleteViaKey(int goalId, int goalActionId) async {
    return LifeDb.db.delete(
      TodoTable.name,
      where: "${TodoTable.columnGoalUuid} = ? and ${TodoTable.columnGoalActionUuid} = ?",
      whereArgs: [goalId, goalActionId],
    );
  }

  Future<int> deleteAll() async {
    return LifeDb.db.delete(
      TodoTable.name,
      where: "1",
    );
  }

  Future<int> deleteOlderThanTime(DateTime time) async {
    return LifeDb.db.delete(
      TodoTable.name,
      where: "${TodoTable.columnStartTime} < ?",
      whereArgs: [time.millisecondsSinceEpoch],
    );
  }

}
