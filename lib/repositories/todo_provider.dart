import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/todo.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/db/todo_table.dart';
import 'package:data_life/repositories/goal_provider.dart';

class TodoProvider {
  final GoalProvider _goalProvider = GoalProvider();

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${TodoTable.name} where ${TodoTable.columnStatus} != ${TodoStatus.dismiss.index}'));
  }

  Future<int> getWaitingTodoCount() async {
    return Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select count(*) from ${TodoTable.name} where ${TodoTable.columnStatus} == ${TodoStatus.waiting.index}'));
  }

  Future<List<Todo>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      where: "${TodoTable.columnStatus} != ?",
      whereArgs: [TodoStatus.dismiss.index],
      orderBy:
          '${TodoTable.columnStartTime} asc, ${TodoTable.columnStatus} asc',
      limit: count,
      offset: startIndex,
    );
    var todoList = maps.map((map) {
      return TodoTable.fromMap(map);
    }).toList();
    for (var todo in todoList) {
      todo.goalAction =
          await _goalProvider.getGoalAction(todo.goalActionId, false);
      todo.goal = await _goalProvider.getViaId(todo.goalId, false);
    }
    return todoList;
  }

  Future<Todo> getViaGoalActionId(int goalActionId) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      where: '${TodoTable.columnGoalActionId} = ?',
      whereArgs: [goalActionId],
    );
    if (maps.length > 0) {
      return TodoTable.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Todo>> getViaGoalId(int goalId, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      TodoTable.name,
      columns: [],
      where: '${TodoTable.columnGoalId} = ?',
      whereArgs: [goalId],
    );
    var todoList =  maps.map((map) {
      return TodoTable.fromMap(map);
    }).toList();
    if (!rowOnly) {
      for (var todo in todoList) {
        todo.goalAction =
        await _goalProvider.getGoalAction(todo.goalActionId, rowOnly);
        todo.goal = await _goalProvider.getViaId(todo.goalId, rowOnly);
      }
    }
    return todoList;
  }

  Future<int> insert(Todo todo) async {
    return LifeDb.db.insert(TodoTable.name, TodoTable.toMap(todo));
  }

  Future<int> update(Todo todo) async {
    assert(todo.id != null);
    return LifeDb.db.update(TodoTable.name, TodoTable.toMap(todo),
        where: "${TodoTable.columnId} = ?", whereArgs: [todo.id]);
  }

  Future<int> save(Todo todo) async {
    int affected = 0;
    if (todo.id == null) {
      todo.id = await insert(todo);
      affected = 1;
    } else {
      affected = await update(todo);
    }
    return affected;
  }

  Future<int> delete(int id) async {
    return LifeDb.db.delete(
      TodoTable.name,
      where: "${TodoTable.columnId} = ?",
      whereArgs: [id],
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

  Future<int> dismissTodo(int id) async {
    return LifeDb.db.update(
      TodoTable.name,
      {'status': TodoStatus.dismiss.index},
      where: "${TodoTable.columnId} = ?",
      whereArgs: [id],
    );
  }

  Future<int> doneTodo(int id) async {
    return LifeDb.db.update(
      TodoTable.name,
      {'status': TodoStatus.done.index},
      where: "${TodoTable.columnId} = ?",
      whereArgs: [id],
    );
  }
}
