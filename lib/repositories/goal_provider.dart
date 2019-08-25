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
      goal.goalActions = await getGoalActionOfGoal(goal.uuid, false);
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
      goal.goalActions = await getGoalActionOfGoal(goal.uuid, false);
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
        goal.goalActions = await getGoalActionOfGoal(goal.uuid, false);
      }
    }
    return goals;
  }

  Future<List<Goal>> getViaActionId(int actionId, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(GoalActionTable.name,
        distinct: true,
        columns: [GoalActionTable.columnGoalUuid],
        where: "${GoalActionTable.columnActionId} = ?",
        whereArgs: [actionId]);
    var goalUuidList = maps.map((map) {
      return map[GoalActionTable.columnGoalUuid];
    }).toList();
    var goals = <Goal>[];
    for (String goalUuid in goalUuidList) {
      var goal = await getViaUuid(goalUuid, rowOnly);
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

  Future<Goal> getViaUuid(String uuid, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalTable.name,
      columns: [],
      where: '${GoalTable.columnUuid} = ?',
      whereArgs: [uuid],
    );
    if (maps.length > 0) {
      Goal goal = GoalTable.fromMap(maps.first);
      if (!rowOnly) {
        goal.goalActions = await getGoalActionOfGoal(goal.uuid, rowOnly);
      }
      return goal;
    }
    return null;
  }

  Future<int> insert(Goal goal) async {
    return LifeDb.db.insert(GoalTable.name, GoalTable.toMap(goal));
  }

  Future<int> deleteGoalAction(GoalAction goalAction) async {
    return LifeDb.db.delete(
      GoalActionTable.name,
      where:
          "${GoalActionTable.columnGoalUuid} = ? and ${GoalActionTable.columnActionId} = ?",
      whereArgs: [goalAction.goalUuid, goalAction.actionId],
    );
  }

  Future<int> update(Goal goal) async {
    assert(goal.uuid != null);
    return LifeDb.db.update(GoalTable.name, GoalTable.toMap(goal),
        where: "${GoalTable.columnUuid} = ?", whereArgs: [goal.uuid]);
  }

  Future<int> save(Goal goal) async {
    return await update(goal);
  }

  Future<int> delete(Goal goal) async {
    return LifeDb.db.delete(
      GoalTable.name,
      where: "${GoalTable.columnUuid} = ?",
      whereArgs: [goal.uuid],
    );
  }

  Future<List<GoalAction>> getGoalActionOfGoal(String goalUuid, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where: "${GoalActionTable.columnGoalUuid} = ?",
      whereArgs: [goalUuid],
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

  Future<GoalAction> getGoalAction(String uuid, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where: "${GoalActionTable.columnUuid} = ?",
      whereArgs: [uuid],
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
    assert(goalAction.uuid != null);
    return LifeDb.db.update(
        GoalActionTable.name, GoalActionTable.toMap(goalAction),
        where: "${GoalActionTable.columnUuid} = ?", whereArgs: [goalAction.uuid]);
  }

  Future<int> saveGoalAction(GoalAction goalAction) async {
    return await updateGoalAction(goalAction);
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
        goalMoment.goalUuid, goalMoment.goalActionId, goalMoment.momentId);
  }

  Future<int> deleteGoalMomentViaUniqueKey(
      String goalUuid, int goalActionId, int momentId) async {
    return LifeDb.db.delete(
      GoalMomentTable.name,
      where:
          "${GoalMomentTable.columnGoalUuid} = ? and ${GoalMomentTable.columnGoalActionId} = ? and ${GoalMomentTable.columnMomentId} = ?",
      whereArgs: [goalUuid, goalActionId, momentId],
    );
  }

  Future<GoalAction> getGoalActionViaGoalAndAction(
      int goalId, int actionId, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      GoalActionTable.name,
      columns: [],
      where:
          "${GoalActionTable.columnGoalUuid} = ? and ${GoalActionTable.columnActionId} = ?",
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
        'select max(${GoalMomentTable.columnMomentBeginTime}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalUuid} = $goalId'));
    return t ?? 0;
  }

  Future<int> getGoalActionLastActiveTime(int goalId, int goalActionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${GoalMomentTable.columnMomentBeginTime}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalUuid} = $goalId and ${GoalMomentTable.columnGoalActionId} = $goalActionId'));
    return t ?? 0;
  }

  Future<int> getGoalTotalTimeTaken(int goalId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${GoalMomentTable.columnMomentDuration}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalUuid} = $goalId'));
    return t ?? 0;
  }

  Future<int> getGoalActionTotalTimeTaken(int goalId, int goalActionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${GoalMomentTable.columnMomentDuration}) from ${GoalMomentTable.name} where ${GoalMomentTable.columnGoalUuid} = $goalId and ${GoalMomentTable.columnGoalActionId} = $goalActionId'));
    return t ?? 0;
  }

  Future<int> setStatus(String uuid, int statusIndex) async {
    return LifeDb.db.update(
      GoalTable.name,
      {
        'status': statusIndex,
        'updateTime': DateTime.now().millisecondsSinceEpoch,
      },
      where: '${GoalTable.columnUuid} = ?',
      whereArgs: [uuid],
    );
  }
}
