import 'package:data_life/paging/page_repository.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/goal_moment.dart';

import 'package:data_life/repositories/goal_provider.dart';

class GoalRepository extends PageRepository<Goal> {
  final GoalProvider _goalProvider;

  GoalRepository(this._goalProvider);

  @override
  Future<int> count() async {
    return _goalProvider.count();
  }

  @override
  Future<List<Goal>> get({int startIndex, int count}) async {
    return _goalProvider.get(startIndex: startIndex, count: count);
  }

  Future<List<Goal>> getAllGoals() async {
    return _goalProvider.getAllGoals();
  }

  Future<List<Goal>> getViaStatus(GoalStatus status, bool rowOnly) async {
    return _goalProvider.getViaStatus(status.index, rowOnly);
  }

  Future<List<Goal>> getViaActionId(int actionId, bool rowOnly) async {
    return _goalProvider.getViaActionId(actionId, rowOnly);
  }

  Future<Goal> getViaName(String name) async {
    return _goalProvider.getViaName(name);
  }

  Future<int> add(Goal goal) async {
    return _goalProvider.insert(goal);
  }

  Future<int> save(Goal goal) async {
    return _goalProvider.save(goal);
  }

  Future<int> delete(Goal goal) async {
    return _goalProvider.delete(goal);
  }

  Future<int> deleteGoalAction(GoalAction goalAction) async {
    return _goalProvider.deleteGoalAction(goalAction);
  }

  Future<int> addGoalAction(GoalAction goalAction) async {
    return _goalProvider.insertGoalAction(goalAction);
  }

  Future<int> saveGoalAction(GoalAction goalAction) async {
    return _goalProvider.saveGoalAction(goalAction);
  }

  Future<GoalAction> getGoalActionViaGoalAndAction(
      int goalId, int actionId, bool rowOnly) async {
    return _goalProvider.getGoalActionViaGoalAndAction(
        goalId, actionId, rowOnly);
  }

  Future<int> saveGoalMoment(GoalMoment goalMoment) async {
    return _goalProvider.saveGoalMoment(goalMoment);
  }

  Future<int> deleteGoalMoment(GoalMoment goalMoment) async {
    return _goalProvider.deleteGoalMoment(goalMoment);
  }

  Future<int> deleteGoalMomentVidGoalId(int goalId) async {
    throw(UnsupportedError('Not implemented'));
  }

  Future<int> deleteGoalMomentViaUniqueKey(
      String goalUuid, int goalActionId, int momentId) async {
    return _goalProvider.deleteGoalMomentViaUniqueKey(
        goalUuid, goalActionId, momentId);
  }

  Future<int> getGoalLastActiveTime(int goalId) async {
    return _goalProvider.getGoalLastActiveTime(goalId);
  }

  Future<int> getGoalActionLastActiveTime(int goalId, int goalActionId) async {
    return _goalProvider.getGoalActionLastActiveTime(goalId, goalActionId);
  }

  Future<int> getGoalTotalTimeTaken(int goalId) async {
    return _goalProvider.getGoalTotalTimeTaken(goalId);
  }

  Future<int> getGoalActionTotalTimeTaken(int goalId, int goalActionId) async {
    return _goalProvider.getGoalActionTotalTimeTaken(goalId, goalActionId);
  }

  Future<int> setStatus(String uuid, GoalStatus status) async {
    return _goalProvider.setStatus(uuid, status.index);
  }

}
