import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/db/goal_table.dart';
import 'package:data_life/db/action_table.dart';
import 'package:data_life/db/goal_action_table.dart';
import 'package:data_life/db/life_db.dart';

import 'package:data_life/repositories/action_provider.dart';


class GoalProvider {
  
  final ActionProvider _actionProvider = ActionProvider();

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${GoalTable.name}'));
  }

  Future<List<Goal>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
      orderBy: '${GoalTable.columnLastActiveTime} desc',
      limit: count,
      offset: startIndex,
    );
    var goals = maps.map((map) {
      return GoalTable.fromMap(map);
    }).toList();
    for (Goal goal in goals) {
      goal.goalActions = await getGoalAction(goal.id);
    }
    return goals;
  }

  Future<Goal> getViaName(String name) async {
    List<Map> maps = await LifeDb.db.query(GoalTable.name,
      columns: [],
      where: '${GoalTable.columnName} = ?',
      whereArgs: [name],
    );
    if (maps.length > 0) {
      return GoalTable.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(Goal goal) async {
    return LifeDb.db.insert(GoalTable.name, GoalTable.toMap(goal));
  }

  Future<int> update(Goal goal) async {
    assert(goal.id != null);
    return LifeDb.db.update(GoalTable.name, GoalTable.toMap(goal),
        where: "${GoalTable.columnId} = ?", whereArgs: [goal.id]);
  }

  Future<int> save(Goal goal) async {
    int affected = 0;
    if (goal.id == null) {
      goal.id = await insert(goal);
      affected = 1;
    } else {
      affected = await update(goal);
    }
    return affected;
  }

  Future<int> delete(Goal goal) async {
    return LifeDb.db.delete(
      GoalTable.name,
      where: "${GoalTable.columnId} = ?",
      whereArgs: [goal.id],
    );
  }

  Future<List<GoalAction>> getGoalAction(int goalId) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where: "${GoalActionTable.columnGoalId} = ?",
      whereArgs: [goalId],
    );
    List<GoalAction> goalActions = maps.map((map) {
      return GoalActionTable.fromMap(map);
    }).toList();
    for (GoalAction goalAction in goalActions) {
      Action action = await _actionProvider.getViaId(goalAction.actionId);
      goalAction.action = action;
    }
    return goalActions;
  }

}
