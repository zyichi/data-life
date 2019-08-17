import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/goal_moment.dart';

import 'package:data_life/db/goal_table.dart';
import 'package:data_life/db/goal_action_table.dart';
import 'package:data_life/db/goal_moment_table.dart';
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
      orderBy:
          '${GoalTable.columnStatus} asc, ${GoalTable.columnLastActiveTime} desc',
      limit: count,
      offset: startIndex,
    );
    var goals = maps.map((map) {
      return GoalTable.fromMap(map);
    }).toList();
    for (Goal goal in goals) {
      goal.goalActions = await getGoalActionOfGoal(goal.id, false);
    }
    return goals;
  }

  Future<List<Goal>> getAllGoals() async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
    );
    var goals = maps.map((map) {
      return GoalTable.fromMap(map);
    }).toList();
    for (Goal goal in goals) {
      goal.goalActions = await getGoalActionOfGoal(goal.id, false);
    }
    return goals;
  }

  Future<List<Goal>> getViaStatus(int statusIndex, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
      where: "${GoalTable.columnStatus} = ?",
      whereArgs: [statusIndex],
    );
    var goals = maps.map((map) {
      return GoalTable.fromMap(map);
    }).toList();
    for (Goal goal in goals) {
      if (!rowOnly) {
        goal.goalActions = await getGoalActionOfGoal(goal.id, false);
      }
    }
    return goals;
  }

  Future<List<Goal>> getViaActionId(int actionId, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(GoalActionTable.name,
        distinct: true,
        columns: [GoalActionTable.columnGoalId],
        where: "${GoalActionTable.columnActionId} = ?",
        whereArgs: [actionId]);
    var goalIdList = maps.map((map) {
      return map[GoalActionTable.columnGoalId] as int;
    }).toList();
    var goals = <Goal>[];
    for (int goalId in goalIdList) {
      var goal = await getViaId(goalId, rowOnly);
      if (goal != null) {
        goals.add(goal);
      }
    }
    return goals;
  }

  Future<Goal> getViaName(String name) async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
      where: '${GoalTable.columnName} = ?',
      whereArgs: [name],
    );
    if (maps.length > 0) {
      return GoalTable.fromMap(maps.first);
    }
    return null;
  }

  Future<Goal> getViaId(int id, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
      where: '${GoalTable.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      Goal goal = GoalTable.fromMap(maps.first);
      if (!rowOnly) {
        goal.goalActions = await getGoalActionOfGoal(goal.id, rowOnly);
      }
      return goal;
    }
    return null;
  }

  Future<int> insert(Goal goal) async {
    return LifeDb.db.insert(GoalTable.name, GoalTable.toMap(goal));
  }

  Future<int> insertDeleted(Goal goal) async {
    var m = GoalTable.toMap(goal);
    m[GoalTable.columnId] = null;
    return LifeDb.db.insert(GoalTable.deletedName, m);
  }

  Future<int> saveDeleted(Goal goal) async {
    return insertDeleted(goal);
  }

  Future<int> deleteGoalAction(GoalAction goalAction) async {
    return LifeDb.db.delete(
      GoalActionTable.name,
      where:
          "${GoalActionTable.columnGoalId} = ? and ${GoalActionTable.columnActionId} = ?",
      whereArgs: [goalAction.goalId, goalAction.actionId],
    );
  }

  Future<int> saveDeletedGoalAction(GoalAction goalAction) async {
    var m = GoalActionTable.toMap(goalAction);
    m[GoalActionTable.columnId] = null;
    return LifeDb.db.insert(GoalActionTable.deletedName, m);
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

  Future<List<GoalAction>> getGoalActionOfGoal(int goalId, bool rowOnly) async {
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
      if (!rowOnly) {
        MyAction action = await _actionProvider.getViaId(goalAction.actionId);
        goalAction.action = action;
      }
    }
    return goalActions;
  }

  Future<GoalAction> getGoalAction(int id, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where: "${GoalActionTable.columnId} = ?",
      whereArgs: [id],
    );
    if (maps.length > 0) {
      var goalAction = GoalActionTable.fromMap(maps.first);
      if (!rowOnly) {
        goalAction.action = await _actionProvider.getViaId(goalAction.actionId);
      }
      return goalAction;
    }
    return null;
  }

  Future<int> insertGoalAction(GoalAction goalAction) async {
    return LifeDb.db
        .insert(GoalActionTable.name, GoalActionTable.toMap(goalAction));
  }

  Future<int> updateGoalAction(GoalAction goalAction) async {
    assert(goalAction.id != null);
    return LifeDb.db.update(
        GoalActionTable.name, GoalActionTable.toMap(goalAction),
        where: "${GoalActionTable.columnId} = ?", whereArgs: [goalAction.id]);
  }

  Future<int> saveGoalAction(GoalAction goalAction) async {
    int affected = 0;
    if (goalAction.id == null) {
      goalAction.id = await insertGoalAction(goalAction);
      affected = 1;
    } else {
      affected = await updateGoalAction(goalAction);
    }
    return affected;
  }

  Future<int> insertGoalMoment(GoalMoment goalMoment) async {
    return LifeDb.db
        .insert(GoalMomentTable.name, GoalMomentTable.toMap(goalMoment));
  }

  Future<int> updateGoalMoment(GoalMoment goalMoment) async {
    assert(goalMoment.id != null);
    return LifeDb.db.update(
        GoalMomentTable.name, GoalMomentTable.toMap(goalMoment),
        where: "${GoalMomentTable.columnId} = ?", whereArgs: [goalMoment.id]);
  }

  Future<int> saveGoalMoment(GoalMoment goalMoment) async {
    int affected = 0;
    if (goalMoment.id == null) {
      goalMoment.id = await insertGoalMoment(goalMoment);
      affected = 1;
    } else {
      affected = await updateGoalMoment(goalMoment);
    }
    return affected;
  }

  Future<int> deleteGoalMoment(GoalMoment goalMoment) async {
    return deleteGoalMomentViaUniqueKey(
        goalMoment.goalId, goalMoment.goalActionId, goalMoment.momentId);
  }

  Future<int> deleteGoalMomentViaUniqueKey(
      int goalId, int goalActionId, int momentId) async {
    return LifeDb.db.delete(
      GoalMomentTable.name,
      where:
          "${GoalMomentTable.columnGoalId} = ? and ${GoalMomentTable.columnGoalActionId} = ? and ${GoalMomentTable.columnMomentId} = ?",
      whereArgs: [goalId, goalActionId, momentId],
    );
  }

  Future<GoalAction> getGoalActionViaGoalAndAction(
      int goalId, int actionId, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where:
          "${GoalActionTable.columnGoalId} = ? and ${GoalActionTable.columnActionId} = ?",
      whereArgs: [goalId, actionId],
    );
    if (maps.length > 0) {
      var goalAction = GoalActionTable.fromMap(maps.first);
      if (!rowOnly) {
        goalAction.action = await _actionProvider.getViaId(goalAction.actionId);
      }
      return goalAction;
    }
    return null;
  }

  Future<int> getGoalLastActiveTime(int goalId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${GoalMomentTable.columnMomentBeginTime}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalId} = $goalId'));
    return t ?? 0;
  }

  Future<int> getGoalActionLastActiveTime(int goalId, int goalActionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${GoalMomentTable.columnMomentBeginTime}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalId} = $goalId and ${GoalMomentTable.columnGoalActionId} = $goalActionId'));
    return t ?? 0;
  }

  Future<int> getGoalTotalTimeTaken(int goalId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${GoalMomentTable.columnMomentDuration}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalId} = $goalId'));
    return t ?? 0;
  }

  Future<int> getGoalActionTotalTimeTaken(int goalId, int goalActionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${GoalMomentTable.columnMomentDuration}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalId} = $goalId and ${GoalMomentTable.columnGoalActionId} = $goalActionId'));
    return t ?? 0;
  }

  Future<int> setStatus(int id, int statusIndex) async {
    return LifeDb.db.update(
      GoalTable.name,
      {
        'status': statusIndex,
        'updateTime': DateTime.now().millisecondsSinceEpoch,
      },
      where: '${GoalTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
